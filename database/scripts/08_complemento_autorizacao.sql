-- Recuperacao para AMBIENTE DE DESENVOLVIMENTO com tres tabelas ja criadas.
-- Precondicao: autorizacao_acesso_paciente e autorizacao_categoria VAZIAS.
-- Remove SOMENTE triggers/procedures da Etapa 08, se presentes.
-- Nao executa CREATE TABLE, DROP TABLE ou altera registros de pessoas.
USE biohealth;
DROP TRIGGER IF EXISTS trg_autorizacao_before_insert;
DROP TRIGGER IF EXISTS trg_autorizacao_before_update;
DROP TRIGGER IF EXISTS trg_autorizacao_before_delete;
DROP TRIGGER IF EXISTS trg_aut_categoria_before_insert;
DROP TRIGGER IF EXISTS trg_aut_categoria_before_update;
DROP TRIGGER IF EXISTS trg_aut_categoria_before_delete;
DROP TRIGGER IF EXISTS trg_pr_after_update_autorizacao;
DROP PROCEDURE IF EXISTS sp_conceder_acesso_paciente;
DROP PROCEDURE IF EXISTS sp_revogar_acesso_paciente;

DELIMITER $$
CREATE TRIGGER trg_autorizacao_before_insert
BEFORE INSERT ON autorizacao_acesso_paciente FOR EACH ROW
BEGIN
 DECLARE v_fim DATETIME(6);
 DECLARE v_existe BOOLEAN DEFAULT TRUE;
 DECLARE v_admin INT DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_existe = FALSE;
 IF NEW.status <> 'RASCUNHO' OR NEW.encerrada_em IS NOT NULL
    OR NEW.motivo_encerramento IS NOT NULL
    OR NEW.encerrada_por_usuario_id IS NOT NULL
    OR NEW.justificativa_encerramento IS NOT NULL THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Concessao deve iniciar como rascunho';
 END IF;
 SELECT COUNT(*) INTO v_admin FROM usuario u
 JOIN usuario_papel up ON up.usuario_id=u.id
 JOIN papel p ON p.id=up.papel_id
 WHERE u.id=NEW.concedida_por_usuario_id AND u.ativo=TRUE AND p.codigo='ADMIN';
 IF v_admin=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Concessao exige ADMIN ativo';
 END IF;
 SELECT encerrado_em INTO v_fim FROM paciente_responsavel
 WHERE id=NEW.paciente_responsavel_id FOR UPDATE;
 IF NOT v_existe OR v_fim IS NOT NULL THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Vinculo inexistente ou encerrado';
 END IF;
END$$

CREATE TRIGGER trg_autorizacao_before_update
BEFORE UPDATE ON autorizacao_acesso_paciente FOR EACH ROW
BEGIN
 DECLARE v_total INT DEFAULT 0;
 DECLARE v_admin INT DEFAULT 0;
 DECLARE v_fim DATETIME(6);
 IF NEW.id <> OLD.id OR NEW.paciente_responsavel_id <> OLD.paciente_responsavel_id
    OR NEW.concedida_por_usuario_id <> OLD.concedida_por_usuario_id
    OR NOT (NEW.concedida_em <=> OLD.concedida_em) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Dados da concessao imutaveis';
 END IF;
 IF OLD.status='ENCERRADA' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Autorizacao encerrada e imutavel';
 ELSEIF OLD.status='RASCUNHO' THEN
  IF NEW.status <> 'ATIVA' OR NEW.encerrada_em IS NOT NULL
     OR NEW.motivo_encerramento IS NOT NULL
     OR NEW.encerrada_por_usuario_id IS NOT NULL
     OR NEW.justificativa_encerramento IS NOT NULL THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Transicao de rascunho invalida';
  END IF;
  SELECT COUNT(*) INTO v_total FROM autorizacao_categoria WHERE autorizacao_id=OLD.id;
  IF v_total=0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Ao menos uma categoria obrigatoria';
  END IF;
  SELECT encerrado_em INTO v_fim FROM paciente_responsavel
  WHERE id=OLD.paciente_responsavel_id;
  IF v_fim IS NOT NULL THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Vinculo encerrado';
  END IF;
  SELECT COUNT(*) INTO v_admin FROM usuario u
  JOIN usuario_papel up ON up.usuario_id=u.id
  JOIN papel p ON p.id=up.papel_id
  WHERE u.id=OLD.concedida_por_usuario_id AND u.ativo=TRUE AND p.codigo='ADMIN';
  IF v_admin=0 THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Ativacao exige ADMIN ativo';
  END IF;
 ELSEIF OLD.status='ATIVA' THEN
  IF NEW.status <> 'ENCERRADA' THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Autorizacao ativa so pode encerrar';
  END IF;
  IF NEW.motivo_encerramento='REVOGACAO_ADMINISTRATIVA' THEN
   SELECT COUNT(*) INTO v_admin FROM usuario u
   JOIN usuario_papel up ON up.usuario_id=u.id
   JOIN papel p ON p.id=up.papel_id
   WHERE u.id=NEW.encerrada_por_usuario_id AND u.ativo=TRUE AND p.codigo='ADMIN';
   IF v_admin=0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Revogacao exige ADMIN ativo';
   END IF;
  ELSEIF NEW.motivo_encerramento='ENCERRAMENTO_VINCULO' THEN
   SELECT encerrado_em INTO v_fim FROM paciente_responsavel
   WHERE id=OLD.paciente_responsavel_id;
   IF v_fim IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Vinculo ainda ativo';
   END IF;
  ELSE
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Motivo de encerramento invalido';
  END IF;
 END IF;
