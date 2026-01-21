# AI Agent Permission Configuration Guide

## Managing Allow/Deny Lists for Claude Code, Codex CLI, and Gemini CLI

**Status:** Active
**Date:** 2026-01-21
**Scope:** Developer Tooling / AI Safety / Workflow Configuration
**Audience:** Engineers using AI coding assistants

---

## Executive Summary

AI coding agents need filesystem and shell access to be useful, but unrestricted access creates risk. All major AI CLI tools (Claude Code, Codex CLI, Gemini CLI) have converged on similar permission models:

1. **Sandbox mode** - OS-level isolation limiting what agents can technically do
2. **Allow/Deny lists** - Command patterns that bypass or block confirmation prompts
3. **Project vs User scope** - Shared team settings vs personal overrides

This guide covers practical configuration for each tool, with emphasis on balancing productivity (fewer prompts) against safety (no destructive commands).

---

## 1. The Permission Problem

Without configuration, AI agents prompt for every potentially dangerous action:
- Running shell commands
- Writing/editing files
- Network requests
- Using MCP tools

This leads to **prompt fatigue** - engineers approve everything without reading, defeating the safety purpose.

The solution: **explicit allowlists** for known-safe commands, **denylists** for known-dangerous ones.

---

## 2. Claude Code

### 2.1 Configuration Files

| File | Scope | Git |
|------|-------|-----|
| `~/.claude/settings.json` | User (all projects) | N/A |
| `.claude/settings.json` | Project (shared) | Commit |
| `.claude/settings.local.json` | Project (personal) | Gitignore |

Project settings override user settings. Local overrides shared.

### 2.2 Permission Syntax

```json
{
  "permissions": {
    "allow": [
      "Bash(make:*)",
      "Bash(git commit:*)",
      "Bash(poetry run:*)",
      "Edit",
      "WebSearch"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(git reset:*)"
    ]
  }
}
```

**Pattern syntax:**
- `Bash(command:*)` - Allow command with any arguments
- `Bash(command)` - Allow command with no arguments
- `WebFetch(domain:example.com)` - Allow fetching from specific domain
- `Skill(skill-name)` - Allow specific skill
- `Edit` - Allow file editing (no pattern needed)

