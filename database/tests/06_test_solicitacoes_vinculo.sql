
USE biohealth;

-- TESTE 03: preservar historico e permitir nova solicitacao
START TRANSACTION;

-- 1. Criar paciente temporario
INSERT INTO pessoa (nome, cpf)
VALUES ('Paciente Historico Teste', '52998224725');

SET @pessoa_paciente_id = LAST_INSERT_ID();

INSERT INTO paciente (pessoa_id)
VALUES (@pessoa_paciente_id);

SET @paciente_id = LAST_INSERT_ID();

-- 2. Criar responsavel temporario
INSERT INTO pessoa (nome, cpf)
VALUES ('Responsavel Historico Teste', '11144477735');

SET @pessoa_responsavel_id = LAST_INSERT_ID();

INSERT INTO responsavel_legal (pessoa_id)
VALUES (@pessoa_responsavel_id);

SET @responsavel_id = LAST_INSERT_ID();

-- 3. Criar pessoa que realizara a analise
INSERT INTO pessoa (nome)
VALUES ('Analista Historico Teste');

SET @pessoa_analista_id = LAST_INSERT_ID();

-- 4. Criar usuario para a analise
-- Ajustar email/senha_hash somente se necessario
INSERT INTO usuario (pessoa_id, email, senha_hash)
VALUES (
    @pessoa_analista_id,
    'analista.historico.teste@biohealth.invalid',
    'HASH_FICTICIO_APENAS_TESTE_SQL'
);

SET @usuario_analista_id = LAST_INSERT_ID();

-- 5. Registrar primeira solicitacao
INSERT INTO solicitacao_vinculo (
    paciente_id,
    responsavel_id,
    status
)
VALUES (
    @paciente_id,
    @responsavel_id,
    'PENDENTE'
);

SET @solicitacao_original_id = LAST_INSERT_ID();

-- 6. Rejeitar a primeira solicitacao
UPDATE solicitacao_vinculo
SET
    status = 'REJEITADA',
    analisada_em = CURRENT_TIMESTAMP(6),
    analisada_por_usuario_id = @usuario_analista_id,
    justificativa_decisao = 'Rejeicao para teste de historico'
WHERE id = @solicitacao_original_id;

-- 7. Registrar nova solicitacao para o mesmo par
INSERT INTO solicitacao_vinculo (
    paciente_id,
    responsavel_id,
    status
)
VALUES (
    @paciente_id,
    @responsavel_id,
    'PENDENTE'
);

-- 8. Conferir preservacao do historico
SELECT
    id,
    paciente_id,
    responsavel_id,
    status,
    analisada_em,
    analisada_por_usuario_id
FROM solicitacao_vinculo
WHERE paciente_id = @paciente_id
  AND responsavel_id = @responsavel_id
ORDER BY id;

-- 9. Descartar os dados temporarios
ROLLBACK;



-- =====================================================
-- BIOHEALTH
-- 06 - Integridade das solicitacoes de vinculo
-- Protecao de transicoes de status
-- MySQL 8.4
-- =====================================================

USE biohealth;

DROP TRIGGER IF EXISTS trg_solicitacao_status_update;

DELIMITER $$

CREATE TRIGGER trg_solicitacao_status_update
BEFORE UPDATE ON solicitacao_vinculo
FOR EACH ROW
BEGIN
    -- Uma solicitacao analisada nao pode
    -- ter seu status alterado posteriormente.
    IF OLD.status IN ('APROVADA', 'REJEITADA')
       AND NEW.status <> OLD.status THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Solicitacao analisada nao permite alteracao de status';

    END IF;

    -- Nao permitir alterar os dados de analise
    -- depois da decisao registrada.
    IF OLD.status IN ('APROVADA', 'REJEITADA')
       AND (
           NOT (NEW.analisada_em <=> OLD.analisada_em)
           OR NOT (
               NEW.analisada_por_usuario_id
               <=> OLD.analisada_por_usuario_id
           )
           OR NOT (
               NEW.justificativa_decisao
               <=> OLD.justificativa_decisao
           )
       ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Dados da analise nao podem ser alterados';

    END IF;

END$$

DELIMITER ;
