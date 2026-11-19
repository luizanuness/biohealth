# BioHealth — Modelagem aprofundada (Pacote B)

**Estado:** proposta arquitetural para revisão, não implementação. Base: Especificação de Requisitos do Backend v1.0, Dicionário de Dados v1.0, Modelo AS IS/TO BE e SQL oficial `database/scripts/`. Não executar migrações estruturais sem decisão de negócio e validação.

## 1. Matriz de rastreabilidade

| Fonte | Exigência documentada | Estado no SQL | Lacuna |
|---|---|---|---|
| RF-01/RN-01 | Cadastro e e-mail único | `pessoa`, `usuario`, `uq_usuario_email` | Formato e normalização de e-mail no backend |
| RF-02/RN-02/RN-03 | Login e perfis | `usuario`, `papel`, `usuario_papel` | Autenticação, atribuição inicial de papéis e autorização no backend |
| RF-03 | Gerenciar pacientes | `paciente` vinculado a `pessoa` | Contratos e validação de perfil |
| RF-04 | Gerenciar funcionários | `funcionario` | Permissões administrativas no backend |
| RF-05 | Gerenciar profissionais | `profissional_saude`, `profissional_especialidade` | Política de habilitação/agenda |
| RF-06/RN-05 | Agendar sem horários indisponíveis | `agendamento` e unicidade por horário | Disponibilidade e conflitos de intervalos |
| RF-07/RN-06 | Informações de saúde vinculadas ao paciente | `informacao_saude` com FK | Autorização de leitura/escrita |
| Modelo TO BE | Consultar serviços, convênios e especialidades | `convenio` e `especialidade` | Catálogo de serviços não modelado explicitamente |
| Política posterior do projeto | Responsáveis, vínculo e autorização com histórico | `solicitacao_vinculo`, `paciente_responsavel`, `autorizacao_acesso_paciente` | Integração e avaliação de permissões |

**Divergência documental:** o dicionário antigo usa `usuarios`, `pacientes` e tipo único de usuário, enquanto o SQL normaliza `pessoa`, `usuario`, perfis e papéis. Atualizar dicionário, não reverter a normalização.

## 2. Modelo lógico atual (núcleo)

- `pessoa 1 — 0..1 usuario`; `usuario N — N papel` por `usuario_papel`.
- `pessoa 1 — 0..1 paciente / responsavel_legal / funcionario / profissional_saude`; uma pessoa pode acumular perfis.
- `profissional_saude N — N especialidade` por `profissional_especialidade`.
- `paciente N — N convenio` por `paciente_convenio`.
- `paciente 1 — N agendamento`; cada agendamento refere profissional + especialidade habilitada.
- `paciente 1 — N informacao_saude`.
- `solicitacao_vinculo` registra decisões; `paciente_responsavel` registra vínculos aprovados e períodos; `autorizacao_acesso_paciente` e `autorizacao_categoria` registram permissões e histórico.

## 3. Agendamento — evolução proposta

### Lacuna confirmada
A coluna `horario_reservado` e a unique key `(profissional_id, data_consulta, horario_reservado)` impedem duas reservas ativas no mesmo instante, mas não duas consultas que se sobrepõem parcialmente.

### Modelo candidato (pendente de aprovação)
- Preservar `agendamento.id`, FKs e histórico.
- Adicionar `inicio_em` e `fim_em` ou `duracao_minutos` em migração posterior, após definir timezone e regra de duração.
- Modelar **disponibilidade_profissional** (recorrência semanal, horário inicial/final, vigência) e **bloqueio_agenda** (ausências/feriados/exceções) somente se a clínica realmente gerenciar essas regras.
- Uma transação de criação/remarcação deve validar: profissional habilitado para a especialidade, disponibilidade, bloqueios, conflitos, paciente autorizado e estado da consulta.
- Em MySQL, `UNIQUE` não impede intervalos sobrepostos. Para concorrência, bloquear um recurso estável (por exemplo a linha de `profissional_saude` com `SELECT ... FOR UPDATE`) antes de verificar conflitos e inserir, usando uma transação única. Não confiar apenas na verificação prévia no frontend.
- Definir máquina de estados de `AGENDADO`, `CONFIRMADO`, `CANCELADO`, `REALIZADO`; não permitir retorno arbitrário de cancelado ou realizado sem regra explícita.
- Preservar registros cancelados para auditoria; não excluí-los para liberar horários.

