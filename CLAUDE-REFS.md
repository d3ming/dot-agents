# Claude Code Settings Reference Guide

Canonical guide for state-of-the-art Claude Code configuration.

## Key References

### Official Documentation
- [Claude Code Docs](https://code.claude.com/docs/en/settings) - Official settings reference
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide) - Official hooks documentation
- [Best Practices for Agentic Coding](https://www.anthropic.com/engineering/claude-code-best-practices) - Anthropic's official best practices

### Community Resources
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) - Curated list of commands, files, workflows
- [feiskyer/claude-code-settings](https://github.com/feiskyer/claude-code-settings) - Multi-provider config, custom commands, specialized agents
- [disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery) - Comprehensive hooks examples
- [johnlindquist/claude-hooks](https://github.com/johnlindquist/claude-hooks) - TypeScript hooks with type safety
- [decider/claude-hooks](https://github.com/decider/claude-hooks) - Clean code enforcement hooks

### Articles & Guides
- [settings.json guide (eesel.ai)](https://www.eesel.ai/blog/settings-json-claude-code) - 2025 developer's guide
- [Claude Code Cheatsheet (Shipyard)](https://shipyard.build/blog/claude-code-cheat-sheet/) - Config, commands, prompts
- [Builder.io tips](https://www.builder.io/blog/claude-code) - Real-world usage patterns
- [Global Instructions Guide](https://naqeebali-shamsi.medium.com/the-complete-guide-to-setting-global-instructions-for-claude-code-cli-cec8407c99a0) - CLAUDE.md setup

---

## Configuration Hierarchy

Settings precedence (highest → lowest):
1. **Managed settings** (Enterprise) - `/Library/Application Support/ClaudeCode/managed-settings.json`
2. **Command line arguments** - `--setting value`
3. **Local project** - `./.claude/settings.local.json` (gitignored, personal)
4. **Shared project** - `./.claude/settings.json` (team-shared, committed)
5. **User global** - `~/.claude/settings.json` (applies to all projects)

### File Locations

```
~/.claude/
├── settings.json              # Global user settings
├── CLAUDE.md                  # Global memory/instructions
├── plugins/                   # Installed plugins
└── .claude/                   # When ~/.claude is a project (ignore in git)

<project>/
├── .claude/
│   ├── settings.json          # Team-shared settings
│   ├── settings.local.json    # Personal overrides (gitignored)
│   ├── CLAUDE.md              # Project memory
│   ├── commands/              # Custom slash commands (*.md)
│   └── rules/                 # Modular CLAUDE.md rules (*.md)
└── CLAUDE.md                  # Alt location for project memory
```

---

## Essential Settings

### Security & Permissions

**~/.claude/settings.json:**

```json
{
  "permissions": {
    "allow": [
      "Edit(~/.claude/**)",
      "Write(~/.claude/**)",
      "Bash(git *)",
      "Bash(test:*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(**/.env)",
      "Write(./production.config.*)"
    ],
    "defaultMode": "default"
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "network": {
      "allowedDomains": ["api.github.com", "registry.npmjs.org"]
    }
  }
}
```

**Key principles:**
- Always deny access to `.env` files and credentials
- Use sandbox mode with auto-allow for safer bash execution
- Whitelist specific bash commands or patterns
- Use `defaultMode: "acceptEdits"` for auto-approving file edits (optional)

### Model Configuration

```json
{
  "model": "claude-sonnet-4-20250514",
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.anthropic.com",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-20250514"
  }
}
```

### Attribution

```json
{
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
```

Set empty strings to disable co-author attribution in commits/PRs.

---

## Memory System (CLAUDE.md)

### Global Memory (~/.claude/CLAUDE.md)

Personal preferences applied to ALL projects:

```markdown
# Personal Preferences

## Code Style
- Use 2-space indentation
- Prefer functional programming
- TypeScript strict mode always

## Communication
- Telegraph style: concise, no filler
- Drop grammar when clarity maintained
- Minimal tokens

## Tools & Environment
- macOS user
- Prefer pnpm over npm
- Use Conventional Commits (feat|fix|refactor|...)

## Workflows
- Run tests before committing
- Never force push to main
- Use `committer` helper for commits
```

**Symlink approach:** Link to existing config

```bash
ln -s ~/.codex/AGENTS.md ~/.claude/CLAUDE.md
```

### Project Memory (./.claude/CLAUDE.md)

Team-shared project context:

```markdown
# Project: Acme Web App

## Architecture
- Next.js 14 App Router
- Tailwind CSS + shadcn/ui
- tRPC for API layer
- Prisma + PostgreSQL

## Conventions
- File naming: kebab-case
- Components in `src/components/`
- Use Server Components by default
- Client Components: explicit "use client"

## Testing
- Vitest for unit tests
- Playwright for E2E
- Min 80% coverage on utils/

## Available Commands
- `pnpm dev` - Start dev server
- `pnpm test` - Run tests
- `pnpm db:push` - Sync Prisma schema
```

### Modular Rules (./.claude/rules/*.md)

For large projects, split CLAUDE.md:

```
.claude/
├── CLAUDE.md          # Main instructions
└── rules/
    ├── code-style.md
    ├── testing.md
    ├── security.md
    └── deployment.md
```

---

## Hooks

Automate workflows via lifecycle events.

### Hook Types
- `SessionStart` - Session initialization
- `UserPromptSubmit` - Before user prompt processed
- `PreToolUse` - Before tool execution
- `PostToolUse` - After successful tool execution
- `PostToolUseFailure` - After failed tool execution
- `PermissionRequest` - Before permission prompt
- `SubagentStart` / `SubagentStop` - Agent lifecycle
- `Stop` - Session end

### Example: Auto-format on Edit

**.claude/settings.json:**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write \"$FILE_PATH\"",
            "statusMessage": "Formatting code..."
          }
        ]
      }
    ]
  }
}
```

### Example: Commit Message Validator

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Verify this commit message follows Conventional Commits format: $ARGUMENTS",
            "statusMessage": "Validating commit message..."
          }
        ]
      }
    ]
  }
}
```

### Hook Repositories
- [claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery) - Python-based, all 8 hook types
- [claude-hooks](https://github.com/johnlindquist/claude-hooks) - TypeScript, type-safe
- [claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability) - Real-time monitoring
- [decider/claude-hooks](https://github.com/decider/claude-hooks) - Clean code enforcement

---

## Custom Commands

Create slash commands via `.claude/commands/*.md` files.

### Example: /think-harder

**.claude/commands/think-harder.md:**

```markdown
---
name: think-harder
description: Extended thinking mode for complex problems
---

# Extended Thinking Mode

Take extra time to reason through this problem. Consider:
- Edge cases and failure modes
- Performance implications
- Security concerns
- Maintainability trade-offs

Break down the problem into sub-problems and address each systematically.
```

### Command Structure

```markdown
---
name: command-name
description: Short description
---

# Command Instructions

Detailed instructions for Claude...
```

Commands appear in autocomplete when typing `/` in Claude Code.

---

## Skills & Agents

### Custom Skills

Install from marketplaces or create your own:

**.claude/settings.json:**

```json
{
  "enabledPlugins": {
    "codex-skill@custom": true,
    "autonomous-skill@custom": true
  },
  "extraKnownMarketplaces": {
    "custom": {
      "source": {
        "source": "github",
        "repo": "yourname/claude-skills",
        "path": ".claude-plugin/marketplace.json"
      }
    }
  }
}
```

### Specialized Agents

Define domain-specific agents:

```json
{
  "agent": "code-reviewer"
}
```

See [feiskyer/claude-code-settings](https://github.com/feiskyer/claude-code-settings) for agent examples:
- GitHub PR reviewer
- Issue resolution specialist
- Documentation writer
- Technical translator

---

## Multi-Provider Setup

### Alternative Model Providers

**Using LiteLLM Gateway:**

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:4000",
    "ANTHROPIC_AUTH_TOKEN": "your-api-key"
  },
  "model": "claude-sonnet-4-20250514"
}
```

**DeepSeek/Qwen/etc:**

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.provider.com/v1",
    "ANTHROPIC_AUTH_TOKEN": "provider-api-key"
  }
}
```

See [feiskyer/claude-code-settings](https://github.com/feiskyer/claude-code-settings) for GitHub Copilot, Azure, Vertex AI examples.

---

## MCP Server Integration

Configure Model Context Protocol servers:

**~/.claude/settings.json:**

```json
{
  "enabledPlugins": {
    "filesystem@mcp": true,
    "memory@mcp": true,
    "brave-search@mcp": true
  },
  "pluginConfigs": {
    "brave-search@mcp": {
      "mcpServers": {
        "brave-search": {
          "BRAVE_API_KEY": "your-api-key"
        }
      }
    }
  }
}
```

Common MCP servers:
- **filesystem** - Enhanced file operations
- **memory** - Persistent KV store across sessions
- **brave-search** / **tavily** / **duckduckgo** - Web search
- **github** - GitHub API integration
- **postgres** / **sqlite** - Database access

---

## Gitignore Best Practices

**.gitignore:**

```gitignore
# Session/runtime data
debug/
history.jsonl
file-history/
projects/
shell-snapshots/
todos/
plans/
session-env/
ide/
statsig/

# Nested .claude (when ~/.claude is a project)
.claude/

# Plugins runtime
plugins/marketplaces/

# Local overrides (optional - can also commit)
# .claude/settings.local.json
```

**Commit to git:**
- `settings.json` - Shared team configuration
- `CLAUDE.md` - Team knowledge
- `.claude/commands/` - Custom commands
- `plugins/known_marketplaces.json` - Plugin sources

**Don't commit:**
- Session logs (debug/, history.jsonl)
- Personal settings (settings.local.json)
- Runtime data (projects/, todos/, plans/)

---

## Advanced Patterns

### Dual-Agent Pattern

Run autonomous task continuation with checkpoint system:

```bash
# Session 1
claude "Implement feature X"

# Session 2 (resume)
claude "Continue from last checkpoint"
```

Requires checkpoint infrastructure (see autonomous-skill examples).

### Constitution-Based Development

Spec-kit pattern: 7-phase workflow
1. Requirements gathering
2. Architecture design
3. Task breakdown
4. Implementation
5. Testing
6. Review
7. Documentation

Defined via custom agents with phase-specific prompts.

### Multi-Agent Observability

Real-time hook monitoring:

```json
{
  "hooks": {
    "SubagentStart": [{
      "hooks": [{
        "type": "command",
        "command": "uv run monitor.py start $AGENT_ID"
      }]
    }],
    "SubagentStop": [{
      "hooks": [{
        "type": "command",
        "command": "uv run monitor.py stop $AGENT_ID"
      }]
    }]
  }
}
```

Tracks agent lifecycle, tool usage, token consumption.

---

## Quick Start Recommendations

### Minimal Setup

```bash
# 1. Create global memory
ln -s ~/.codex/AGENTS.md ~/.claude/CLAUDE.md

# 2. Configure permissions & sandbox
cat > ~/.claude/settings.json <<'EOF'
{
  "permissions": {
    "allow": [
      "Edit(~/.claude/**)",
      "Write(~/.claude/**)"
    ]
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true
  },
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
EOF

# 3. Ignore runtime data
cat > ~/.claude/.gitignore <<'EOF'
debug/
history.jsonl
file-history/
projects/
shell-snapshots/
todos/
plans/
session-env/
ide/
statsig/
.claude/
plugins/marketplaces/
EOF
```

### Advanced Setup

Add:
- Custom hooks for formatting, linting, commit validation
- Slash commands for common workflows
- MCP servers for enhanced capabilities
- Project-specific CLAUDE.md with architecture/conventions
- Modular rules/ directory for large projects

---

## Resources

### Documentation
- [Claude Code Docs](https://code.claude.com/docs)
- [Settings Reference](https://code.claude.com/docs/en/settings)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [IAM & Permissions](https://code.claude.com/docs/en/iam)

### Repositories
- [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [feiskyer/claude-code-settings](https://github.com/feiskyer/claude-code-settings)
- [disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery)
- [johnlindquist/claude-hooks](https://github.com/johnlindquist/claude-hooks)
- [decider/claude-hooks](https://github.com/decider/claude-hooks)

### Articles
- [Anthropic Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Shipyard Cheatsheet](https://shipyard.build/blog/claude-code-cheat-sheet/)
- [Builder.io Tips](https://www.builder.io/blog/claude-code)
- [eesel.ai Guide](https://www.eesel.ai/blog/settings-json-claude-code)

---

*Last updated: 2026-01-05*
