---
name: skill-author
description: Create or update Codex/Claude skills with a shared SKILL.md source of truth; use when asked to add a new skill, refine a skill, or set up shared skill scaffolding.
---

# Skill Author

## Inputs
- Skill intent, example triggers, and any needed resources (scripts, references, assets).
- Optional: target agent(s) and desired name.

## Workflow
1. Define skill name and triggers
   - Use lowercase letters, digits, hyphens; keep under 64 chars.
   - Ensure description captures when to use the skill (primary trigger signal).
2. Create shared skill folder
   - Path: `master/skills/<skill-name>/SKILL.md`
   - Frontmatter: only `name` and `description`.
3. Write SKILL.md body
   - Imperative voice.
   - Keep concise; avoid duplicate docs.
   - Include guardrails and failure cases.
4. Add resources if needed
   - `scripts/`, `references/`, `assets/` under the same folder.
5. Wire into agents
   - Codex: symlink `codex/.codex/skills/<skill-name>` -> `master/skills/<skill-name>`
   - Claude: symlink `claude/.claude/skills/<skill-name>` -> `master/skills/<skill-name>`
6. Optionally add Gemini wrapper
   - `.gemini/commands/<skill-name>.toml` with `@{master/skills/<skill-name>/SKILL.md}`
7. Sanity check
   - Confirm symlinks and that SKILL.md stays under ~500 lines.

## Guardrails
- Do not add extra docs (README, changelog).
- Avoid long examples; move detail into `references/`.
- Ask before overwriting an existing skill.
