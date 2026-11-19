
-- =====================================================
-- BIOHEALTH
-- TESTE 06 - HISTORICO E TRANSICAO DE STATUS
-- MySQL Server 8.4 LTS
--
-- Execucao em etapas:
-- 1. Executar ate o SELECT de verificacao.
-- 2. Executar o UPDATE invalido separadamente.
-- 3. Confirmar o bloqueio e executar ROLLBACK.
-- =====================================================

USE biohealth;

START TRANSACTION;

-- 1. Criar paciente temporario
INSERT INTO pessoa (nome, cpf)
VALUES ('Paciente Teste 06', '52998224725');

SET @pessoa_paciente_id = LAST_INSERT_ID();

INSERT INTO paciente (pessoa_id)
VALUES (@pessoa_paciente_id);

SET @paciente_id = LAST_INSERT_ID();

-- 2. Criar responsavel temporario
INSERT INTO pessoa (nome, cpf)
VALUES ('Responsavel Teste 06', '11144477735');

SET @pessoa_responsavel_id = LAST_INSERT_ID();

INSERT INTO responsavel_legal (pessoa_id)
VALUES (@pessoa_responsavel_id);

SET @responsavel_id = LAST_INSERT_ID();

-- 3. Criar usuario analista temporario
INSERT INTO pessoa (nome)
VALUES ('Analista Teste 06');

SET @pessoa_analista_id = LAST_INSERT_ID();

INSERT INTO usuario (pessoa_id, email, senha_hash)
VALUES (
    @pessoa_analista_id,
    'analista.teste06@biohealth.invalid',
    'HASH_FICTICIO_APENAS_TESTE'
);

SET @usuario_analista_id = LAST_INSERT_ID();

-- 4. Criar primeira solicitacao
INSERT INTO solicitacao_vinculo (
    paciente_id,
    responsavel_id
)
VALUES (
    @paciente_id,
    @responsavel_id
);

SET @solicitacao_original_id = LAST_INSERT_ID();

-- 5. Registrar rejeicao
UPDATE solicitacao_vinculo
SET
    status = 'REJEITADA',
    analisada_em = CURRENT_TIMESTAMP(6),
    analisada_por_usuario_id = @usuario_analista_id,
    justificativa_decisao = 'Rejeicao para teste'
WHERE id = @solicitacao_original_id;

-- 6. Preservar historico criando nova solicitacao
INSERT INTO solicitacao_vinculo (
    paciente_id,
    responsavel_id
)
VALUES (
    @paciente_id,
    @responsavel_id
);

SET @nova_solicitacao_id = LAST_INSERT_ID();

-- 7. Conferir as duas solicitacoes
SELECT
    id,
    paciente_id,
    responsavel_id,
    status,
    analisada_em
FROM solicitacao_vinculo
WHERE paciente_id = @paciente_id
  AND responsavel_id = @responsavel_id
ORDER BY id;

-- 8. Verificar a solicitacao rejeitada
SELECT
    id,
    status
FROM solicitacao_vinculo
WHERE id = @solicitacao_original_id;

-- PARE A EXECUCAO AQUI.
-- Nao execute ROLLBACK antes do teste seguinte.