END$$

CREATE TRIGGER trg_autorizacao_before_delete
BEFORE DELETE ON autorizacao_acesso_paciente FOR EACH ROW
BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Exclusao de autorizacao proibida';
END$$

CREATE TRIGGER trg_aut_categoria_before_insert
BEFORE INSERT ON autorizacao_categoria FOR EACH ROW
BEGIN
 DECLARE v_status VARCHAR(20) DEFAULT NULL;
 DECLARE v_existe BOOLEAN DEFAULT TRUE;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_existe=FALSE;
 SELECT status INTO v_status FROM autorizacao_acesso_paciente
 WHERE id=NEW.autorizacao_id FOR UPDATE;
 IF NOT v_existe OR v_status <> 'RASCUNHO' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Categorias somente no rascunho';
 END IF;
END$$

CREATE TRIGGER trg_aut_categoria_before_update
BEFORE UPDATE ON autorizacao_categoria FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Alteracao de categoria proibida';
END$$

CREATE TRIGGER trg_aut_categoria_before_delete
BEFORE DELETE ON autorizacao_categoria FOR EACH ROW
BEGIN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Exclusao de categoria proibida';
END$$

CREATE TRIGGER trg_pr_after_update_autorizacao
AFTER UPDATE ON paciente_responsavel FOR EACH ROW
BEGIN
 IF OLD.encerrado_em IS NULL AND NEW.encerrado_em IS NOT NULL THEN
  UPDATE autorizacao_acesso_paciente
  SET status='ENCERRADA',
      encerrada_em=GREATEST(CURRENT_TIMESTAMP(6),concedida_em),
      motivo_encerramento='ENCERRAMENTO_VINCULO',
      encerrada_por_usuario_id=NULL,
      justificativa_encerramento=NULL
  WHERE paciente_responsavel_id=NEW.id AND status='ATIVA';
 END IF;
END$$

-- Estas procedures controlam a transacao (COMMIT/ROLLBACK).
-- Nao chama-las dentro de uma transacao externa.
-- No ambiente de aplicacao, restringir DML direto nas tabelas.
CREATE PROCEDURE sp_conceder_acesso_paciente(
 IN p_vinculo_id BIGINT UNSIGNED,
 IN p_admin_usuario_id BIGINT UNSIGNED,
 IN p_categorias JSON,
 OUT p_autorizacao_id BIGINT UNSIGNED
)
BEGIN
 DECLARE v_total INT DEFAULT 0;
 DECLARE v_distintas INT DEFAULT 0;
 DECLARE v_validas INT DEFAULT 0;
 DECLARE v_fim DATETIME(6);
 DECLARE v_existe BOOLEAN DEFAULT TRUE;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_existe=FALSE;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
  ROLLBACK;
  SET p_autorizacao_id=NULL;
  RESIGNAL;
 END;
 SET p_autorizacao_id=NULL;
 IF p_categorias IS NULL OR JSON_TYPE(p_categorias)<>'ARRAY' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Categorias devem ser array JSON';
 END IF;
 SELECT COUNT(*),COUNT(DISTINCT jt.codigo),COUNT(c.id)
 INTO v_total,v_distintas,v_validas
 FROM JSON_TABLE(p_categorias,'$[*]'
  COLUMNS(codigo VARCHAR(40) PATH '$')) jt
 LEFT JOIN categoria_acesso c ON c.codigo=jt.codigo;
 IF v_total=0 OR v_total<>v_distintas OR v_total<>v_validas THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Categorias vazias, repetidas ou invalidas';
 END IF;
 START TRANSACTION;
 SELECT encerrado_em INTO v_fim FROM paciente_responsavel
 WHERE id=p_vinculo_id FOR UPDATE;
 IF NOT v_existe OR v_fim IS NOT NULL THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Vinculo inexistente ou encerrado';
 END IF;
 INSERT INTO autorizacao_acesso_paciente
  (paciente_responsavel_id,concedida_por_usuario_id)
 VALUES (p_vinculo_id,p_admin_usuario_id);
 SET p_autorizacao_id=LAST_INSERT_ID();
 INSERT INTO autorizacao_categoria (autorizacao_id,categoria_id)
 SELECT p_autorizacao_id,c.id
 FROM JSON_TABLE(p_categorias,'$[*]'
  COLUMNS(codigo VARCHAR(40) PATH '$')) jt
 JOIN categoria_acesso c ON c.codigo=jt.codigo;
 UPDATE autorizacao_acesso_paciente SET status='ATIVA'
 WHERE id=p_autorizacao_id;
 COMMIT;
