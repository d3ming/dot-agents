# AI Agent Configuration & Skills Reference

Central reference for configuring coding agents (Claude Code, Gemini CLI, Codex) with a focus on: (1) where instructions live, (2) how commands/skills are packaged, (3) how to share reusable “capabilities” across tools, and (4) where to look for high-quality community patterns.

---

## 1) Official products, standards, and where they live

| Component                    | Repo / Docs                                                         | What it is used for                                                                                      |
| ---------------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| Claude Code                  | anthropics/claude-code ([GitHub][1])                                | Agentic coding tool (terminal/IDE/GitHub) with project “memory” and extensibility.                       |
| Gemini CLI                   | google-gemini/gemini-cli ([GitHub][2])                              | Terminal agent with layered settings, hierarchical context files, custom slash commands, and extensions. |
| Codex CLI                    | openai/codex ([GitHub][3])                                          | Local coding agent; supports persistent project instructions via AGENTS.md and skills.                   |
| Agent Skills (open standard) | agentskills/agentskills ([GitHub][4])                               | Portable packaging format for task-specific capabilities (instructions + optional scripts/resources).    |
| Codex skills documentation   | developers.openai.com codex/skills ([OpenAI Developers][5])         | OpenAI’s reference for how skills work in Codex.                                                         |
| MCP (Model Context Protocol) | modelcontextprotocol/modelcontextprotocol + spec site ([GitHub][6]) | Standard for securely connecting agents to tools/data sources (servers, transports, SDKs).               |

---

## 2) Mental model: “instructions” vs “commands” vs “skills” vs “MCP”

Use this vocabulary consistently across agents:

* Instructions (project rules / memory): long-lived guidance (style, architecture, constraints).

  * Example: “Always add tests; prefer small PRs; never change public APIs without deprecation.”
* Commands (shortcuts): named prompt templates you run explicitly.

  * Example: `/plan`, `/refactor`, `/write-tests`.
* Skills (capabilities): reusable, discoverable bundles (instructions + optional scripts/resources) designed for reliable execution, often portable across hosts that implement the standard. ([GitHub][4])
* MCP servers (connectors): tool/data integrations exposed via a protocol so agents can call them safely. ([GitHub][6])

A useful analogy for teams:

* Instructions = “team handbook”
* Commands = “runbooks/macros”
* Skills = “packaged SOPs + helpers”
* MCP = “standardized API adapter layer”

---

## 3) Configuration patterns (project-level vs user-level) by agent

### 3.1 Claude Code

**Project instructions (“memory”)**

* CLAUDE.md is treated as a special project file that Claude can pull into context at session start (commonly used for architecture and conventions). ([Anthropic][7])
* Claude Code also supports automatically loading rule files under a project rules directory (e.g., `.claude/rules/`) alongside a project CLAUDE.md under `.claude/`. ([Claude Code][8])

  * Practical guidance: standardize on a single convention per repo (either root `CLAUDE.md` or `.claude/CLAUDE.md` + `.claude/rules/`) and document which one your org uses.

**Installation (common options)**

* curl / brew / npm install paths are documented in the repo. ([GitHub][1])

### 3.2 Gemini CLI

**Settings (layered)**

* Global user settings: `~/.gemini/settings.json` ([Gemini CLI][9])
* Project settings: `.gemini/settings.json` (in project root) ([Gemini CLI][9])
* Gemini CLI documents explicit precedence order across defaults → user → project → env vars → CLI args. ([Gemini CLI][9])

**Instructional context (“hierarchical instructional context”)**

* Gemini CLI supports context files such as `GEMINI.md` and documents hierarchical loading. ([Gemini CLI][9])

**Custom commands**

* Custom slash commands are supported and can be defined in local `.toml` files. ([Gemini CLI][10])

### 3.3 Codex CLI

**Project instructions**

* Codex reads `AGENTS.md` files “before doing any work,” enabling consistent project guidance. ([OpenAI Developers][11])
* Codex discovers project configuration by walking up to a project root (default markers include `.git`; configurable). ([OpenAI Developers][12])

