# AGENTS.MD: common agent rules for all AI agents.

Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Tenets: ALWAYS APPLY
- Do not assume you are given a coding task, before jumping in, determine mode of operation (see MOO):
- Do it right. No quick fixes unless explicitly asked. Prioritize long term maintainability.
- Clarify: STOP + ASK for clarification!
- Avoid hard data loss: NEVER cause irreversible damage to our repo (see below)

## MOO: Modes of Operation
- FAQ (qq,qna,faq): You can inspect code and run certain read-only tool calls but you cannot write code. Only answer questions. Write answers in new `ai/faq/` markdown file at end of session (when asked to write FAQ)
- Plan (brainstorm,interactive): Clarify plan via interactions before writing a plan via `task-planning` skill.
- BEAST (owner,unleash): E2E Ownership. You utilize the `beast_mode` skill to execute complex goals autonomously. Do not get blocked; utilize infinite resourcefulness. **Requirement**: Follow `ai/skills/beast_mode/SKILL.md` (Log, Loop, Fix).
- Code (fix): Only do this if no other mode fits. Assume you are in either FAQ or PLAN mode before doing this.

## Agent Protocol
- Workspace: `~/projects`.
- Screenshots in `~/Desktop`, if I ask you to refer to screenshot find the latest `Screenshot**.png` file.
- Shared skills directory: `~/projects/dot-agents/master/skills/`.
- **Skill resources**: Skills may include scripts, assets, or other files. To locate skill resources:
  - Skills are symlinked: `~/.codex/skills/`, `~/.claude/skills/`, `~/.gemini/skills/` → `master/skills/`
  - Find a skill resource: `find ~/.codex ~/.claude ~/.gemini -path "*/<skill-name>/<resource-path>" 2>/dev/null | head -1`
  - Example: `find ~/.codex ~/.claude ~/.gemini -path "*/gh-address-comments/scripts/fetch_comments.py" 2>/dev/null | head -1`
  - Never use relative paths like `scripts/file.py` - always resolve the full path first
- Need upstream file: stage in `/tmp/`, then cherry-pick; never overwrite tracked.
- Bugs: add regression test when it fits.
- Keep files <~500 LOC; split/refactor as needed.
- Commits: Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|style|perf|test`).
- Prefer end-to-end verify; if blocked, say what’s missing.
- New deps: quick health check (recent releases/commits, adoption).
- Slash cmds: `~/.codex/prompts/`.
- Web: search early; quote exact errors; prefer 2024–2026 sources; fallback Firecrawl (`pnpm mcp:*`) / `mcporter`.
- Write handoff msg at the end of every session, needs to have enough context for new hire to pick up where you left off.

## Git
- Safe by default: `git status/diff/log`. Push only when user asks.
- `git checkout` ok for PR review / explicit request.
- Branch changes require user consent.
- Destructive ops (`rm`, `rm -rf`, `reset --hard`, `clean`, `restore`) forbidden unless user explicitly asks in conversation.
- No assumptions: if uncertain, ask before deleting—even if it seems temporary or accidental.
- Remotes under `~/Projects`: prefer HTTPS; flip SSH->HTTPS before pull/push.
- Don’t delete/rename unexpected stuff; stop + ask.
- No repo-wide S/R scripts; keep edits small/reviewable.
- Avoid manual `git stash`; if Git auto-stashes during pull/rebase, that’s fine (hint, not hard guardrail).
- If user types a command (“pull and push”), that’s consent for that command.
- No amend unless asked.
- Big review: `git --no-pager diff --color=never`.
- Multi-agent: check `git status/diff` before edits; ship small commits.

## PR Feedback
- Active PR: `gh pr view --json number,title,url --jq '"PR #\\(.number): \\(.title)\\n\\(.url)"'`.
- PR comments: `gh pr view …` + `gh api …/comments --paginate`.
- Replies: cite fix + file/line; resolve threads only after fix lands.
- When merging a PR: thank the contributor in `CHANGELOG.md`.

## Critical Thinking
- Fix root cause (not band-aid).
- Unsure: read more code; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.
- Leave breadcrumb notes in thread.
- Do not blindly assume user is right. Challenge assumptions

---
Inspired by <https://github.com/steipete/agent-scripts/tree/main>
