# 🩺 BioHealth

BioHealth é um projeto web voltado para a área da saúde, desenvolvido com foco em organização, usabilidade e experiência do usuário.

## 📂 Estrutura do Projeto

```bash
biohealth/
├── assets/       # Imagens, ícones e arquivos estáticos
├── fragments/    # Componentes reutilizáveis
├── navegacao/    # Páginas de navegação
├── paciente/     # Funcionalidades relacionadas ao paciente
└── index.html    # Página inicial
```

## 🚀 Tecnologias Utilizadas

- HTML5
- CSS3
- JavaScript
- Git e GitHub

## 🎯 Objetivo

Desenvolver uma plataforma web para centralizar informações da área da saúde por meio de uma interface intuitiva e organizada.


## 🔨 Próximas Implementações

- Integração com back-end
- Cadastro de usuários
- Gerenciamento de pacientes
- Dashboard com informações de saúde
- Responsividade aprimorada

## 👩‍💻 Desenvolvedora

Luiza Nunes

GitHub: https://github.com/luizanuness/biohealth

Trello: https://trello.com/invite/b/6a3b1bd423d6c23ae43ad140/ATTIaa5789161158321df375f0e3c179c4e4D51DCBA9/biohealth

---

Projeto desenvolvido para fins acadêmicos e aprendizado.


## 🗄️ Banco de dados — MySQL 8.4

Os scripts SQL estão em `database/scripts/` e os testes em `database/tests/`.
O backend Java/Spring Boot continua **planejado**, não implementado.

Ordem para criar um banco **novo**:
1. `00_criar_banco.sql` até `07_paciente_responsavel.sql`, respeitando a ordem numérica e os ajustes da etapa 06.
2. `08_preparacao_papel_admin.sql`.
3. `08_autorizacao_acesso_paciente.sql` **somente em banco sem tabelas da Etapa 08**.

Recuperação de desenvolvimento: `08_complemento_autorizacao.sql` é
destinado exclusivamente ao ambiente em que as três tabelas da Etapa 08
já existem, e os registros de `autorizacao_acesso_paciente` e
`autorizacao_categoria` estão vazios. O complemento recria somente
triggers e procedures da Etapa 08: **não** execute os dois scripts 08
de instalação/complemento em sequência.

**Estado:** as etapas anteriores possuem scripts e testes no repositório.
A Etapa 08 está em correção e precisa de validação funcional no MySQL
Workbench antes de ser marcada como concluída. O arquivo
`database/tests/04_test_integridade_cpf.sql` ainda necessita de
restauração dos testes. O modelo de papéis e SQL não substitui
autenticação e privilégios mínimos no futuro backend.
