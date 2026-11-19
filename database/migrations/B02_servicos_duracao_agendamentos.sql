-- BioHealth | B02 - Catalogo de servicos e duracao configuravel
-- MySQL 8.4 LTS | Migracao aditiva para schema existente.
-- NAO executada. Exige backup, homologacao e aplicacao unica.
USE biohealth;

-- Um servico pertence a uma especialidade nesta primeira versao.
-- Caso um servico atenda multiplas especialidades, revisar antes de aplicar.
CREATE TABLE servico (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    especialidade_id BIGINT UNSIGNED NOT NULL,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT NULL,
    duracao_minutos SMALLINT UNSIGNED NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_servico PRIMARY KEY (id),
    CONSTRAINT fk_servico_especialidade
        FOREIGN KEY (especialidade_id) REFERENCES especialidade(id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_servico_id_especialidade UNIQUE (id, especialidade_id),
    CONSTRAINT uq_servico_nome_especialidade UNIQUE (especialidade_id, nome),
    CONSTRAINT chk_servico_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
    CONSTRAINT chk_servico_descricao
        CHECK (descricao IS NULL OR CHAR_LENGTH(TRIM(descricao)) > 0),
    CONSTRAINT chk_servico_duracao CHECK (duracao_minutos BETWEEN 1 AND 1440)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Campos opcionais permitem preservar agendamentos legados sem inventar servico
-- nem atribuir duracao ficticia. A aplicacao deve exigir ambos para NOVOS registros.
ALTER TABLE agendamento
    ADD COLUMN servico_id BIGINT UNSIGNED NULL,
    ADD COLUMN duracao_minutos SMALLINT UNSIGNED NULL,
    ADD CONSTRAINT chk_agendamento_duracao
        CHECK (duracao_minutos IS NULL OR duracao_minutos BETWEEN 1 AND 1440),
    ADD CONSTRAINT chk_agendamento_servico_duracao
        CHECK ((servico_id IS NULL AND duracao_minutos IS NULL)
            OR (servico_id IS NOT NULL AND duracao_minutos IS NOT NULL)),
    ADD CONSTRAINT fk_agendamento_servico_especialidade
        FOREIGN KEY (servico_id, especialidade_id)
        REFERENCES servico(id, especialidade_id)
        ON DELETE RESTRICT;

CREATE INDEX idx_agendamento_profissional_intervalo
    ON agendamento (profissional_id, data_consulta, horario, status);

-- Nao converter registros existentes automaticamente.
-- Duracao armazenada em agendamento e um snapshot do momento da reserva;
-- alteracoes futuras no catalogo nao devem reescrever o historico.
-- Nao ha controle de sobreposicao por CHECK/UNIQUE: exige transacao no backend.
