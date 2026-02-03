---
name: gh-address-comments
description: Help address review/issue comments on the open GitHub PR for the current branch using gh CLI; verify gh auth first and prompt the user to authenticate if not logged in.
metadata:
  short-description: Address comments in a GitHub PR review
---

# PR Comment Handler

Guide to find the open PR for the current branch and address its comments with gh CLI. Run all `gh` commands with elevated network access.

Prereq: ensure `gh` is authenticated (for example, run `gh auth login` once), then run `gh auth status` with escalated permissions (include workflow/repo scopes) so `gh` commands succeed. If sandboxing blocks `gh auth status`, rerun it with `sandbox_permissions=require_escalated`.

## 1) Inspect comments needing attention
- This skill includes a helper script `fetch_comments.py` in its scripts/ subdirectory
- Locate and run the script (skills are installed in ~/.codex/skills/, ~/.claude/skills/, or ~/.gemini/skills/):
  `python $(find ~/.codex ~/.claude ~/.gemini -path "*/gh-address-comments/scripts/fetch_comments.py" 2>/dev/null | head -1)`
- The script outputs all PR comments, review threads, and inline code review comments as JSON
- If the script cannot be located, fall back to using `gh api` GraphQL queries directly to fetch PR comment data

## 2) Ask the user for clarification
- Number all the review threads and comments and provide a short summary of what would be required to apply a fix for it
- Ask the user which numbered comments should be addressed

## 3) If user chooses comments
- Apply fixes for the selected comments

Notes:
- If gh hits auth/rate issues mid-run, prompt the user to re-authenticate with `gh auth login`, then retry.
