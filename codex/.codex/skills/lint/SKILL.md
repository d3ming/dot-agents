---
name: lint
description: Enforce repository linting standards by discovering and running the correct lint command (prefer make lint). Use after completing any coding task, or when user asks to lint, validate formatting, or check code quality.
---

# Lint

## Overview
Run the repo’s lint command after each coding task. Prefer `make lint`; if unavailable, discover the correct lint command from repo docs or config, then run it and report results.

## Workflow
1. **Discover lint command**
   - First try `make lint`.
   - If missing, inspect `Makefile`, `pyproject.toml`, `package.json`, `tox.ini`, or `README.md` for lint targets/scripts.
   - Do not guess or invent commands. If none found, stop and ask the user.

2. **Run lint**
   - Execute the discovered command exactly.
   - If lint fails, summarize the errors and ask how to proceed.

3. **Report**
   - Confirm command used and outcome.
   - If lint was skipped (no command found or user asked not to run), state why.

## Guardrails
- Fail fast if the lint command cannot be determined.
- Never fabricate a lint command or silently skip lint after code changes.
