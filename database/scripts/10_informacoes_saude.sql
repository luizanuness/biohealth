USE biohealth;

CREATE TABLE informacao_saude (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    paciente_id BIGINT UNSIGNED NOT NULL,
    descricao TEXT NULL,
    data_registro DATE NOT NULL,
    tipo_informacao ENUM(
        'EXAME',
        'RESULTADO_EXAME',
        'HISTORICO_MEDICO',
        'ALERGIA',
        'MEDICAMENTO',
        'VACINA',
        'OUTRO'
    ) NOT NULL,

    CONSTRAINT pk_informacao_saude PRIMARY KEY (id),
    CONSTRAINT fk_informacao_saude_paciente
        FOREIGN KEY (paciente_id) REFERENCES paciente(id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_informacao_saude_descricao
        CHECK (descricao IS NULL OR CHAR_LENGTH(TRIM(descricao)) > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX idx_informacao_saude_paciente_data
    ON informacao_saude (paciente_id, data_registro);
