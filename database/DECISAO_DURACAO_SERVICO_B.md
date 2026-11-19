# Pacote B — Decisão de duração por serviço

**Decisão confirmada em 19/11/2026:** duração configurável por serviço. Os scripts acadêmicos originais permanecem inalterados.

## Modelo incremental proposto

```text
especialidade (1) ─── (N) servico
servico       (1) ─── (N) agendamento
especialidade (1) ─── (N) agendamento
profissional_saude (1) ─── (N) agendamento
```

- `servico`: catálogo com `nome`, `descricao`, `ativo`, `especialidade_id` e `duracao_minutos` obrigatória, de 1 a 1440 minutos.
- `agendamento.servico_id`: FK composta com `especialidade_id`, garantindo que serviço e especialidade sejam compatíveis.
- `agendamento.duracao_minutos`: snapshot da duração escolhida no momento da reserva. A mudança de duração no catálogo **não altera** consultas já agendadas.
- As duas colunas novas em `agendamento` são **nullable por compatibilidade** com os registros anteriores; a restrição exige ambas nulas ou ambas preenchidas.
- O backend deverá exigir serviço e duração para **novos** agendamentos, validando duração igual à configuração vigente do serviço no momento da criação. Não aceitar duração arbitrária enviada pelo cliente.
- O agendamento continua ligado a um profissional habilitado na especialidade pela FK já existente.

## Justificativa das escolhas

O modelo inicial associa cada serviço a uma especialidade, evitando uma tabela associativa desnecessária. **Hipótese de modelagem ainda pendente de validação de negócio**: um serviço não é compartilhado entre especialidades. Se o requisito futuro exigir serviço transversal, será necessário revisar essa cardinalidade antes de aplicar B02.

A migração B02 não cria dados fictícios, não exclui registros e não tenta inferir serviço/duração de agendamentos históricos. As novas colunas opcionais são um compromisso explícito para migração segura; a integridade obrigatória dos novos registros ficará na API até que todos os legados possam ser regularizados e a restrição endurecida.

## Regras de agendamento a implementar no backend

1. Selecionar serviço ativo e profissional habilitado na especialidade do serviço.
2. Ler `duracao_minutos` do catálogo dentro da transação e gravar o snapshot.
3. Calcular intervalo semiaberto `[inicio, fim)`, impedindo sobreposição quando `novo_inicio < fim_existente AND inicio_existente < novo_fim`. Consultas canceladas não ocupam horário.
4. Bloquear a linha do profissional com `SELECT ... FOR UPDATE` **antes** de consultar conflitos e inserir; todas as operações de criação/remarcação devem obedecer ao mesmo protocolo de lock. Garantir isolamento e leitura atualizada para evitar snapshots antigos.
5. Não permitir consulta ultrapassando o dia/expediente sem regra explícita.
6. Manter a unique key atual de início por profissional/data como proteção adicional, não como substituto do bloqueio de intervalos.
7. Não alterar serviço/duração de uma reserva existente sem regra explícita de remarcação.
8. Não apagar agendamentos cancelados.

**Limite importante:** enquanto existirem agendamentos legados sem duração, não é possível provar ausência de sobreposição com eles. Antes de habilitar reservas reais, regularizar os registros existentes ou bloquear reservas nas agendas/datas afetadas. Não preencher durações automaticamente.

## Migração B02

Arquivo: `database/migrations/B02_servicos_duracao_agendamentos.sql`.

- Aditiva, sem `DROP`, `DELETE` ou `UPDATE` de registros.
- Requer MySQL 8.4 e schema das etapas 00–10.
- Não foi aplicada ou testada em MySQL.
- Não é idempotente: executar uma vez, com backup e em homologação antes da produção.
- MySQL DDL causa commits implícitos: uma falha intermediária exige inspeção do estado antes de retentar, não confiar em `ROLLBACK`.

## Decisões ainda abertas

- Catálogo apenas de consultas ou também procedimentos e exames?
- Horário de funcionamento e exceções da clínica; disponibilidade individual dos profissionais.
- Timezone de operação e atendimento que atravessa meia-noite.
- Regras de remarcação, cancelamento e confirmação.
- Tratamento de consultas históricas sem serviço/duração.
- Eventual cobertura de serviços por convênio.

## Testes integrados previstos

- Migração B01 e B02 sobre schema com dados existentes.
- FK serviço/especialidade incompatível deve falhar.
- Duração zero ou superior a 1440 deve falhar.
- Serviço sem duração deve falhar.
- Legados devem permanecer intactos e com novas colunas nulas.
- Concorrência de agendamentos sobrepostos no backend, inclusive início diferente.
- Alteração de duração do serviço não deve modificar o snapshot dos agendamentos.