END$$

CREATE PROCEDURE sp_revogar_acesso_paciente(
 IN p_autorizacao_id BIGINT UNSIGNED,
 IN p_admin_usuario_id BIGINT UNSIGNED,
 IN p_justificativa VARCHAR(500)
)
BEGIN
 DECLARE v_vinculo_id BIGINT UNSIGNED;
 DECLARE v_status VARCHAR(20);
 DECLARE v_existe BOOLEAN DEFAULT TRUE;
 DECLARE v_admin INT DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_existe=FALSE;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
  ROLLBACK;
  RESIGNAL;
 END;
 IF p_justificativa IS NULL OR CHAR_LENGTH(TRIM(p_justificativa))=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Justificativa obrigatoria';
 END IF;
 START TRANSACTION;
 SELECT paciente_responsavel_id INTO v_vinculo_id
 FROM autorizacao_acesso_paciente WHERE id=p_autorizacao_id;
 IF NOT v_existe THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Autorizacao inexistente';
 END IF;
 -- Bloqueio na ordem vinculo -> autorizacao.
 SELECT id INTO v_vinculo_id FROM paciente_responsavel
 WHERE id=v_vinculo_id FOR UPDATE;
 SELECT status INTO v_status FROM autorizacao_acesso_paciente
 WHERE id=p_autorizacao_id FOR UPDATE;
 IF v_status<>'ATIVA' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Autorizacao nao esta ativa';
 END IF;
 SELECT COUNT(*) INTO v_admin FROM usuario u
 JOIN usuario_papel up ON up.usuario_id=u.id
 JOIN papel p ON p.id=up.papel_id
 WHERE u.id=p_admin_usuario_id AND u.ativo=TRUE AND p.codigo='ADMIN';
 IF v_admin=0 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Revogacao exige ADMIN ativo';
 END IF;
 UPDATE autorizacao_acesso_paciente
 SET status='ENCERRADA',
     encerrada_em=GREATEST(CURRENT_TIMESTAMP(6),concedida_em),
     motivo_encerramento='REVOGACAO_ADMINISTRATIVA',
     encerrada_por_usuario_id=p_admin_usuario_id,
     justificativa_encerramento=TRIM(p_justificativa)
 WHERE id=p_autorizacao_id;
 COMMIT;
END$$
DELIMITER ;

-- Conferencia dos objetos, sem modifica-los
SELECT TRIGGER_NAME FROM information_schema.TRIGGERS
 WHERE TRIGGER_SCHEMA='biohealth'
 AND (TRIGGER_NAME LIKE 'trg_autorizacao%'
 OR TRIGGER_NAME LIKE 'trg_aut_categoria%'
 OR TRIGGER_NAME='trg_pr_after_update_autorizacao')
 ORDER BY TRIGGER_NAME;
SELECT ROUTINE_NAME FROM information_schema.ROUTINES
 WHERE ROUTINE_SCHEMA='biohealth'
 AND ROUTINE_NAME IN ('sp_conceder_acesso_paciente','sp_revogar_acesso_paciente')
 ORDER BY ROUTINE_NAME;
