
-- =====================================================
-- BIOHEALTH
-- MODULO 08 - PREPARACAO DO PAPEL ADMINISTRATIVO
-- MySQL Server 8.4 LTS
-- =====================================================

USE biohealth;

-- Cadastrar o papel, caso ainda nao exista

INSERT INTO papel (codigo, descricao)
SELECT
    'ADMIN',
    'Administrador do sistema BioHealth'
WHERE NOT EXISTS (
    SELECT 1
    FROM papel
    WHERE codigo = 'ADMIN'
);

-- Verificar o papel cadastrado

SELECT
    id,
    codigo,
    descricao
FROM papel
WHERE codigo = 'ADMIN';
