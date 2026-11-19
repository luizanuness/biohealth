-- =====================================================
-- BIOHEALTH - PREPARACAO DO AMBIENTE DE TESTES
-- Etapa 08 | MySQL 8.4
-- =====================================================

USE biohealth_validacao_integrada;

-- Confirmar o banco selecionado
SELECT DATABASE() AS banco_atual;

-- Verificar a quantidade de tabelas
SELECT COUNT(*) AS total_tabelas
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'biohealth_validacao_integrada'
  AND TABLE_TYPE = 'BASE TABLE';