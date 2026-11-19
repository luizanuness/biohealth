# Testes SQL — ambiente isolado

## Regra de segurança

**Nunca executar os testes em `biohealth`.** Todos os arquivos de teste ativos foram direcionados para `biohealth_validacao_integrada`. O gerador `database/tools/preparar_validacao.py` apenas prepara scripts temporários; não conecta ao MySQL.

## Preparação

1. Em um ambiente com Python 3, executar `python database/tools/preparar_validacao.py` na raiz do repositório.
2. Executar os 13 scripts temporários gerados, em ordem, **em uma instalação de testes vazia**. Os scripts contêm comandos DDL e não são idempotentes.
3. Executar os testes de leitura (`04_test_integridade_cpf.sql` e `08_test_autorizacao_acesso_paciente.sql`) no schema de teste.
4. Os testes `01`, `05`, `06` e `07` são **roteiros manuais legados**, não uma suíte automática: os cenários de falha esperada devem ser executados individualmente e depois revertidos com `ROLLBACK`. Não executar o arquivo inteiro de uma vez.
5. As fixtures `setup/09` a `setup/12` são opcionais e dependem de execução em ordem **na mesma conexão**, pois utilizam variáveis de sessão. Inserem dados fictícios persistentes no schema de teste; não executar em produção.

## Limitações

- A suíte integrada e os testes de concorrência ainda não foram executados.
- Os testes legados com falha esperada não são adequados para CI sem adaptação.
- Não há teste de dígitos verificadores de CPF implementado.
- A limpeza do banco de testes deve ser feita apenas após confirmar que ele não contém dados reais; não há comandos automáticos de exclusão de bancos.
