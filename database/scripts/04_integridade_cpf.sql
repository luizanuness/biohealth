USE biohealth;

DELIMITER $$


CREATE TRIGGER trg_paciente_cpf_insert
BEFORE INSERT ON paciente
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pessoa
        WHERE id = NEW.pessoa_id
          AND cpf IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Paciente exige pessoa com CPF';
    END IF;
END$$



CREATE TRIGGER trg_paciente_cpf_update
BEFORE UPDATE ON paciente
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pessoa
        WHERE id = NEW.pessoa_id
          AND cpf IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Paciente exige pessoa com CPF';
    END IF;
END$$



CREATE TRIGGER trg_responsavel_cpf_insert
BEFORE INSERT ON responsavel_legal
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pessoa
        WHERE id = NEW.pessoa_id
          AND cpf IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Responsavel exige pessoa com CPF';
    END IF;
END$$



CREATE TRIGGER trg_responsavel_cpf_update
BEFORE UPDATE ON responsavel_legal
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pessoa
        WHERE id = NEW.pessoa_id
          AND cpf IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Responsavel exige pessoa com CPF';
    END IF;
END$$



CREATE TRIGGER trg_pessoa_cpf_update
BEFORE UPDATE ON pessoa
FOR EACH ROW
BEGIN
    IF NEW.cpf IS NULL
       AND (
           EXISTS (
               SELECT 1
               FROM paciente
               WHERE pessoa_id = OLD.id
           )
           OR EXISTS (
               SELECT 1
               FROM responsavel_legal
               WHERE pessoa_id = OLD.id
           )
       )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'CPF obrigatorio para perfil existente';
    END IF;
END$$

DELIMITER ;
