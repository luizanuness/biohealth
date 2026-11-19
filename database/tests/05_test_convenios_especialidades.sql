
USE biohealth_validacao_integrada;

START TRANSACTION;

INSERT INTO convenio (nome)
VALUES ('Convenio Teste A');

INSERT INTO especialidade (nome)
VALUES ('Especialidade Teste A');

SELECT id, nome, ativo
FROM convenio
WHERE nome = 'Convenio Teste A';

SELECT id, nome, ativo
FROM especialidade
WHERE nome = 'Especialidade Teste A';

ROLLBACK;
