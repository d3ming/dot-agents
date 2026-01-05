# dot-agents consolidation plan

Goal: one public-safe repo; Stow-managed; shared `AGENTS.md`/workflow; minimal breakage.

Constraints
- No secrets in git (ever); assume config dirs contain runtime/auth junk
- Non-destructive migration; prefer copy + diff; no blind `sudo chown -R …`
- Existing tracked files: never overwrite; stage in `/tmp/` then cherry-pick
- Stow first as dry-run; real run only after diff/confirm
- OK to move whole config dirs to `~/projects/` for safety/backup, but keep backups outside repo working tree (avoid accidental commits)

Scope (initial)
- Claude: `settings.json`, `commands/`
- Codex: `prompts/`, `skills/`, `rules/` (audit for secrets before commit)
- Gemini: `settings.json`, `commands/`
- Shared: `shared/AGENTS.md` (source-of-truth)
- Explicitly exclude: auth / oauth creds / tokens / account ids / histories / session logs

Target layout (Option B: full dirs + gitignore)
```
dot-agents/
  archive/              # gitignored; full backups before migration
  scripts/              # migration/install scripts
  shared/AGENTS.md      # source of truth
  claude/.claude/       # full dir; runtime gitignored
  codex/.codex/         # full dir; runtime gitignored
  gemini/.gemini/       # full dir; runtime gitignored
  .gitignore            # strict: deny runtime/secrets
```

Expected end state (home symlinks)
```
~/.claude  -> dot-agents/claude/.claude
~/.codex   -> dot-agents/codex/.codex
~/.gemini  -> dot-agents/gemini/.gemini

# Shared doc symlinks (inside each dir after Stow)
claude/.claude/CLAUDE.md  -> ../../shared/AGENTS.md
codex/.codex/AGENTS.md    -> ../../shared/AGENTS.md
gemini/.gemini/GEMINI.md  -> ../../shared/AGENTS.md
```

Milestones / steps
1) Preflight inventory
   - list current files/dirs, symlinks, and `.git` presence in `~/.claude`, `~/.codex`, `~/.gemini`
   - identify candidate “trackable” vs “runtime/secret” paths (explicit allowlist above)
   - confirm repo root path (this repo currently at `~/projects/dot-agents`)
   - decide backup location (suggest `~/projects/dot-agents-archive/YYYYMMDD-HHMMSS/`)

2) Repo hygiene
   - strict `.gitignore` (secrets + runtime)
   - add “denylist reminders” to README later (plan only; implement later)

3) Migration (non-destructive; no overwrites)
   - optional: move whole existing dirs to archive first (e.g. `~/.codex` -> `~/projects/dot-agents-archive/.../.codex/`) for “nothing lost” guarantee
   - stage copies into `/tmp/dot-agents-stage/` from archive or from current home dirs (exclude `.git`, exclude secret/runtime paths)
   - diff staged -> repo working tree; cherry-pick changes file-by-file into repo
   - quick secret scan: `rg` for obvious patterns (tokens/keys) + manual spot-check

4) Stow dry-run + conflict resolution
   - run `stow -n -v -t ~ {claude,codex,gemini}`; inspect conflicts
   - decide per conflict: back up, delete, or keep (prefer back up)

5) Install/rollback strategy (define before execution)
   - `install.sh` design: create parent dirs, back up non-symlinks, remove old symlinks, then stow, then link shared docs
   - rollback: `stow -D …` + restore backups (no `rm -rf` steps unless explicit later)

6) Verification checklist (post-install)
   - `readlink`/`ls -la` for each target symlink
   - basic tool smoke: start each CLI; confirm settings/commands picked up (manual step)

Release gates (don’t skip)
- Gate A: local E2E works (no GitHub yet)
- Gate B: secret audit clean (then consider local commit)
- Gate C: publish to GitHub only after explicit review

Publishing (later; optional)
- Prefer HTTPS remotes under `~/projects` (avoid SSH flip-flop)
- GitHub creation via `gh` only after secret audit passes

References
- GNU Stow manual: https://www.gnu.org/software/stow/
- Dotfiles overview: https://dotfiles.github.io/

---

## Preflight Inventory (2026-01-05) ✅

### Current State Summary

| Dir | `.git`? | Existing Symlinks | Notes |
|-----|---------|-------------------|-------|
| `~/.claude` | ✅ | `CLAUDE.md` → `~/.codex/AGENTS.md` | Already unified |
| `~/.codex`  | ✅ | None | Source of truth for `AGENTS.md` |
| `~/.gemini` | ✅ | `GEMINI.md` → `~/.codex/AGENTS.md` | Already unified |

**Key Finding**: Shared `AGENTS.md` already exists at `~/.codex/AGENTS.md` with symlinks from Claude and Gemini. Consolidation partially done!

### Trackable Files (to migrate)

**Claude (`~/.claude/`)**
- `settings.json` (303 bytes)
- `commands/gh/review-pr.md`

**Codex (`~/.codex/`)**
- `AGENTS.md` (2899 bytes) — source of truth
- `prompts/` — 7 files (deep-reflector, github-issue-fixer, github-pr-reviewer, insight-documenter, instruction-reflector, prompt-creator, ui-engineer)
- `rules/default.rules` (empty)
- `skills/lint/SKILL.md`
- `skills/public/regression-analysis/`
- `skills/.system/` — **exclude** (system-managed)

**Gemini (`~/.gemini/`)**
- `settings.json` (951 bytes)
- `commands/reflect.toml`

### Runtime/Secret Files (exclude)

| Path | Reason |
|------|--------|
| `~/.claude/projects/`, `statsig/`, `plugins/`, `debug/` | Session/runtime |
| `~/.codex/sessions/`, `shell_snapshots/`, `internal_storage.json`, `version.json` | Runtime |
| `~/.gemini/oauth_creds.json` | **SECRET** |
| `~/.gemini/google_accounts.json`, `installation_id`, `state.json` | Account/runtime |
| `~/.gemini/history/`, `antigravity-browser-profile/`, `extensions/` | Runtime/third-party |

### Decisions

1. **Existing `.git` repos**: Each dir has own `.git`. Remove after backup → single source of truth here.
2. **`.system` skills**: Exclude (Codex-managed).
3. **Third-party extensions**: Exclude `~/.gemini/extensions/`.
