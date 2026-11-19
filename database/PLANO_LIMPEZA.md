# Pacote A — Inventário e plano de limpeza

## Fonte de verdade

- `database/scripts/00_criar_banco.sql` a `10_informacoes_saude.sql`: scripts oficiais da estrutura entregue.
- `database/scripts/08_complemento_autorizacao.sql`: recuperação histórica; **não executar** em instalação nova.
- `database/tests/setup/*_teste.sql`: cópias do DDL oficial com outro nome de banco; duplicação técnica, **candidatas a remoção depois que houver instalação de teste automatizada**.
- `database/tests/setup/*dados_teste.sql`: fixtures, manter até substituição por conjunto controlado.
- `database/tests/*test*.sql`: testes heterogêneos; alguns apontam para `biohealth` e não são seguros para execução indiscriminada.

## Problemas confirmados

1. README principal desatualizado sobre a Etapa 08 e sem os módulos 09/10.
2. README de execução com contagens anteriores (16 tabelas, 17 triggers) e ordem incompleta.
3. Scripts de testes que apontam para o banco principal.
4. DDL de teste duplicado, com risco de divergência da fonte oficial.
5. `database/tests/04_test_integridade_cpf.sql` é somente um marcador de pendência.
6. Scripts de recuperação misturados com scripts normais.

## Política de mudanças

- Não apagar, truncar nem recriar bancos existentes.
- Não alterar retroativamente os scripts acadêmicos sem plano de migração.
- Nenhuma exclusão de arquivo sem identificar substituto e verificar referências.
- Novos testes devem usar schema isolado e não modificar `biohealth`.
- Agrupar alterações e executar uma validação integrada antes do merge.
- Backend Spring Boot e Flyway ainda não estão implementados.

## Próximas tarefas do Pacote A

- [ ] Definir um instalador de testes que reutilize os scripts oficiais sem editar a origem.
- [ ] Migrar os testes legados para execução isolada e repetível.
- [ ] Substituir o marcador de CPF por testes de integridade reais.
- [ ] Remover as cópias de DDL de `database/tests/setup/` **após** disponibilizar substituto.
- [ ] Retirar `08_complemento_autorizacao.sql` do fluxo principal, preservando histórico Git.
- [ ] Revisar referências do frontend antes de remover assets ou páginas.
- [ ] Executar validação integrada do Pacote A e abrir caminho para migrações.

## Estado

Documentação e inventário preparados na branch `chore/pacote-a-organizacao`. Nenhum dado do MySQL foi modificado.
