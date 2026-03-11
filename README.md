# tlex-global

Globální projektový template pro Claude Code na webu.

## Co obsahuje

- **SessionStart hook** — při každém otevření session automaticky stáhne aktuální `CLAUDE.md` z [`claude-global-config`](https://github.com/tlex4891-tlex/claude-global-config) do `~/.claude/CLAUDE.md`
- **CLAUDE.md** — odkaz na globální konfiguraci

## Jak funguje

1. Otevřeš tento repozitář (nebo nový projekt zkopírovaný z tohoto) v Claude Code web app
2. SessionStart hook se automaticky spustí
3. Stáhne nejnovější `CLAUDE.md` z `claude-global-config`
4. Claude ho přečte a bude pracovat podle tvých globálních instrukcí

## Úprava globálních instrukcí

Edituj `CLAUDE.md` v repozitáři [claude-global-config](https://github.com/tlex4891-tlex/claude-global-config) — změny se projeví při další session automaticky.
