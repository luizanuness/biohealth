USE biohealth;

CREATE TABLE agendamento (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    paciente_id BIGINT UNSIGNED NOT NULL,
    profissional_id BIGINT UNSIGNED NOT NULL,
    especialidade_id BIGINT UNSIGNED NOT NULL,
    data_consulta DATE NOT NULL,
    horario TIME NOT NULL,
    status ENUM('AGENDADO', 'CONFIRMADO', 'CANCELADO', 'REALIZADO')
        NOT NULL DEFAULT 'AGENDADO',


    horario_reservado TIME GENERATED ALWAYS AS (
        CASE WHEN status = 'CANCELADO' THEN NULL ELSE horario END
    ) STORED,

    CONSTRAINT pk_agendamento PRIMARY KEY (id),
    CONSTRAINT fk_agendamento_paciente
        FOREIGN KEY (paciente_id) REFERENCES paciente(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_agendamento_profissional_especialidade
        FOREIGN KEY (profissional_id, especialidade_id)
        REFERENCES profissional_especialidade(profissional_id, especialidade_id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_agendamento_horario_profissional
        UNIQUE (profissional_id, data_consulta, horario_reservado),
    CONSTRAINT chk_agendamento_horario
        CHECK (horario >= '00:00:00' AND horario < '24:00:00')
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_agendamento_paciente_data
    ON agendamento (paciente_id, data_consulta);
