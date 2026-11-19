#!/usr/bin/env python3
"""Gera cópias temporárias dos scripts oficiais para validação em schema isolado.

Não conecta ao MySQL, não executa SQL e não modifica scripts versionados.
Uso: python database/tools/preparar_validacao.py
"""
from pathlib import Path
import re
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "scripts"
ORDER = (
    "00_criar_banco.sql",
    "01_pessoa.sql",
    "02_identidade.sql",
    "03_perfis.sql",
    "04_integridade_cpf.sql",
    "05_convenios_especialidades.sql",
    "06_solicitacoes_vinculo.sql",
    "06_ajuste_protecao_historico.sql",
    "07_paciente_responsavel.sql",
    "08_preparacao_papel_admin.sql",
    "08_autorizacao_acesso_paciente.sql",
    "09_agendamentos.sql",
    "10_informacoes_saude.sql",
)
SCHEMA = "biohealth_validacao_integrada"
ALLOWED_SCHEMA = re.compile(r"^biohealth_validacao_[a-z0-9_]+$")


def convert(sql: str) -> str:
    sql, use_count = re.subn(
        r"(?im)^\s*USE\s+biohealth\s*;",
        f"USE {SCHEMA};", sql
    )
    if use_count == 0:
        raise ValueError("Script sem USE biohealth; — revisar manualmente")
    sql = re.sub(
        r"(?i)(CREATE\s+DATABASE\s+IF\s+NOT\s+EXISTS\s+)biohealth\b",
        lambda match: match.group(1) + SCHEMA, sql
    )
    sql = re.sub(
        r"(?i)((?:TRIGGER_SCHEMA|ROUTINE_SCHEMA)\s*=\s*')biohealth(')",
        lambda match: match.group(1) + SCHEMA + match.group(2), sql
    )
    # Bloqueia referências restantes que poderiam selecionar a base principal.
    if re.search(r"(?im)^\s*USE\s+biohealth\s*;", sql):
        raise ValueError("Referência ao schema principal ainda presente")
    return sql


def main() -> int:
    if not ALLOWED_SCHEMA.fullmatch(SCHEMA):
        raise ValueError("Nome de schema de teste inválido")
    missing = [name for name in ORDER if not (SOURCE / name).is_file()]
    if missing:
        raise FileNotFoundError(f"Scripts oficiais ausentes: {missing}")

    output = Path(tempfile.mkdtemp(prefix="biohealth-validacao-"))
    for name in ORDER:
        content = (SOURCE / name).read_text(encoding="utf-8-sig")
        (output / name).write_text(convert(content), encoding="utf-8")
    manifest = output / "ORDEM_EXECUCAO.txt"
    manifest.write_text(
        f"Schema isolado: {SCHEMA}\n"
        "Execute no Workbench em ordem, somente em banco de testes vazio:\n"
        + "\n".join(ORDER) + "\n",
        encoding="utf-8",
    )
    print(f"Scripts temporários preparados em: {output}")
    print(f"Schema de destino: {SCHEMA}")
    print("Nenhum SQL foi executado. NÃO execute os originais para este teste.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
