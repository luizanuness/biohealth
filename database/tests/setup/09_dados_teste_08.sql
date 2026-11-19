-- =====================================================
-- BIOHEALTH - DADOS INICIAIS DE TESTE
-- Etapa 08 | Administrador temporario
-- =====================================================

USE biohealth_validacao_integrada;

-- Interromper caso a conexao esteja em outro banco
SELECT DATABASE() AS banco_atual;

START TRANSACTION;

-- Criar pessoa administrativa ficticia
INSERT INTO pessoa (
    nome,
    cpf
)
VALUES (
    'Administrador Teste BioHealth',
    NULL
);

SET @pessoa_admin_id = LAST_INSERT_ID();

-- Criar usuario de teste
-- Hash ficticio: nao utilizar para autenticacao real
INSERT INTO usuario (
    pessoa_id,
    email,
    senha_hash,
    ativo
)
VALUES (
    @pessoa_admin_id,
    'admin.etapa08@biohealth.invalid',
    'HASH_FICTICIO_SOMENTE_TESTE',
    TRUE
);

SET @usuario_admin_id = LAST_INSERT_ID();

-- Associar ao papel ADMIN
INSERT INTO usuario_papel (
    usuario_id,
    papel_id
)
SELECT
    @usuario_admin_id,
    id
FROM papel
WHERE codigo = 'ADMIN';

COMMIT;

-- Confirmar usuario administrativo
SELECT
    u.id AS usuario_admin_id,
    p.nome,
    u.email,
    u.ativo,
    pa.codigo AS papel
FROM usuario u
JOIN pessoa p ON p.id = u.pessoa_id
JOIN usuario_papel up ON up.usuario_id = u.id
JOIN papel pa ON pa.id = up.papel_id
WHERE u.id = @usuario_admin_id;