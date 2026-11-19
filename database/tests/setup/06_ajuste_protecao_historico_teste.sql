
-- =====================================================
-- BIOHEALTH
-- MODULO 06 - AJUSTE DA PROTECAO DO HISTORICO
-- MySQL Server 8.4 LTS
-- =====================================================

USE biohealth_teste_08;

DROP TRIGGER IF EXISTS trg_solicitacao_status_update;

DELIMITER $$

CREATE TRIGGER trg_solicitacao_status_update
BEFORE UPDATE ON solicitacao_vinculo
FOR EACH ROW
BEGIN
    -- A identidade da solicitacao nunca pode mudar
    IF NEW.paciente_id <> OLD.paciente_id
       OR NEW.responsavel_id <> OLD.responsavel_id THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Paciente e responsavel nao podem ser alterados';
    END IF;

    -- Uma solicitacao analisada nao pode ser reaberta
    IF OLD.status IN ('APROVADA', 'REJEITADA')
       AND NEW.status <> OLD.status THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Solicitacao analisada nao permite alteracao de status';
    END IF;

    -- Os dados da analise nao podem ser modificados
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
