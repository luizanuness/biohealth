# BioHealth

Aplicação web acadêmica de gestão de clínica de saúde, desenvolvida no projeto de extensão da Universidade de Sorocaba (UNISO).

## Estado atual

- **Frontend existente:** HTML5, CSS3, JavaScript e Bootstrap, com páginas estáticas em `index.html`, `navegacao/` e `paciente/`.
- **Banco de dados implementado:** MySQL 8.4 LTS; 19 tabelas, 16 triggers e 2 stored procedures confirmadas no ambiente `biohealth` em 19/11/2026.
- **Backend planejado:** Java, Spring Boot, Spring Data JPA, APIs REST e Spring Security. Ainda não implementado.
- **Integração frontend/backend:** pendente.
- **Testes:** há scripts SQL de desenvolvimento; a instalação integral a partir de um banco vazio e a regressão completa ainda precisam de validação.

A existência de uma tabela SQL não significa que o fluxo correspondente esteja funcional na aplicação.

## Estrutura

```text
assets/                 Estilos e imagens do frontend
fragments/              Fragmentos HTML compartilhados
navegacao/              Páginas públicas
paciente/               Páginas da área do paciente
database/scripts/       Scripts SQL oficiais de instalação
database/tests/         Testes e fixtures legados (em reorganização)
database/README_EXECUCAO_SQL.md   Ordem e cuidados de instalação
index.html              Página inicial
```

## Banco de dados

Consulte [as instruções de execução](database/README_EXECUCAO_SQL.md). Os 13 scripts de instalação das etapas 00–10 são a referência atual do schema. O arquivo `08_complemento_autorizacao.sql` é **legado de recuperação** e não faz parte da instalação normal.

**Segurança:** não execute scripts de testes ou instalação sobre um banco com dados sem avaliar previamente seu efeito. Preserve os bancos existentes; faça testes de instalação em schema isolado.

## Próximas frentes

1. Organizar scripts, testes e documentação sem perda de histórico ou dados.
2. Revisar a modelagem de agenda, integridade, serviços e permissões com base nos requisitos.
3. Implementar o backend Spring Boot e integrar o frontend existente.
4. Executar testes integrados e documentar a implantação.

## Projeto

Repositório: https://github.com/luizanuness/biohealth

Projeto acadêmico individual, iniciado em 2026.