### 2.3 Sandbox Mode

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true
  }
}
```

When sandbox is enabled:
- Commands run in an isolated environment
- Network access may be restricted
- Some tools (Docker, certain git operations) may not work

**Recommendation:** For full-featured development, disable sandbox and use explicit allowlists instead.

### 2.4 Recommended Configuration

```json
{
  "permissions": {
    "allow": [
      "Edit",
      "WebSearch",

      "Bash(make:*)",
      "Bash(make)",

      "Bash(poetry run:*)",
      "Bash(poetry add:*)",
      "Bash(poetry install:*)",
      "Bash(uv:*)",

      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git pull:*)",
      "Bash(git fetch:*)",
      "Bash(git branch:*)",
      "Bash(git checkout:*)",
      "Bash(git switch:*)",
      "Bash(git merge:*)",
      "Bash(git rebase:*)",
      "Bash(git cherry-pick:*)",
      "Bash(gh:*)",

      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(find:*)",
      "Bash(grep:*)",
      "Bash(rg:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(wc:*)",
      "Bash(tree:*)",
      "Bash(pwd)",
      "Bash(mkdir:*)",
      "Bash(mv:*)",
      "Bash(cp:*)",
      "Bash(touch:*)",

      "Bash(python:*)",
      "Bash(python3:*)",
      "Bash(node:*)",
      "Bash(npm:*)",
      "Bash(pnpm:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(git push -f:*)",
      "Bash(git reset:*)",
      "Bash(git restore:*)",
      "Bash(git clean:*)",
      "Bash(git stash:*)",
      "Bash(git checkout -- :*)",
      "Bash(git checkout .:*)"
    ]
  }
}
```

---

## 3. Codex CLI (OpenAI)

### 3.1 Configuration Files

| File | Scope |
|------|-------|
| `~/.codex/rules/*.rules` | User rules |
| Project-level config | Via `codex.toml` |

### 3.2 Two-Layer Security Model

**Layer 1: Sandbox Mode**
- `sandbox_mode: "sandbox"` - OS-enforced isolation (default)
- `sandbox_mode: "danger-full-access"` - No sandbox

**Layer 2: Approval Policy**
- `approval_policy: "always"` - Prompt for everything
- `approval_policy: "unless-allow-listed"` - Use rules
- `approval_policy: "never"` - Auto-approve (dangerous)

### 3.3 Rules Syntax

Create `~/.codex/rules/default.rules`:

```toml
[[rule]]
pattern = "make *"
decision = "allow"

[[rule]]
pattern = "git commit *"
decision = "allow"

[[rule]]
pattern = "rm -rf *"
decision = "forbidden"

[[rule]]
pattern = "git push --force *"
decision = "forbidden"
```

**Decisions:**
- `allow` - Run without prompting
- `prompt` - Ask user (default)
- `forbidden` - Block entirely

When multiple rules match, **most restrictive wins** (forbidden > prompt > allow).

### 3.4 Testing Rules

```bash
codex execpolicy check "git commit -m 'test'"
# Output: allowed

codex execpolicy check "rm -rf /"
# Output: forbidden
```

### 3.5 Enterprise Controls

Organizations can enforce constraints via `requirements.toml`:
- Disallow `approval_policy = "never"`
- Disallow `sandbox_mode = "danger-full-access"`
- Enforce network allowlists

---

## 4. Gemini CLI (Google)

### 4.1 Configuration Files

| File | Scope | Git |
|------|-------|-----|
| `~/.gemini/settings.json` | User (global) | N/A |
| `.gemini/settings.json` | Project (workspace) | Commit |

Precedence: Default → System → User → Project → System overrides

### 4.2 Permission Syntax

```json
{
  "tools": {
    "allowed": [
      "run_shell_command(git)",
      "run_shell_command(make)",
      "run_shell_command(npm test)"
    ],
    "core": [
      "ReadFileTool",
      "GlobTool",
      "GrepTool",
      "ShellTool"
    ]
  }
}
```

**Key settings:**
- `tools.allowed` - Commands that bypass confirmation
- `tools.core` - Restrict available built-in tools (allowlist)

### 4.3 MCP Server Controls

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["my-mcp-server"],
      "includeTools": ["safe-tool-1", "safe-tool-2"],
      "excludeTools": ["dangerous-tool"]
    }
  }
}
```

- `includeTools` - Allowlist (only these tools available)
- `excludeTools` - Denylist (these tools blocked)
- `excludeTools` takes precedence over `includeTools`

### 4.4 Enterprise Configuration

For maximum security, use allowlist-only:

```json
{
  "tools": {
    "core": ["ReadFileTool", "GlobTool", "ShellTool(ls)", "ShellTool(git status)"]
  }
}
```

**Security note from Google:** Blocklisting with `excludeTools` is less secure than allowlisting with `includeTools`, as clever users may find ways to bypass string-based blocks.

---

## 5. Philosophy: Allowlist vs Denylist

### Denylist Approach
- Block known-dangerous commands
- Allow everything else
- **Pros:** Less maintenance, more flexible
- **Cons:** May miss dangerous commands, bypass risk

### Allowlist Approach
- Only permit known-safe commands
- Block everything else
- **Pros:** Maximum security, no surprises
- **Cons:** More maintenance, may block legitimate commands

### Recommendation

Use a **hybrid approach**:
1. Allowlist common safe commands (make, git, language runtimes)
2. Explicitly denylist known-dangerous patterns (rm -rf, force push, reset)
3. Let the agent prompt for edge cases

This balances productivity with safety.

---

## 6. Dangerous Commands Reference

### Destructive File Operations
```
rm -rf
rm -r
rmdir
```

### Destructive Git Operations
```
git push --force / git push -f
git reset (all forms)
git restore (discards uncommitted changes)
git clean (deletes untracked files)
git stash (can lose work if misused)
git checkout -- (legacy discard syntax)
git rebase -i (interactive, can rewrite history)
git filter-branch (rewrites history)
```

### System-Level Risks
```
sudo
chmod 777
chown
dd
mkfs
```

### Network Risks
```
curl | bash
wget -O - | sh
```

---

## 7. Quick Reference

| Feature | Claude Code | Codex CLI | Gemini CLI |
|---------|-------------|-----------|------------|
| Project config | `.claude/settings.json` | `codex.toml` | `.gemini/settings.json` |
| User config | `~/.claude/settings.json` | `~/.codex/rules/*.rules` | `~/.gemini/settings.json` |
| Allow syntax | `Bash(cmd:*)` | `pattern = "cmd *"` | `run_shell_command(cmd)` |
| Deny syntax | `deny: [...]` | `decision = "forbidden"` | `excludeTools: [...]` |
| Sandbox | `sandbox.enabled` | `sandbox_mode` | N/A |
| Test rules | N/A | `codex execpolicy check` | N/A |

---

## 8. References

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Codex CLI Security](https://developers.openai.com/codex/security/)
- [Codex CLI Rules](https://developers.openai.com/codex/rules/)
- [Gemini CLI Configuration](https://google-gemini.github.io/gemini-cli/docs/get-started/configuration.html)
- [Gemini CLI Enterprise](https://google-gemini.github.io/gemini-cli/docs/cli/enterprise.html)

---

## Related Docs

- [Autonomous Engineering Loops](./automation/autonomous-engineering.md) - Patterns for agentic workflows
- [CLAUDE.md](../CLAUDE.md) - Project-specific agent instructions
