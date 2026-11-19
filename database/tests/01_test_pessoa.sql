USE biohealth_validacao_integrada;

START TRANSACTION;

INSERT INTO pessoa (
    nome,
    cpf,
    data_nascimento,
    telefone
)
VALUES (
    'Pessoa Teste A',
    '12345678909',
    '2000-05-15',
    '11999999999'
);

INSERT INTO pessoa (
    nome,
    cpf
)
VALUES (
    'Pessoa Teste B',
    NULL
);

SELECT
    id,
    nome,
    cpf,
    data_nascimento,
    telefone
FROM pessoa
WHERE nome LIKE 'Pessoa Teste%';

ROLLBACK;
