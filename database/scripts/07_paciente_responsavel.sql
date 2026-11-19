
-- =====================================================
-- BIOHEALTH
-- MODULO 07 - VINCULO PACIENTE / RESPONSAVEL
-- MySQL Server 8.4 LTS
-- Executar apos o modulo 06
-- =====================================================

USE biohealth;

CREATE TABLE paciente_responsavel (

    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    paciente_id BIGINT UNSIGNED NOT NULL,

    responsavel_id BIGINT UNSIGNED NOT NULL,

    solicitacao_vinculo_id BIGINT UNSIGNED NOT NULL,

    iniciado_em DATETIME(6) NOT NULL
        DEFAULT CURRENT_TIMESTAMP(6),

    encerrado_em DATETIME(6) NULL,

    -- Colunas geradas para identificar vinculos ativos

    paciente_ativo_id BIGINT UNSIGNED
        GENERATED ALWAYS AS (
            CASE
                WHEN encerrado_em IS NULL
                THEN paciente_id
                ELSE NULL
            END
        ) STORED,

    responsavel_ativo_id BIGINT UNSIGNED
        GENERATED ALWAYS AS (
            CASE
                WHEN encerrado_em IS NULL
                THEN responsavel_id
                ELSE NULL
            END
        ) STORED,

    -- Chave primaria

    CONSTRAINT pk_paciente_responsavel
        PRIMARY KEY (id),

    -- Cada solicitacao origina no maximo um vinculo

    CONSTRAINT uq_pr_solicitacao
        UNIQUE (solicitacao_vinculo_id),

    -- Impede dois vinculos ativos para o mesmo par

    CONSTRAINT uq_pr_par_ativo
        UNIQUE (
            paciente_ativo_id,
            responsavel_ativo_id
        ),

    -- Indices auxiliares

    INDEX idx_pr_paciente (paciente_id),

    INDEX idx_pr_responsavel (responsavel_id),

    -- Chaves estrangeiras

    CONSTRAINT fk_pr_paciente
        FOREIGN KEY (paciente_id)
        REFERENCES paciente(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pr_responsavel
        FOREIGN KEY (responsavel_id)
        REFERENCES responsavel_legal(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pr_solicitacao_identidade
        FOREIGN KEY (
            solicitacao_vinculo_id,
            paciente_id,
            responsavel_id
        )
        REFERENCES solicitacao_vinculo (
            id,
            paciente_id,
            responsavel_id
        )
        ON DELETE RESTRICT,

    -- Data de encerramento nao pode ser anterior ao inicio

    CONSTRAINT chk_pr_periodo
        CHECK (
            encerrado_em IS NULL
            OR encerrado_em >= iniciado_em
        )

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

-- =====================================================
-- MODULO 07 - TRIGGERS DE INTEGRIDADE
-- =====================================================

DELIMITER $$

-- 1. Validar solicitacao aprovada

CREATE TRIGGER trg_pr_before_insert
BEFORE INSERT ON paciente_responsavel
FOR EACH ROW
BEGIN

    DECLARE v_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_nao_encontrado BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_nao_encontrado = TRUE;

    SELECT status
    INTO v_status
    FROM solicitacao_vinculo
    WHERE id = NEW.solicitacao_vinculo_id
      AND paciente_id = NEW.paciente_id
      AND responsavel_id = NEW.responsavel_id
    FOR UPDATE;

    IF v_nao_encontrado
       OR v_status <> 'APROVADA' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Vinculo exige solicitacao aprovada para o mesmo par';

    END IF;

    IF NEW.encerrado_em IS NOT NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Vinculo novo deve iniciar ativo';

    END IF;

END$$

-- 2. Proteger identidade e encerramento definitivo

CREATE TRIGGER trg_pr_before_update
BEFORE UPDATE ON paciente_responsavel
FOR EACH ROW
BEGIN

    IF NEW.id <> OLD.id
       OR NEW.paciente_id <> OLD.paciente_id
       OR NEW.responsavel_id <> OLD.responsavel_id
       OR NEW.solicitacao_vinculo_id <> OLD.solicitacao_vinculo_id
       OR NOT (NEW.iniciado_em <=> OLD.iniciado_em) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Identidade e inicio do vinculo sao imutaveis';

    END IF;

    IF OLD.encerrado_em IS NOT NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Vinculo encerrado e imutavel';

    END IF;

    IF NEW.encerrado_em IS NOT NULL
       AND NEW.encerrado_em < OLD.iniciado_em THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Encerramento anterior ao inicio do vinculo';

    END IF;

END$$

-- 3. Impedir exclusao do historico

CREATE TRIGGER trg_pr_before_delete
BEFORE DELETE ON paciente_responsavel
FOR EACH ROW
BEGIN

    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT =
        'Exclusao de vinculo proibida: preservar historico';

END$$

DELIMITER ;
