---
name: git-commit
description: Review unstaged changes, stage relevant files, and commit with Conventional Commits.
---

# Git Commit

## Inputs
- Optional scope, intent, or paths to include/exclude.

## Workflow
1. Review changes
   - `git status --short`
   - `git diff`
   - If staged changes exist, confirm they are in-scope; otherwise ask to reset or split.
   - If multiple unrelated changes, ask to split or specify scope.
2. Stage relevant files
   - Prefer explicit paths: `git add path...`
   - Use `git add -p` for partial staging.
   - Include new files only if clearly part of the commit intent; otherwise ask.
3. Craft Conventional Commit message
   - Types: feat, fix, refactor, build, ci, chore, docs, style, perf, test.
   - Format: `type(scope): subject` (scope optional).
   - Subject: imperative, lowercase, no trailing period.
   - Breaking change: add `!` or `BREAKING CHANGE:` body.
4. Commit
   - Prefer `./scripts/committer` if present; else `committer` (PATH).
   - Otherwise `git commit -m "type(scope): subject"` (add body with a second `-m`).
5. Report
   - Show commit hash and message.

## Guardrails
- Never commit without reviewing the diff.
- Do not stage unrelated changes; ask if uncertain.
- If no changes, stop and explain.
- If hooks fail, report and ask how to proceed.
