# AUTO-GENERATED FILE. DO NOT EDIT.
# AGENTS.MD: common agent rules for all AI agents.

Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Agent Protocol
- “Make a note” => edit AGENTS.md (shortcut; not a blocker). Ignore `CLAUDE.md`.
- Need upstream file: stage in `/tmp/`, then cherry-pick; never overwrite tracked.
- Bugs: add regression test when it fits.
- Keep files <~500 LOC; split/refactor as needed.
- Commits: Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|style|perf|test`).
- Editor: `antigravity <path>`.
- Prefer end-to-end verify; if blocked, say what’s missing.
- New deps: quick health check (recent releases/commits, adoption).
- Slash cmds: `~/.codex/prompts/`.
- Web: search early; quote exact errors; prefer 2024–2026 sources; fallback Firecrawl (`pnpm mcp:*`) / `mcporter`.
- Style: telegraph. Drop filler/grammar. Min tokens (global AGENTS + replies).
- Questions: `QQ:` or `Question:` prefix => answer only, no code.

## Flow & Runtime
- Use repo’s package manager/runtime; no swaps w/o approval.
- Use Codex background for long jobs; tmux only for interactive/persistent (debugger/server).

## Git
- Safe by default: `git status/diff/log`. Push only when user asks.
- `git checkout` ok for PR review / explicit request.
- Branch changes require user consent.
- Destructive ops (`rm`, `rm -rf`, `reset --hard`, `clean`, `restore`) forbidden unless user explicitly asks in conversation.
- No assumptions: if uncertain, ask before deleting—even if it seems temporary or accidental.
- Remotes under `~/Projects`: prefer HTTPS; flip SSH->HTTPS before pull/push.
- Commit helper on PATH: `committer` (bash). Prefer it; if repo has `./scripts/committer`, use that.
- Don’t delete/rename unexpected stuff; stop + ask.
- No repo-wide S/R scripts; keep edits small/reviewable.
- Avoid manual `git stash`; if Git auto-stashes during pull/rebase, that’s fine (hint, not hard guardrail).
- If user types a command (“pull and push”), that’s consent for that command.
- No amend unless asked.
- Big review: `git --no-pager diff --color=never`.
- Multi-agent: check `git status/diff` before edits; ship small commits.

## Critical Thinking
- Fix root cause (not band-aid).
- Unsure: read more code; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.
- Leave breadcrumb notes in thread.
- Do not blindly assume user is right. Challenge assumptions

<frontend_aesthetics>
Avoid “AI slop” UI. Be opinionated + distinctive.

Do:
- Typography: pick a real font; avoid Inter/Roboto/Arial/system defaults.
- Theme: commit to a palette; use CSS vars; bold accents > timid gradients.
- Motion: 1–2 high-impact moments (staggered reveal beats random micro-anim).
- Background: add depth (gradients/patterns), not flat default.

Avoid: purple-on-white clichés, generic component grids, predictable layouts.
</frontend_aesthetics>

---
Inspired by <https://github.com/steipete/agent-scripts/tree/main>

## Commands & Tooling
- Prioritize `make` commands over direct script execution (e.g., `make setup` instead of `./scripts/install.sh`).
- Available `make` commands:
  - `make setup`: Full installation (symlinks + bootstrap configs).
  - `make build`: Compile templates into agent configs.
  - `make sync`: Sync Gemini configs from ~/.gemini back to repo.
  - `make lint`: Run secret scanning (gitleaks).
  - `make clean`: Remove generated artifacts.
