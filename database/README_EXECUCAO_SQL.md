# BioHealth — Instalação do banco de dados

## Escopo e ambiente

- SGBD: MySQL Server 8.4 LTS
- Banco de referência: `biohealth`
- Ferramenta manual: MySQL Workbench
- Fonte oficial: `database/scripts/`

**Atenção:** os scripts contêm `USE biohealth;`. Não os execute diretamente em um banco alternativo supondo que o schema selecionado no Workbench será respeitado. A instalação deve ocorrer somente em ambiente apropriado, preferencialmente novo e isolado. Não execute scripts de criação sobre um banco com dados existentes.

## Ordem de instalação em banco novo

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
12. `09_agendamentos.sql`
13. `10_informacoes_saude.sql`

**Não executar na instalação normal:** `08_complemento_autorizacao.sql`. Trata-se de recuperação de instalação parcial antiga, mantida temporariamente para rastreabilidade.

## Estrutura observada

Em 19/11/2026, consultas no MySQL Workbench ao banco `biohealth` retornaram:

| Objeto | Quantidade |
| --- | ---: |
| Tabelas | 19 |
| Triggers | 16 |
| Stored procedures | 2 |

As tabelas `agendamento` e `informacao_saude` também foram confirmadas. Essas verificações **não** substituem teste de instalação do zero nem validação de regras de negócio.

## Testes e preservação de dados

Os arquivos em `database/tests/` são legados de desenvolvimento e estão em reorganização. Alguns contêm `USE biohealth;`; portanto, **não os execute contra a base principal**. Os scripts em `database/tests/setup/` duplicam partes do schema e não devem ser tratados como fonte oficial.

Antes de alterar estrutura em banco com registros: obter backup, elaborar migração incremental e validar em ambiente separado. Não utilizar `DROP DATABASE` nem recriar tabelas da base existente para aplicar mudanças.

## Evolução prevista

Adoção de migrações versionadas com Flyway será considerada quando o backend Spring Boot for iniciado. Até lá, preservar os scripts originais da entrega acadêmica e registrar mudanças posteriores de modo incremental.
