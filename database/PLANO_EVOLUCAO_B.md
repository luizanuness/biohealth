# Pacote B — Evolução da modelagem de dados

## Base analisada

Referência: `database/scripts/00_criar_banco.sql` a `10_informacoes_saude.sql` na branch `main` em 19/11/2026. MySQL 8.4 LTS. Estrutura já instalada com 19 tabelas, conforme verificação anterior no Workbench.

## Estado de implementação

| Área | Banco atual | Aplicação funcional |
| --- | --- | --- |
| Pessoa, usuário e papéis | Tabelas presentes | Backend pendente |
| Paciente, responsável e profissional | Tabelas presentes | Backend pendente |
| Solicitação, vínculo e autorização | Tabelas e triggers presentes | Backend pendente |
| Convênio e especialidade | Tabelas presentes | Integração pendente |
| Agendamento | Tabela com unicidade de horário | Fluxo completo pendente |
| Informações de saúde | Tabela com classificação | Controle de acesso pendente |

## Problemas e decisões de arquitetura

1. **Agenda:** `agendamento` possui `data_consulta` e `horario`, mas não duração, início/fim ou disponibilidade. A unicidade atual só protege horários iguais; não protege intervalos sobrepostos. Não inventar duração padrão. Definir regras de duração, expediente, bloqueios, feriados e remarcação antes da migração estrutural.
2. **Serviços:** `especialidade` não representa necessariamente um serviço comercial ou procedimento. Conferir requisitos de catálogo, preço, duração e cobertura de convênios antes de criar `servico`.
3. **Convênios:** `paciente_convenio` guarda vínculo e carteirinha, mas não histórico temporal. Definir se o projeto exige múltiplos períodos e elegibilidade antes de modificar.
4. **Segurança:** permissões sobre dados clínicos não são garantidas pela simples existência de `autorizacao_acesso_paciente`; precisam de validação transacional no backend.
5. **CPF:** a estrutura atual valida 11 dígitos e obrigatoriedade por perfil, não os dígitos verificadores. Implementar a validação na camada de aplicação e avaliar regra no banco separadamente.
6. **Migrações:** scripts da entrega acadêmica devem permanecer imutáveis. Mudanças futuras devem ser incrementais, sem `DROP DATABASE` ou recriação de tabelas com dados.

## Alteração proposta nesta branch

`database/migrations/B01_indices_consulta.sql`: três índices secundários para consultas de agendamentos, informações de saúde e solicitações de vínculo. Não modifica colunas, chaves existentes ou registros. Ainda não executado em MySQL. **Não aplicar automaticamente à base principal.**

## Plano de execução por conjuntos

- [x] Inspecionar as estruturas de identidade, perfis, convênios, agendamento e saúde.
- [x] Preparar a primeira migração incremental não destrutiva.
- [ ] Revisar integralmente os scripts de autorização e regras de integridade.
- [ ] Confrontar os requisitos acadêmicos com o modelo para definir novas entidades e atributos.
- [ ] Preparar migrações estruturais para agenda e serviços **após decisões de negócio**.
- [ ] Documentar contratos de persistência e permissões para o backend.
- [ ] Executar validação integrada em banco isolado, incluindo índices e migrações.
- [ ] Somente depois da validação, aprovar merge e implantação no banco principal.

## Dependência do Pacote A

O PR #2 foi integrado à `main` contendo somente documentação e inventário (head `8c069644...`). A branch `chore/pacote-a-organizacao` recebeu commits posteriores de limpeza e testes que ainda não constam na `main`. Essas mudanças precisam ser integradas separadamente e validadas; não presumir que o Pacote A inteiro foi concluído.
