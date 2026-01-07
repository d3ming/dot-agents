## Gemini session bootstrap (run `init-gemini`)
- This repo uses `master/AGENTS.md` as the single protocol source of truth.
- Do not edit `~/.gemini/GEMINI.md`; it is a symlink to `master/AGENTS.md`.
- Gemini-specific guidance should live in this file and be loaded via the `init-gemini` command.

## Working with this repo
- Prefer `make build` over running scripts directly.
- After changes to `gemini/templates/`, run `make build`, then `make setup`.
- If instructions need updates, edit `master/AGENTS.md` (shared) or this file (Gemini-only).
