
-- BioHealth | Pacote B
-- B03 - Disponibilidade semanal e bloqueios de agenda
-- MySQL 8.4 LTS
-- Executar apenas em ambiente de testes inicialmente.

USE biohealth;

CREATE TABLE disponibilidade_profissional (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    profissional_id BIGINT UNSIGNED NOT NULL,
    dia_semana TINYINT UNSIGNED NOT NULL,
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_disponibilidade_profissional
        PRIMARY KEY (id),

    CONSTRAINT fk_disponibilidade_profissional
        FOREIGN KEY (profissional_id)
        REFERENCES profissional_saude(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_disponibilidade_dia
        CHECK (dia_semana BETWEEN 1 AND 7),

    CONSTRAINT chk_disponibilidade_horario
        CHECK (horario_inicio < horario_fim),

    CONSTRAINT uq_disponibilidade_periodo
        UNIQUE (
            profissional_id,
            dia_semana,
            horario_inicio,
            horario_fim
        )
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


CREATE INDEX idx_disponibilidade_consulta
    ON disponibilidade_profissional (
        profissional_id,
        dia_semana,
        ativo
    );


CREATE TABLE bloqueio_agenda (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    profissional_id BIGINT UNSIGNED NOT NULL,
    inicio_em DATETIME NOT NULL,
    fim_em DATETIME NOT NULL,
    motivo VARCHAR(255) NULL,

    CONSTRAINT pk_bloqueio_agenda
        PRIMARY KEY (id),

    CONSTRAINT fk_bloqueio_profissional
        FOREIGN KEY (profissional_id)
        REFERENCES profissional_saude(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_bloqueio_periodo
        CHECK (inicio_em < fim_em),

    CONSTRAINT chk_bloqueio_motivo
        CHECK (
            motivo IS NULL
            OR CHAR_LENGTH(TRIM(motivo)) > 0
        )
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


CREATE INDEX idx_bloqueio_profissional_periodo
    ON bloqueio_agenda (
        profissional_id,
        inicio_em,
        fim_em
    );
