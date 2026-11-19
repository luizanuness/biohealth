-- Fixture de desenvolvimento: executar após 09_dados_teste_08.sql
-- e 10_paciente_responsavel_dados_teste.sql na MESMA conexão.
-- Ambiente exclusivamente descartável.
USE biohealth_validacao_integrada;

START TRANSACTION;
INSERT INTO solicitacao_vinculo
  (paciente_id, responsavel_id, status, solicitada_por_usuario_id)
VALUES (@paciente_id, @responsavel_id, 'PENDENTE', @usuario_admin_id);
SET @solicitacao_id = LAST_INSERT_ID();

UPDATE solicitacao_vinculo
SET status = 'APROVADA',
    analisada_em = CURRENT_TIMESTAMP(6),
    analisada_por_usuario_id = @usuario_admin_id,
    justificativa_decisao = 'Fixture de teste'
WHERE id = @solicitacao_id AND status = 'PENDENTE';
COMMIT;

SELECT id, paciente_id, responsavel_id, status
FROM solicitacao_vinculo WHERE id = @solicitacao_id;
