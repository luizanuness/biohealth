-- =====================================================
-- BIOHEALTH - ETAPA 08
-- DADOS DE TESTE: PACIENTE E RESPONSAVEL
-- =====================================================

USE biohealth_validacao_integrada;

START TRANSACTION;

-- 1. Pessoa do paciente
INSERT INTO pessoa (
    nome,
    cpf,
    data_nascimento
)
VALUES (
    'Paciente Teste BioHealth',
    '16899535009',
    '2015-05-10'
);

SET @pessoa_paciente_id = LAST_INSERT_ID();

-- 2. Perfil de paciente
INSERT INTO paciente (pessoa_id)
VALUES (@pessoa_paciente_id);

SET @paciente_id = LAST_INSERT_ID();

-- 3. Pessoa do responsavel
INSERT INTO pessoa (
    nome,
    cpf,
    data_nascimento
)
VALUES (
    'Responsavel Teste BioHealth',
    '86432199036',
    '1985-03-15'
);

SET @pessoa_responsavel_id = LAST_INSERT_ID();

-- 4. Perfil de responsavel
INSERT INTO responsavel_legal (pessoa_id)
VALUES (@pessoa_responsavel_id);

SET @responsavel_id = LAST_INSERT_ID();

COMMIT;

-- 5. Validacao
SELECT
    pa.id AS paciente_id,
    pp.nome AS paciente_nome,
    rl.id AS responsavel_id,
    pr.nome AS responsavel_nome
FROM paciente pa
JOIN pessoa pp ON pp.id = pa.pessoa_id
CROSS JOIN responsavel_legal rl
JOIN pessoa pr ON pr.id = rl.pessoa_id
WHERE pa.id = @paciente_id
  AND rl.id = @responsavel_id;