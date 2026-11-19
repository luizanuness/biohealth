-- =====================================================
-- BIOHEALTH - ETAPA 08
-- CRIACAO DO VINCULO ATIVO - CORRECAO ERRO 1442
-- Ambiente isolado: biohealth_teste_08
-- =====================================================

USE biohealth_teste_08;

-- Encerrar eventual transacao pendente da tentativa anterior
ROLLBACK;

-- Conferir se o vinculo ainda nao existe
SELECT
    id,
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id,
    encerrado_em
FROM paciente_responsavel
WHERE solicitacao_vinculo_id = 1;

-- Conferir a solicitacao aprovada
SELECT
    id,
    paciente_id,
    responsavel_id,
    status
FROM solicitacao_vinculo
WHERE id = 1;

-- EXECUTAR O BLOCO ABAIXO SOMENTE SE:
-- 1. Nenhum vinculo existir para a solicitacao 1
-- 2. A solicitacao estiver APROVADA

START TRANSACTION;

INSERT INTO paciente_responsavel (
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id
)
VALUES (
    1,
    1,
    1
);

COMMIT;

-- Verificar a persistencia
SELECT
    id,
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id,
    iniciado_em,
    encerrado_em
FROM paciente_responsavel
WHERE solicitacao_vinculo_id = 1;