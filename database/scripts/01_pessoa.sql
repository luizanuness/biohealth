USE biohealth;

CREATE TABLE pessoa (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    nome VARCHAR(120) NOT NULL,

    cpf CHAR(11) NULL,

    data_nascimento DATE NULL,

    telefone VARCHAR(20) NULL,

    CONSTRAINT pk_pessoa
        PRIMARY KEY (id),

    CONSTRAINT uq_pessoa_cpf
        UNIQUE (cpf),

    CONSTRAINT chk_pessoa_nome
        CHECK (CHAR_LENGTH(TRIM(nome)) > 0),

    CONSTRAINT chk_pessoa_cpf_formato
        CHECK (
            cpf IS NULL
            OR REGEXP_LIKE(cpf, '^[0-9]{11}$')
        )

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
