# BioHealth — Execução da estrutura do banco de dados

## 1. Objetivo

Documentar a instalação da estrutura relacional do banco de dados BioHealth, desenvolvido como parte do projeto acadêmico de extensão da Universidade de Sorocaba (UNISO).

## 2. Ambiente

- SGBD: MySQL Server 8.4 LTS
- Ferramenta de execução: MySQL Workbench
- Banco de dados: `biohealth`
- Localização dos scripts: `database/scripts/`

## 3. Ordem de execução

Executar os arquivos SQL na seguinte sequência:

1. `00_criar_banco.sql`
2. `01_pessoa.sql`
3. `02_identidade.sql`
4. `03_perfis.sql`
5. `04_integridade_cpf.sql`
6. `05_convenios_especialidades.sql`
7. `06_solicitacoes_vinculo.sql`
8. `06_ajuste_protecao_historico.sql`
9. `07_paciente_responsavel.sql`
10. `08_preparacao_papel_admin.sql`
11. `08_autorizacao_acesso_paciente.sql`

A execução deve ocorrer em um banco novo, respeitando a ordem apresentada.

O arquivo `08_complemento_autorizacao.sql` é destinado à recuperação de instalações parciais e não faz parte da sequência de instalação inicial.

## 4. Verificação da estrutura

Após executar os scripts, utilizar as consultas:

```sql
SELECT COUNT(*) AS total_tabelas
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'biohealth'
AND TABLE_TYPE = 'BASE TABLE';

SELECT COUNT(*) AS total_triggers
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'biohealth';

SELECT COUNT(*) AS total_procedures
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'biohealth'
AND ROUTINE_TYPE = 'PROCEDURE';
```

Resultado esperado:

| Objeto            | Quantidade |
| ----------------- | ---------: |
| Tabelas           |         16 |
| Triggers          |         17 |
| Stored procedures |          2 |

## 5. Observações

Os arquivos em `database/tests/` são destinados exclusivamente à validação da estrutura e de suas regras de integridade.

A instalação inicial não exige a criação de pacientes, responsáveis ou usuários fictícios.

O backend Java/Spring Boot e a integração com o frontend estão previstos para etapas posteriores do projeto.

## 6. Estado da validação

Os scripts das Etapas 01–08 foram instalados no ambiente de testes durante o desenvolvimento. A validação integral da sequência oficial em um banco novo permanece necessária antes da entrega definitiva.
