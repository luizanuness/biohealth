
-- =====================================================
-- BIOHEALTH
-- TESTES DO MODULO 07 - PACIENTE RESPONSAVEL
-- MySQL Server 8.4 LTS
-- =====================================================

USE biohealth_validacao_integrada;

START TRANSACTION;

-- A. Criar paciente temporario

INSERT INTO pessoa (nome, cpf)
VALUES ('Paciente Teste 07', '16899535009');

SET @pessoa_paciente_07 = LAST_INSERT_ID();

INSERT INTO paciente (pessoa_id)
VALUES (@pessoa_paciente_07);

SET @paciente_07 = LAST_INSERT_ID();

-- B. Criar responsavel temporario

INSERT INTO pessoa (nome, cpf)
VALUES ('Responsavel Teste 07', '86432199036');

SET @pessoa_responsavel_07 = LAST_INSERT_ID();

INSERT INTO responsavel_legal (pessoa_id)
VALUES (@pessoa_responsavel_07);

SET @responsavel_07 = LAST_INSERT_ID();

-- C. Criar usuario analista temporario

INSERT INTO pessoa (nome)
VALUES ('Analista Teste 07');

SET @pessoa_analista_07 = LAST_INSERT_ID();

INSERT INTO usuario (
    pessoa_id,
    email,
    senha_hash
)
VALUES (
    @pessoa_analista_07,
    'analista.teste07@biohealth.invalid',
    'HASH_FICTICIO_TESTE'
);

SET @analista_07 = LAST_INSERT_ID();

-- D. Criar solicitacao pendente

INSERT INTO solicitacao_vinculo (
    paciente_id,
    responsavel_id
)
VALUES (
    @paciente_07,
    @responsavel_07
);

SET @solicitacao_07_a = LAST_INSERT_ID();

-- Conferir solicitacao criada

SELECT
    id,
    paciente_id,
    responsavel_id,
    status
FROM solicitacao_vinculo
WHERE id = @solicitacao_07_a;


-- =====================================================
-- TESTE 1 - SOLICITACAO PENDENTE
-- Esperado: erro 1644
-- Executar INSERT separadamente
-- =====================================================

INSERT INTO paciente_responsavel (
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id
)
VALUES (
    @paciente_07,
    @responsavel_07,
    @solicitacao_07_a
);

-- =====================================================
-- TESTE 2 - APROVAR SOLICITACAO
-- Esperado: sucesso
-- =====================================================

UPDATE solicitacao_vinculo
SET
    status = 'APROVADA',
    analisada_em = CURRENT_TIMESTAMP(6),
    analisada_por_usuario_id = @analista_07
WHERE id = @solicitacao_07_a;

-- Criar vinculo ativo

INSERT INTO paciente_responsavel (
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id
)
VALUES (
    @paciente_07,
    @responsavel_07,
    @solicitacao_07_a
);

SET @vinculo_07_a = LAST_INSERT_ID();

-- Conferir vinculo

SELECT
    id,
    paciente_id,
    responsavel_id,
    iniciado_em,
    encerrado_em
FROM paciente_responsavel
WHERE id = @vinculo_07_a;

-- =====================================================
-- TESTE 3 - SOLICITACAO JA UTILIZADA
-- Esperado: erro 1062
-- Executar INSERT separadamente
-- =====================================================

INSERT INTO paciente_responsavel (
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id
)
VALUES (
    @paciente_07,
    @responsavel_07,
    @solicitacao_07_a
);


-- =====================================================
-- TESTE 4 - NOVA SOLICITACAO PARA O MESMO PAR
-- =====================================================

INSERT INTO solicitacao_vinculo (
    paciente_id,
    responsavel_id
)
VALUES (
    @paciente_07,
    @responsavel_07
);

SET @solicitacao_07_b = LAST_INSERT_ID();

UPDATE solicitacao_vinculo
SET
    status = 'APROVADA',
    analisada_em = CURRENT_TIMESTAMP(6),
    analisada_por_usuario_id = @analista_07
WHERE id = @solicitacao_07_b;

-- Tentar criar segundo vinculo ativo
-- Esperado: erro 1062

INSERT INTO paciente_responsavel (
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id
)
VALUES (
    @paciente_07,
    @responsavel_07,
    @solicitacao_07_b
);

-- =====================================================
-- TESTE 5 - IMPEDIR ALTERACAO DA IDENTIDADE
-- Esperado: erro 1644
-- =====================================================

UPDATE paciente_responsavel
SET solicitacao_vinculo_id = @solicitacao_07_b
WHERE id = @vinculo_07_a;

-- =====================================================
-- TESTE 6 - ENCERRAR VINCULO ORIGINAL
-- Esperado: sucesso
-- =====================================================

UPDATE paciente_responsavel
SET encerrado_em = CURRENT_TIMESTAMP(6)
WHERE id = @vinculo_07_a;

-- =====================================================
-- TESTE 7 - IMPEDIR REATIVACAO
-- Esperado: erro 1644
-- =====================================================

UPDATE paciente_responsavel
SET encerrado_em = NULL
WHERE id = @vinculo_07_a;

-- =====================================================
-- TESTE 8 - IMPEDIR ALTERACAO DO ENCERRAMENTO
-- Esperado: erro 1644
-- =====================================================

UPDATE paciente_responsavel
SET encerrado_em =
    DATE_ADD(encerrado_em, INTERVAL 1 SECOND)
WHERE id = @vinculo_07_a;

-- =====================================================
-- TESTE 9 - IMPEDIR EXCLUSAO
-- Esperado: erro 1644
-- =====================================================

DELETE FROM paciente_responsavel
WHERE id = @vinculo_07_a;

-- =====================================================
-- TESTE 10 - NOVO VINCULO APOS ENCERRAMENTO
-- Esperado: sucesso
-- =====================================================

INSERT INTO paciente_responsavel (
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id
)
VALUES (
    @paciente_07,
    @responsavel_07,
    @solicitacao_07_b
);

SET @vinculo_07_b = LAST_INSERT_ID();

-- Conferir historico

SELECT
    id,
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id,
    iniciado_em,
    encerrado_em
FROM paciente_responsavel
WHERE id IN (
    @vinculo_07_a,
    @vinculo_07_b
)
ORDER BY id;

-- =====================================================
-- LIMPEZA FINAL DOS TESTES
-- Executar apos validar todos os cenarios
-- =====================================================

ROLLBACK;

-- Confirmar remocao dos vinculos temporarios

SELECT COUNT(*) AS registros_restantes
FROM paciente_responsavel
WHERE id IN (
    @vinculo_07_a,
    @vinculo_07_b
);

-- Confirmar remocao das solicitacoes temporarias

SELECT COUNT(*) AS solicitacoes_restantes
FROM solicitacao_vinculo
WHERE id IN (
    @solicitacao_07_a,
    @solicitacao_07_b
);

-- Confirmar remocao das pessoas temporarias

SELECT COUNT(*) AS pessoas_restantes
FROM pessoa
WHERE id IN (
    @pessoa_paciente_07,
    @pessoa_responsavel_07,
    @pessoa_analista_07
);