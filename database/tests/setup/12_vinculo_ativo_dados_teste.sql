-- Fixture de desenvolvimento: executar após 11_solicitacao_vinculo_dados_teste.sql
-- na MESMA conexão e somente em banco de teste vazio.
USE biohealth_validacao_integrada;

START TRANSACTION;
INSERT INTO paciente_responsavel
  (paciente_id, responsavel_id, solicitacao_vinculo_id)
VALUES (@paciente_id, @responsavel_id, @solicitacao_id);
SET @vinculo_id = LAST_INSERT_ID();
COMMIT;

SELECT id, paciente_id, responsavel_id, solicitacao_vinculo_id, encerrado_em
FROM paciente_responsavel WHERE id = @vinculo_id;
