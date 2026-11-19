-- BioHealth: verificações não destrutivas de integridade de CPF.
-- Executar SOMENTE no schema isolado após instalar os scripts oficiais.
USE biohealth_validacao_integrada;

-- Deve retornar zero: CPF ausente em paciente.
SELECT 'paciente_sem_cpf' AS verificacao, COUNT(*) AS inconsistencias
FROM paciente pa
JOIN pessoa pe ON pe.id = pa.pessoa_id
WHERE pe.cpf IS NULL
UNION ALL
-- Deve retornar zero: CPF ausente em responsável.
SELECT 'responsavel_sem_cpf', COUNT(*)
FROM responsavel_legal rl
JOIN pessoa pe ON pe.id = rl.pessoa_id
WHERE pe.cpf IS NULL
UNION ALL
-- Deve retornar zero: CPF fora do formato.
SELECT 'cpf_formato_invalido', COUNT(*)
FROM pessoa
WHERE cpf IS NOT NULL AND NOT REGEXP_LIKE(cpf, '^[0-9]{11}$');

-- Deve retornar 5: triggers de CPF presentes.
SELECT COUNT(*) AS triggers_cpf
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'biohealth_validacao_integrada'
  AND TRIGGER_NAME IN (
    'trg_paciente_cpf_insert',
    'trg_paciente_cpf_update',
    'trg_responsavel_cpf_insert',
    'trg_responsavel_cpf_update',
    'trg_pessoa_cpf_update'
  );
-- Observação: este teste não comprova cálculo de dígitos verificadores.
