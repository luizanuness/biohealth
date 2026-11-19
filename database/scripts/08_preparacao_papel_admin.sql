USE biohealth;


INSERT INTO papel (codigo, descricao)
SELECT
    'ADMIN',
    'Administrador do sistema BioHealth'
WHERE NOT EXISTS (
    SELECT 1
    FROM papel
    WHERE codigo = 'ADMIN'
);


SELECT
    id,
    codigo,
    descricao
FROM papel
WHERE codigo = 'ADMIN';
