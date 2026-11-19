-- BioHealth | Etapa 08 | MySQL 8.4
-- Pre-requisitos: etapas 00-07 e papel ADMIN criado.
-- Execute UMA vez em banco sem objetos da Etapa 08.
USE biohealth;

CREATE TABLE categoria_acesso (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 codigo VARCHAR(40) NOT NULL,
 descricao VARCHAR(180) NOT NULL,
 CONSTRAINT pk_categoria_acesso PRIMARY KEY (id),
 CONSTRAINT uq_categoria_codigo UNIQUE (codigo),
 CONSTRAINT chk_categoria_codigo CHECK (CHAR_LENGTH(TRIM(codigo)) > 0),
 CONSTRAINT chk_categoria_descricao CHECK (CHAR_LENGTH(TRIM(descricao)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO categoria_acesso (codigo, descricao) VALUES
 ('DADOS_CADASTRAIS','Consulta de dados cadastrais permitidos'),
 ('AGENDAMENTOS','Consulta de agendamentos permitidos'),
 ('INFORMACOES_SAUDE','Consulta de informacoes de saude autorizadas');

CREATE TABLE autorizacao_acesso_paciente (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 paciente_responsavel_id BIGINT UNSIGNED NOT NULL,
 status VARCHAR(20) NOT NULL DEFAULT 'RASCUNHO',
 concedida_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 concedida_por_usuario_id BIGINT UNSIGNED NOT NULL,
 encerrada_em DATETIME(6) NULL,
 motivo_encerramento VARCHAR(30) NULL,
 encerrada_por_usuario_id BIGINT UNSIGNED NULL,
 justificativa_encerramento VARCHAR(500) NULL,
 vinculo_ativo_id BIGINT UNSIGNED GENERATED ALWAYS AS
  (CASE WHEN status = 'ATIVA' THEN paciente_responsavel_id ELSE NULL END) STORED,
 CONSTRAINT pk_autorizacao_acesso PRIMARY KEY (id),
 CONSTRAINT uq_autorizacao_vinculo_ativo UNIQUE (vinculo_ativo_id),
 INDEX idx_autorizacao_vinculo (paciente_responsavel_id),
 INDEX idx_autorizacao_concedente (concedida_por_usuario_id),
 INDEX idx_autorizacao_encerrador (encerrada_por_usuario_id),
 CONSTRAINT fk_autorizacao_vinculo FOREIGN KEY (paciente_responsavel_id)
  REFERENCES paciente_responsavel(id) ON DELETE RESTRICT,
 CONSTRAINT fk_autorizacao_concedente FOREIGN KEY (concedida_por_usuario_id)
  REFERENCES usuario(id) ON DELETE RESTRICT,
 CONSTRAINT fk_autorizacao_encerrador FOREIGN KEY (encerrada_por_usuario_id)
  REFERENCES usuario(id) ON DELETE RESTRICT,
 CONSTRAINT chk_autorizacao_status CHECK (status IN ('RASCUNHO','ATIVA','ENCERRADA')),
 CONSTRAINT chk_autorizacao_encerramento CHECK (
  (status IN ('RASCUNHO','ATIVA') AND encerrada_em IS NULL
   AND motivo_encerramento IS NULL AND encerrada_por_usuario_id IS NULL
   AND justificativa_encerramento IS NULL)
  OR
  (status = 'ENCERRADA' AND encerrada_em IS NOT NULL
   AND encerrada_em >= concedida_em AND
   ((motivo_encerramento = 'REVOGACAO_ADMINISTRATIVA'
      AND encerrada_por_usuario_id IS NOT NULL
      AND justificativa_encerramento IS NOT NULL
      AND CHAR_LENGTH(TRIM(justificativa_encerramento)) > 0)
    OR
    (motivo_encerramento = 'ENCERRAMENTO_VINCULO'
      AND encerrada_por_usuario_id IS NULL
      AND justificativa_encerramento IS NULL)))
 )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE autorizacao_categoria (
 autorizacao_id BIGINT UNSIGNED NOT NULL,
 categoria_id BIGINT UNSIGNED NOT NULL,
 CONSTRAINT pk_autorizacao_categoria PRIMARY KEY (autorizacao_id,categoria_id),
 CONSTRAINT fk_aut_categoria_autorizacao FOREIGN KEY (autorizacao_id)
  REFERENCES autorizacao_acesso_paciente(id) ON DELETE RESTRICT,
 CONSTRAINT fk_aut_categoria_categoria FOREIGN KEY (categoria_id)
  REFERENCES categoria_acesso(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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