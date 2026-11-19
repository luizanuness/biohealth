
-- =====================================================
-- BIOHEALTH
-- MODULO 02 - IDENTIDADE DIGITAL
-- MySQL Server 8.4 LTS
-- =====================================================

USE biohealth;

-- 1. Tabela USUARIO

CREATE TABLE usuario (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pessoa_id BIGINT UNSIGNED NOT NULL,
    email VARCHAR(180) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_usuario
        PRIMARY KEY (id),

    CONSTRAINT uq_usuario_pessoa
        UNIQUE (pessoa_id),

    CONSTRAINT uq_usuario_email
        UNIQUE (email),

    CONSTRAINT fk_usuario_pessoa
        FOREIGN KEY (pessoa_id)
        REFERENCES pessoa(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_usuario_email
        CHECK (CHAR_LENGTH(TRIM(email)) > 3),

    CONSTRAINT chk_usuario_senha_hash
        CHECK (CHAR_LENGTH(TRIM(senha_hash)) > 0)

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- 2. Tabela PAPEL

CREATE TABLE papel (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(40) NOT NULL,
    descricao VARCHAR(150) NOT NULL,

    CONSTRAINT pk_papel
        PRIMARY KEY (id),

    CONSTRAINT uq_papel_codigo
        UNIQUE (codigo),

    CONSTRAINT chk_papel_codigo
        CHECK (CHAR_LENGTH(TRIM(codigo)) > 0)

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;


-- 3. Tabela USUARIO_PAPEL

CREATE TABLE usuario_papel (
    usuario_id BIGINT UNSIGNED NOT NULL,
    papel_id BIGINT UNSIGNED NOT NULL,

    CONSTRAINT pk_usuario_papel
        PRIMARY KEY (usuario_id, papel_id),

    CONSTRAINT fk_usuario_papel_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_usuario_papel_papel
        FOREIGN KEY (papel_id)
        REFERENCES papel(id)
        ON DELETE RESTRICT

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