**User settings**

* `~/.codex/config.toml` is the primary configuration file. ([OpenAI Developers][13])

**Skills**

* Skills are first-class in Codex (CLI + IDE extensions). ([OpenAI Developers][14])

---

## 4) File layout conventions you can standardize across tools

A practical repo layout that maps cleanly to all three ecosystems:

* `AGENTS.md` (Codex instructions) ([OpenAI Developers][11])
* `CLAUDE.md` (Claude instructions) ([Anthropic][7])
* `GEMINI.md` (Gemini instructions) ([Google Codelabs][15])
* `shared/`

  * `shared/protocols/` (team-wide engineering rules, review rules, security rules)
  * `shared/skills/` (portable skills in Agent Skills format) ([GitHub][4])
  * `shared/commands/` (prompt templates that can be rendered into each agent’s command format)
  * `shared/mcp/` (MCP server configs, manifests, env templates)

Key design goal: treat project instruction files as thin “indexes” that point to canonical shared docs, rather than duplicating content.

---

## 5) Command/skill implementation comparison (examples without metadata headers)

### 5.1 Claude Code: command file (Markdown body + metadata fields)

Typical location: `.claude/commands/<name>.md` (see repo layout). ([GitHub][1])

Recommended structure you can enforce consistently:

```markdown
# Command: explain-change

Purpose:
- Explain what changed and why, in human terms.
- Call out risk areas and required tests.

Inputs:
- Optional: scope (file/dir) or PR URL

Steps:
1) Summarize changes by subsystem.
2) Identify behavior changes vs refactors.
3) List risks, rollback plan, and test plan.
4) Output a short “review checklist” for a human reviewer.
```

### 5.2 Gemini CLI: custom slash command (`.toml`)

Custom commands are supported and commonly stored under `~/.gemini/commands/` (global) or `.gemini/commands/` (project), using TOML. ([Gemini CLI][10])

```toml
description = "Create a focused implementation plan before coding"
prompt = """
You are in planning mode only.

Goal:
- Produce a step-by-step plan and a test plan.
- Do not write code until I confirm.

Constraints:
- Prefer small diffs and incremental commits.
- Call out risks, unknowns, and required decisions.

User request:
{{args}}
"""
```

### 5.3 Codex: skills (portable “capability bundles”)

Codex supports skills built on the Agent Skills standard. ([OpenAI Developers][5])

A skill should be treated as a folder (not just a single file), so you can include scripts/resources deterministically. You can enforce a structure like:

```text
skills/
  test-author/
    SKILL.md
    scripts/
      generate_tests.py
    assets/
      test_templates.md
```

Example `SKILL.md` body pattern:

```markdown
# Skill: test-author

## Overview
Generate high-signal unit tests for the changed code, aligned to repo testing conventions.

## Inputs
- Target files/dirs
- Desired coverage focus (happy path, edge cases, regression)

## Workflow
1) Inspect existing test patterns and helpers.
2) Identify behaviors that changed.
3) Generate tests with minimal mocking.
4) Provide a short rationale and how to run tests.
```

---

## 6) Shared skills strategy (portable-first, agent-specific rendering at the edges)

### 6.1 Principle: one canonical “capability” definition, multiple renderers

* Canonical format: Agent Skills standard for anything you want to share across agents. ([GitHub][4])
* Renderer approach:

  * Generate Gemini `.toml` commands from shared templates when you want explicit “slash command” invocation.
  * Keep Codex skills as-is (native).
  * For Claude, either:

    * mirror the SKILL.md content into `.claude/commands/`, or
    * maintain a small shim command that invokes/loads the shared skill text.

### 6.2 Operational approach

* `shared/MASTER-AGENTS.md` as source-of-truth policy (security, style, testing, review).
* Keep project files (AGENTS.md / CLAUDE.md / GEMINI.md) thin and stable; they should primarily:

  1. define local exceptions
  2. link/point to shared policy blocks
  3. specify toolchain-specific constraints (e.g., sandboxing, network policy)

