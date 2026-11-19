USE biohealth;


CREATE TABLE paciente (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pessoa_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_paciente
        PRIMARY KEY (id),

    CONSTRAINT uq_paciente_pessoa
        UNIQUE (pessoa_id),

    CONSTRAINT fk_paciente_pessoa
        FOREIGN KEY (pessoa_id)
        REFERENCES pessoa(id)
        ON DELETE RESTRICT

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;



CREATE TABLE responsavel_legal (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pessoa_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_responsavel_pessoa
        PRIMARY KEY (id),

    CONSTRAINT uq_responsavel_pessoa
        UNIQUE (pessoa_id),

    CONSTRAINT fk_responsavel_pessoa
        FOREIGN KEY (pessoa_id)
        REFERENCES pessoa(id)
        ON DELETE RESTRICT

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;



CREATE TABLE funcionario (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pessoa_id BIGINT UNSIGNED NOT NULL,
    cargo VARCHAR(100) NOT NULL,

    CONSTRAINT pk_funcionario
        PRIMARY KEY (id),

    CONSTRAINT uq_funcionario_pessoa
        UNIQUE (pessoa_id),

    CONSTRAINT fk_funcionario_pessoa
        FOREIGN KEY (pessoa_id)
        REFERENCES pessoa(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_funcionario_cargo
        CHECK (CHAR_LENGTH(TRIM(cargo)) > 0)

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;



CREATE TABLE profissional_saude (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pessoa_id BIGINT UNSIGNED NOT NULL,
    registro_profissional VARCHAR(30) NOT NULL,

    CONSTRAINT pk_profissional_saude
        PRIMARY KEY (id),

    CONSTRAINT uq_profissional_pessoa
        UNIQUE (pessoa_id),

    CONSTRAINT fk_profissional_pessoa
        FOREIGN KEY (pessoa_id)
        REFERENCES pessoa(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_profissional_registro
        CHECK (
            CHAR_LENGTH(TRIM(registro_profissional)) > 0
        )

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
