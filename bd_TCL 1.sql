CREATE MATERIALIZED VIEW contas_nomes AS
SELECT cod, cliente.nome, saldo FROM conta, cliente WHERE cliente.id = conta.cliente
WITH DATA;

REFRESH MATERIALIZED VIEW contas_nomes;
SELECT * FROM contas_nomes;

UPDATE conta SET saldo = saldo - 100 WHERE cliente IN (SELECT id FROM cliente WHERE nome = 'Bruce Wayne')
UPDATE conta SET saldo = saldo + 100 WHERE cliente IN (SELECT id FROM cliente WHERE nome = 'Clark Kent')

BEGIN;
	UPDATE conta SET saldo = saldo -100
		WHERE cliente IN (SELECT id FROM cliente WHERE nome = 'Bruce Wayne');
	UPDATE conta SET saldo = saldo + 100
		WHERE cliente IN (SELECT id FROM cliente WHERE nome = 'Clark Kent');
COMMIT;

BEGIN;
	UPDATE conta SET saldo = saldo - 100
		WHERE cliente IN (SELECT id FROM cliente WHERE nome = 'Bruce Wayne');
		
	SAVEPOINT debito;
	UPDATE conta SET saldo = saldo + 100
		WHERE cliente IN (SELECT id FROM cliente WHERE nome = 'Clark Kent');
		
	ROLLBACK TO debito;
	
	UPDATE conta SET saldo = saldo + 100
		WHERE cliente IN (SELECT id FROM cliente WHERE nome = 'Berry Allen');
COMMIT;




CREATE OR REPLACE PROCEDURE transferencia (pagador TEXT, recebedor TEXT, valor DECIMAL)
LANGUAGE 'plpgsql' AS $$
	BEGIN
		IF ((SELECT saldo FROM conta WHERE cliente IN (SELECT id FROM cliente WHERE nome = pagador)) < valor) THEN
			RAISE EXCEPTION 'Saldo insuficiente';
		ELSE
			UPDATE conta SET saldo = saldo - valor
				WHERE cliente IN (SELECT id FROM cliente WHERE nome = pagador);
			UPDATE conta SET saldo = saldo + valor
				WHERE cliente IN (SELECT id FROM cliente WHERE nome = recebedor);
		END IF;
	COMMIT;
END; $$

CALL transferencia('Barry Allen', 'Klark Kent', 100)