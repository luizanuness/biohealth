-- BioHealth Etapa 08 - Complemento para banco com 3 tabelas existentes
-- Executar uma vez, somente apos diagnostico de ausencia de triggers e procedures.
-- Nao recria tabelas nem reinsere categorias.
USE biohealth;

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
BEGIN