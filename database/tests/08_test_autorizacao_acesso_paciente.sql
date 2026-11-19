-- =====================================================
-- BIOHEALTH
-- ETAPA 08 - TESTES DE AUTORIZACAO DE ACESSO
-- MySQL Server 8.4
-- Ambiente exclusivo: biohealth_teste_08
-- =====================================================

USE biohealth_teste_08;

-- TESTE 01: Conferir o banco selecionado
SELECT DATABASE() AS banco_atual;

-- TESTE 02: Conferir autorizacoes existentes
SELECT
    id,
    paciente_responsavel_id,
    status,
    concedida_em,
    encerrada_em
FROM autorizacao_acesso_paciente
ORDER BY id;

-- TESTE 03: Conferir categorias vinculadas
SELECT
    a.id AS autorizacao_id,
    a.status,
    c.codigo AS categoria
FROM autorizacao_acesso_paciente a
JOIN autorizacao_categoria ac
    ON ac.autorizacao_id = a.id
JOIN categoria_acesso c
    ON c.id = ac.categoria_id
ORDER BY a.id, c.codigo;

-- TESTE 04: Conferir vinculos ativos
SELECT
    id,
    paciente_id,
    responsavel_id,
    solicitacao_vinculo_id,
    iniciado_em,
    encerrado_em
FROM paciente_responsavel
WHERE encerrado_em IS NULL;

-- TESTE 05: Conferir usuarios administradores ativos
SELECT
    u.id,
    u.email,
    u.ativo,
    p.codigo AS papel
FROM usuario u
JOIN usuario_papel up
    ON up.usuario_id = u.id
JOIN papel p
    ON p.id = up.papel_id
WHERE p.codigo = 'ADMIN'
  AND u.ativo = TRUE;