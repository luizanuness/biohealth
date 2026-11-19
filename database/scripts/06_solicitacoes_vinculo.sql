
USE biohealth;

CREATE TABLE solicitacao_vinculo (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

    paciente_id BIGINT UNSIGNED NOT NULL,
    responsavel_id BIGINT UNSIGNED NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',

    solicitada_em DATETIME(6) NOT NULL
        DEFAULT CURRENT_TIMESTAMP(6),

    solicitada_por_usuario_id BIGINT UNSIGNED NULL,

    analisada_em DATETIME(6) NULL,
    analisada_por_usuario_id BIGINT UNSIGNED NULL,

    justificativa_decisao VARCHAR(500) NULL,

    paciente_pendente_id BIGINT UNSIGNED
        GENERATED ALWAYS AS (
            CASE
                WHEN status = 'PENDENTE'
                THEN paciente_id
                ELSE NULL
            END
        ) STORED,

    responsavel_pendente_id BIGINT UNSIGNED
        GENERATED ALWAYS AS (
            CASE
                WHEN status = 'PENDENTE'
                THEN responsavel_id
                ELSE NULL
            END
        ) STORED,

    PRIMARY KEY (id),

    CONSTRAINT uq_solicitacao_pendente
        UNIQUE (
            paciente_pendente_id,
            responsavel_pendente_id
        ),

    CONSTRAINT uq_solicitacao_identidade
        UNIQUE (id, paciente_id, responsavel_id),

    CONSTRAINT fk_solicitacao_paciente
        FOREIGN KEY (paciente_id)
        REFERENCES paciente(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_solicitacao_responsavel
        FOREIGN KEY (responsavel_id)
        REFERENCES responsavel_legal(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_solicitacao_solicitante
        FOREIGN KEY (solicitada_por_usuario_id)
        REFERENCES usuario(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_solicitacao_analista
        FOREIGN KEY (analisada_por_usuario_id)
        REFERENCES usuario(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_solicitacao_status
        CHECK (
            status IN (
                'PENDENTE',
                'APROVADA',
                'REJEITADA'
            )
        ),

    CONSTRAINT chk_solicitacao_analise
        CHECK (
            (
                status = 'PENDENTE'
                AND analisada_em IS NULL
                AND analisada_por_usuario_id IS NULL
            )
            OR
            (
                status IN ('APROVADA', 'REJEITADA')
                AND analisada_em IS NOT NULL
                AND analisada_por_usuario_id IS NOT NULL
                AND analisada_em >= solicitada_em
            )
        )

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
