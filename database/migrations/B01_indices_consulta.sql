-- BioHealth | Evolucao incremental B01
-- MySQL 8.4 LTS
-- Pre-requisito: schema academico 00-10 instalado.
-- Preserva todos os registros existentes. Nenhum DROP/DELETE/UPDATE de dados.
-- Executar uma unica vez no schema biohealth apos backup e validacao em homologacao.
USE biohealth;

-- Consultas por agenda de profissional e status.
CREATE INDEX idx_agendamento_profissional_data_status
    ON agendamento (profissional_id, data_consulta, status);

-- Filtros do historico de saude por paciente e classificacao.
CREATE INDEX idx_informacao_saude_paciente_tipo_data
    ON informacao_saude (paciente_id, tipo_informacao, data_registro);

-- Historico de solicitacoes por par paciente/responsavel.
CREATE INDEX idx_solicitacao_par_data
    ON solicitacao_vinculo (paciente_id, responsavel_id, solicitada_em);

-- Nota: a migracao nao resolve conflitos de intervalo nem implementa autorizacao.
-- Nao repetir a execucao: indices com o mesmo nome ja existentes geram erro.
