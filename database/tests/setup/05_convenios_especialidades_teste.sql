
-- =====================================================
-- BIOHEALTH
-- MODULO 05 - CONVENIOS E ESPECIALIDADES
-- MySQL Server 8.4 LTS
-- =====================================================

USE biohealth_teste_08;

-- 1. CONVENIO

CREATE TABLE convenio (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_convenio
        PRIMARY KEY (id),

    CONSTRAINT uq_convenio_nome
        UNIQUE (nome),

    CONSTRAINT chk_convenio_nome
        CHECK (CHAR_LENGTH(TRIM(nome)) > 0)

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- 2. PACIENTE_CONVENIO

CREATE TABLE paciente_convenio (
    paciente_id BIGINT UNSIGNED NOT NULL,
    convenio_id BIGINT UNSIGNED NOT NULL,
    numero_carteirinha VARCHAR(50) NULL,

    CONSTRAINT pk_paciente_convenio
        PRIMARY KEY (paciente_id, convenio_id),

    CONSTRAINT fk_paciente_convenio_paciente
        FOREIGN KEY (paciente_id)
        REFERENCES paciente(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_paciente_convenio_convenio
        FOREIGN KEY (convenio_id)
        REFERENCES convenio(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_paciente_convenio_carteirinha
        CHECK (
            numero_carteirinha IS NULL
            OR CHAR_LENGTH(TRIM(numero_carteirinha)) > 0
        )

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- 3. ESPECIALIDADE

CREATE TABLE especialidade (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_especialidade
        PRIMARY KEY (id),

    CONSTRAINT uq_especialidade_nome
        UNIQUE (nome),

    CONSTRAINT chk_especialidade_nome
        CHECK (CHAR_LENGTH(TRIM(nome)) > 0)

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- 4. PROFISSIONAL_ESPECIALIDADE

CREATE TABLE profissional_especialidade (
    profissional_id BIGINT UNSIGNED NOT NULL,
    especialidade_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_profissional_especialidade
        PRIMARY KEY (profissional_id, especialidade_id),

    CONSTRAINT fk_prof_esp_profissional
        FOREIGN KEY (profissional_id)
        REFERENCES profissional_saude(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_prof_esp_especialidade
        FOREIGN KEY (especialidade_id)
        REFERENCES especialidade(id)
        ON DELETE RESTRICT

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