### 6.3 “Don’t fight the host”

* Use each platform’s strengths:

  * Gemini: fast reuse via TOML slash commands + hierarchical context. ([Google Cloud][16])
  * Codex: skills + AGENTS.md + approval/sandbox controls. ([OpenAI Developers][11])
  * Claude: strong project memory conventions + command ecosystem. ([Anthropic][7])

---

## 7) Popular GitHub repos for inspiration (patterns worth copying)

Star counts below are approximate and can drift; figures are as observed around early January 2026 from the cited sources.

### 7.1 Claude Code ecosystems (commands, templates, and orchestration)

* hesreallyhim/awesome-claude-code (≈19.4k) ([GitHub][17])
* davila7/claude-code-templates (≈14.7k) ([GitHub][18])
* feiskyer/claude-code-settings (≈1k) ([GitHub][19])
* anthropics/claude-code (≈51.6k) ([GitHub][1])
* anthropics/claude-code-action (GitHub automation patterns for @claude workflows) ([GitHub][20])

### 7.2 Gemini CLI ecosystems (commands + extensions)

* Piebald-AI/awesome-gemini-cli (≈240) ([GitHub][21])
* gemini-cli-extensions/conductor (≈1.3k) ([GitHub][22])
* Gemini CLI docs: custom commands and configuration (best source for file formats and locations) ([Gemini CLI][10])

### 7.3 Codex ecosystems (skills + instruction patterns)

* openai/codex (install patterns + CLI quickstart) ([GitHub][3])
* openai/skills (Codex skills catalog; good for folder structure and real-world skill patterns) ([GitHub][23])
* Codex docs: AGENTS.md and skills (authoritative behavior) ([OpenAI Developers][11])

### 7.4 Skills standard and skill libraries

* anthropics/skills (large skill library; great for “what does a good skill look like?”) ([GitHub][24])
* agentskills/agentskills (spec and examples; portability reference) ([GitHub][4])

### 7.5 MCP servers and protocol ecosystems

* appcypher/awesome-mcp-servers (≈5k) ([GitHub][25])
* modelcontextprotocol/modelcontextprotocol (core spec + schema + official docs) ([GitHub][6])
* modelcontextprotocol/typescript-sdk (reference SDK + examples) ([GitHub][26])
* MCP examples page (official reference implementations and servers list) ([Model Context Protocol][27])

---

## 8) A practical “minimum viable” standard for teams

If you want the fewest moving parts with strong leverage:

1. Put core engineering policy in `shared/MASTER-AGENTS.md`.
2. In every repo, add:

   * `AGENTS.md` (Codex) with “review guidelines” + local constraints. ([OpenAI Developers][28])
   * `CLAUDE.md` (Claude) with architecture + conventions. ([Anthropic][7])
   * `GEMINI.md` (Gemini) with the same core rules + any repo-specific workflows. ([Google Codelabs][15])
3. Start with 5–10 shared skills (test authoring, bug triage, refactor plan, security review, release checklist).
4. Add 5–10 Gemini slash commands (TOML) that map to the same skills for explicit invocation. ([Google Cloud][16])
5. Only introduce MCP servers once you have stable workflows; treat MCP as a “capability multiplier,” not a starting dependency. ([Model Context Protocol][29])

---

Last Updated: January 5, 2026

TLDR;

* Standardize vocabulary: instructions (handbook), commands (macros), skills (packaged SOPs), MCP (tool/data connectors). ([GitHub][4])
* Codex: use `AGENTS.md` + skills; config in `~/.codex/config.toml`. ([OpenAI Developers][11])
* Gemini: use `.gemini/settings.json` + `GEMINI.md` + `.toml` custom commands. ([Gemini CLI][9])
* Claude: use `CLAUDE.md` and (optionally) `.claude/rules/` for structured project memory. ([Anthropic][7])
* For inspiration, start with awesome-claude-code, claude-code-templates, openai/skills, anthropics/skills, and awesome-mcp-servers. ([GitHub][17])

