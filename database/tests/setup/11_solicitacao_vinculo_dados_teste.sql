-- =====================================================
-- BIOHEALTH - ETAPA 08
-- SOLICITACAO E APROVACAO DE VINCULO
-- Banco exclusivo de testes
-- =====================================================

USE biohealth_teste_08;

START TRANSACTION;

-- 1. Criar solicitacao pendente
INSERT INTO solicitacao_vinculo (
    paciente_id,
    responsavel_id,
    status,
    solicitada_por_usuario_id
)
VALUES (
    1,
    1,
    'PENDENTE',
    1
);

SET @solicitacao_id = LAST_INSERT_ID();

-- 2. Aprovar a solicitacao
UPDATE solicitacao_vinculo
SET
    status = 'APROVADA',
    analisada_em = CURRENT_TIMESTAMP(6),
    analisada_por_usuario_id = 1,
    justificativa_decisao = 'Vinculo aprovado para testes da Etapa 08'
WHERE id = @solicitacao_id
  AND status = 'PENDENTE';

COMMIT;

-- 3. Verificar resultado
SELECT
    id,
    paciente_id,
    responsavel_id,
    status,
    solicitada_em,
    analisada_em,
    analisada_por_usuario_id
FROM solicitacao_vinculo
WHERE id = @solicitacao_id;