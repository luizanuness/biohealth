-- =====================================================
-- BIOHEALTH - PREPARACAO DO AMBIENTE DE TESTES
-- Etapa 08 | MySQL 8.4
-- =====================================================

USE biohealth_teste_08;

-- Confirmar o banco selecionado
SELECT DATABASE() AS banco_atual;

-- Verificar a quantidade de tabelas
SELECT COUNT(*) AS total_tabelas
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'biohealth_teste_08'
  AND TABLE_TYPE = 'BASE TABLE';