[1]: https://github.com/anthropics/claude-code "GitHub - anthropics/claude-code: Claude Code is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows - all through natural language commands."
[2]: https://github.com/google-gemini/gemini-cli?utm_source=chatgpt.com "google-gemini/gemini-cli: An open-source AI ..."
[3]: https://github.com/openai/codex?utm_source=chatgpt.com "openai/codex: Lightweight coding agent that runs in your ..."
[4]: https://github.com/agentskills/agentskills?utm_source=chatgpt.com "Specification and documentation for Agent Skills"
[5]: https://developers.openai.com/codex/skills/?utm_source=chatgpt.com "Agent Skills"
[6]: https://github.com/modelcontextprotocol/modelcontextprotocol?utm_source=chatgpt.com "Specification and documentation for the Model Context ..."
[7]: https://www.anthropic.com/engineering/claude-code-best-practices?utm_source=chatgpt.com "Claude Code: Best practices for agentic coding"
[8]: https://code.claude.com/docs/en/memory?utm_source=chatgpt.com "Manage Claude's memory"
[9]: https://geminicli.com/docs/get-started/configuration/ "Gemini CLI configuration | Gemini CLI"
[10]: https://geminicli.com/docs/cli/custom-commands/?utm_source=chatgpt.com "Custom commands - Gemini CLI"
[11]: https://developers.openai.com/codex/guides/agents-md/?utm_source=chatgpt.com "Custom instructions with AGENTS.md"
[12]: https://developers.openai.com/codex/config-advanced/?utm_source=chatgpt.com "Advanced Configuration"
[13]: https://developers.openai.com/codex/config-basic/?utm_source=chatgpt.com "Basic Configuration"
[14]: https://developers.openai.com/codex/changelog/?utm_source=chatgpt.com "Codex changelog"
[15]: https://codelabs.developers.google.com/gemini-cli-hands-on?utm_source=chatgpt.com "Hands-on with Gemini CLI"
[16]: https://cloud.google.com/blog/topics/developers-practitioners/gemini-cli-custom-slash-commands?utm_source=chatgpt.com "Gemini CLI: Custom slash commands"
[17]: https://github.com/hesreallyhim/awesome-claude-code "GitHub - hesreallyhim/awesome-claude-code: A curated list of awesome commands, files, and workflows for Claude Code"
[18]: https://github.com/davila7/claude-code-templates/blob/main/CLAUDE.md?utm_source=chatgpt.com "claude-code-templates/CLAUDE.md at main"
[19]: https://github.com/feiskyer/claude-code-settings "GitHub - feiskyer/claude-code-settings: Claude Code settings, commands and agents for vibe coding"
[20]: https://github.com/anthropics/claude-code-action?utm_source=chatgpt.com "anthropics/claude-code-action"
[21]: https://github.com/Piebald-AI/awesome-gemini-cli/activity "Activity · Piebald-AI/awesome-gemini-cli · GitHub"
[22]: https://github.com/gemini-cli-extensions?utm_source=chatgpt.com "Gemini CLI Extensions"
[23]: https://github.com/openai/skills?utm_source=chatgpt.com "openai/skills: Skills Catalog for Codex"
[24]: https://github.com/anthropics/skills?utm_source=chatgpt.com "anthropics/skills: Public repository for Agent Skills"
[25]: https://github.com/appcypher/awesome-mcp-servers "GitHub - appcypher/awesome-mcp-servers: Awesome MCP Servers - A curated list of Model Context Protocol servers"
[26]: https://github.com/modelcontextprotocol/typescript-sdk?utm_source=chatgpt.com "modelcontextprotocol/typescript-sdk"
[27]: https://modelcontextprotocol.io/examples?utm_source=chatgpt.com "Example Servers"
[28]: https://developers.openai.com/codex/integrations/github/?utm_source=chatgpt.com "Use Codex in GitHub"
[29]: https://modelcontextprotocol.io/specification/2025-11-25?utm_source=chatgpt.com "Specification"
