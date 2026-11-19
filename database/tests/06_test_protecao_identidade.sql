
-- =====================================================
-- BIOHEALTH
-- TESTE 06 - PROTECAO DA IDENTIDADE
-- Esperado: MySQL Error 1644
-- =====================================================

USE biohealth;

START TRANSACTION;

-- Criar duas pessoas com CPF de teste
INSERT INTO pessoa (nome, cpf)
VALUES ('Paciente Teste Identidade A', '52998224725');

SET @pessoa_a = LAST_INSERT_ID();

INSERT INTO paciente (pessoa_id)
VALUES (@pessoa_a);

SET @paciente_a = LAST_INSERT_ID();

INSERT INTO pessoa (nome, cpf)
VALUES ('Paciente Teste Identidade B', '11144477735');

SET @pessoa_b = LAST_INSERT_ID();

INSERT INTO paciente (pessoa_id)
VALUES (@pessoa_b);

SET @paciente_b = LAST_INSERT_ID();

-- Criar responsavel legal
INSERT INTO pessoa (nome, cpf)
VALUES ('Responsavel Teste Identidade', '12345678909');

SET @pessoa_responsavel = LAST_INSERT_ID();

INSERT INTO responsavel_legal (pessoa_id)
VALUES (@pessoa_responsavel);

SET @responsavel = LAST_INSERT_ID();

-- Criar solicitacao pendente
INSERT INTO solicitacao_vinculo (
    paciente_id,
    responsavel_id
)
VALUES (
    @paciente_a,
    @responsavel
);

SET @solicitacao_teste = LAST_INSERT_ID();

-- Confirmar solicitacao
SELECT id, paciente_id, responsavel_id, status
FROM solicitacao_vinculo
WHERE id = @solicitacao_teste;

-- PARE AQUI.
-- Execute o UPDATE abaixo separadamente.