### Decisões pendentes
Duração fixa ou variável por serviço? Horários recorrentes ou slots cadastrados? Agendamento direto pelo paciente ou solicitação sujeita a confirmação? Remarcação cria novo registro ou altera registro com trilha de auditoria? Timezone de operação?

## 4. Serviços, especialidades e convênios

A documentação TO BE menciona **serviços**, mas o SQL atual possui `especialidade` e `convenio`, não uma tabela `servico`.

**Proposta condicional:** `servico(id, nome, descricao, ativo)` para catálogo público; relação `servico_especialidade` somente se um serviço puder ser oferecido por múltiplas especialidades; relação `convenio_servico` somente se cobertura contratual fizer parte do escopo. Não introduzir preço, tabela de faturamento, coparticipação ou cobrança sem requisito.

**Pendente:** decidir se consulta é o único serviço agendável ou se procedimentos/exames também são agendáveis. Isso altera diretamente `agendamento`.

## 5. Identidade, perfis e CPF

- Preservar `pessoa` como fonte de identidade; CPF obrigatório para pacientes e responsáveis conforme política definida no projeto.
- `pessoa.cpf` atualmente verifica somente 11 dígitos; dígitos verificadores devem ser validados na aplicação e avaliados no banco.
- Evitar duplicar nome, CPF e e-mail em tabelas de perfil.
- Papéis são autorização, perfis são relacionamentos de domínio: não confundir `papel` com `paciente` ou `funcionario`.
- Planejar tratamento de e-mail case-insensitive/normalização e recuperação de credenciais no backend, sem guardar senhas em texto claro.

## 6. Responsáveis e acesso a informações de saúde

- Preservar histórico de solicitações, vínculos e autorizações; nova aprovação é necessária para novo vínculo.
- A autorização ativa precisa ser avaliada **na consulta ao recurso**, verificando paciente, responsável, vínculo ativo, categoria permitida e usuário autenticado.
- O identificador do usuário passado à procedure não substitui a identidade autenticada; a API deve obter o ator do contexto de segurança, não aceitar IDs administrativos arbitrários do cliente.
- Separar leitura de informações clínicas de permissão para cadastrar/alterar informações; a categoria `INFORMACOES_SAUDE` atual não define sozinha permissão de escrita.
- Considerar LGPD, minimização de dados e auditoria de acessos na implementação; não registrar dados clínicos sensíveis em logs.

## 7. Migrações e compatibilidade

- Manter os 13 scripts acadêmicos como baseline histórica.
- `B01_indices_consulta.sql` é proposta de índices, ainda não executada. Verificar plano de execução e índices já existentes antes de aplicar.
- Novas alterações estruturais serão migrações aditivas; colunas obrigatórias novas precisam de estratégia de backfill para registros existentes.
- Não aplicar scripts `CREATE TABLE` antigos sobre a base já instalada.
- Flyway está planejado, não configurado; ao adotá-lo, definir baseline do schema existente e impedir execução dupla das migrações.
- Fazer backup, instalar em banco isolado, executar migrações, validar dados e fluxos, então planejar implantação. A validação será integrada, conforme estratégia do projeto.

## 8. Sequência de trabalho

1. Confirmar as decisões pendentes sobre agenda e serviços.
2. Criar DDL incremental para as entidades efetivamente necessárias.
3. Atualizar dicionário e diagrama ER conforme o modelo real.
4. Definir regras de transição e autorização para implementação Spring Boot.
5. Executar uma bateria integrada (instalação limpa, migração sobre dados fictícios, concorrência, permissões e regressão).
