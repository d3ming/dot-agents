# System-Level Permission Defaults Implementation Plan

**Status:** Active
**Date:** 2026-01-21
**Scope:** AI Agent Configuration / Security / Workflow Optimization
**Related:** [allow-deny-guide.md](./allow-deny-guide.md), [master/AGENTS.md](../master/AGENTS.md)

---

## Executive Summary

This document outlines the implementation plan for system-level permission defaults across all AI agents (Claude, Codex, Gemini) in the dot-agents repository. The goal is to establish a **hybrid allowlist + denylist approach** that balances productivity (fewer prompts) with safety (blocking destructive operations).

---

## 1. Current State Analysis

### Claude (`claude/.claude/settings.json`)
- ✅ Has basic permissions (Edit/Write for `~/.claude/**`, `gh` commands)
- ❌ Missing comprehensive allow/deny lists
- ⚠️ Sandbox enabled with auto-allow (less secure than explicit allowlists)

### Codex (`codex/.codex/config.toml` + `rules/default.rules`)
- ✅ Has `workspace-write` sandbox mode
- ✅ Has `on-failure` approval policy
- ❌ Rules file is minimal (only 1 git fetch rule)
- ❌ Missing comprehensive allow/deny patterns

### Gemini (`gemini/.gemini/settings.json`)
- ❌ No permission configuration at all
- ❌ No tools.allowed or tools.core settings
- Only has UI/model preferences

---

## 2. Permission Philosophy

### Hybrid Approach
1. **Allowlist**: Common safe commands that agents use frequently
   - Build tools: `make`
   - Git read operations: `status`, `diff`, `log`
   - Git write operations: `add`, `commit`, `push`, `pull`, `fetch`
   - File operations: `ls`, `cat`, `grep`, `rg`, `find`, `tree`, `mkdir`, `touch`
   - Language runtimes: `python`, `node`, `npm`, `pnpm`, `poetry`, `uv`

2. **Denylist**: Known-dangerous patterns that should never auto-run
   - Destructive file ops: `rm -rf`, `rm -r`
   - Destructive git ops: `push --force`, `reset`, `restore`, `clean`, `stash`
   - System-level risks: `sudo`, `chmod 777`

3. **Prompt Zone**: Everything else requires user confirmation

### Alignment with master/AGENTS.md

| AGENTS.md Rule | Permission Implementation |
|----------------|---------------------------|
| "Safe by default: git status/diff/log" | ✅ Allowlist read-only git |
| "Push only when user asks" | ⚠️ Allow push (user consent via conversation) |
| "Destructive ops forbidden unless explicit" | ✅ Denylist rm -rf, reset, clean, restore |
| "No manual git stash" | ✅ Denylist git stash |
| "No amend unless asked" | ⚠️ Prompt for git commit --amend |

---

## 3. Implementation Details

### 3.1 Master Permission Policy

Create `master/PERMISSIONS.md` to document:
- Permission philosophy and rationale
- Complete list of allowed commands with justification
- Complete list of denied commands with risk explanation
- Edge cases and decision criteria

### 3.2 Claude Configuration

**File**: `claude/.claude/settings.json`

**Changes**:
- Disable sandbox mode (use explicit allowlists instead)
- Add comprehensive `permissions.allow` list
- Add comprehensive `permissions.deny` list
- Keep existing plugin configurations

**Rationale**:
- Sandbox mode limits full dev functionality (Docker, certain git ops)
- Explicit allowlists provide better visibility and control
- Aligns with guide recommendation (Section 2.4)

### 3.3 Codex Configuration

**File**: `codex/.codex/rules/default.rules`

**Changes**:
- Expand from 1 rule to ~40+ rules covering:
  - All safe git operations
  - Build tools (make)
  - Language runtimes (poetry, uv, python, npm, pnpm)
  - File operations (ls, cat, grep, rg, find, tree, mkdir, touch)
  - Forbidden operations (rm -rf, git reset, sudo, etc.)

**Keep existing**:
- `sandbox_mode = "workspace-write"` (appropriate for dev)
- `approval_policy = "on-failure"` (conservative, safe)

**Rationale**:
- Codex uses most-restrictive-wins rule precedence
- Explicit forbidden rules prevent bypass attempts
- on-failure policy adds extra safety layer

### 3.4 Gemini Configuration

**File**: `gemini/.gemini/settings.json`

**Changes**:
- Add `tools.allowed` array with command patterns
- Add `security.commandDenyList` array (if supported)
- Preserve existing UI/model settings

**Note**: Gemini's permission syntax may need adjustment based on latest CLI docs.

---

## 4. Security Considerations

### Tradeoffs

**Allowlisting git push**:
- **Risk**: Agent could push without explicit user command
- **Mitigation**: `master/AGENTS.md` protocol says "Push only when user asks"
- **Decision**: Allow but rely on agent protocol compliance

**Disabling Claude sandbox**:
- **Risk**: Less OS-level isolation
- **Mitigation**: Explicit allowlists provide similar protection
- **Decision**: Disable for full dev functionality

**Codex approval_policy = "on-failure"**:
- **Benefit**: More conservative than "unless-allow-listed"
- **Decision**: Keep this setting for extra safety

### Dangerous Commands (NEVER Allow)

```bash
# Data loss
rm -rf
rm -r
rmdir

# Uncommitted work loss
git reset
git restore
git clean
git stash

# History rewriting
git push --force
git push -f
git filter-branch
git rebase -i (interactive)

# System-level risks
sudo
chmod 777
chown
dd
mkfs

# Arbitrary code execution
curl | bash
wget -O - | sh
```

---

## 5. Implementation Phases

### Phase 1: Documentation ✅
1. ✅ Create `docs/permission-defaults-plan.md` (this document)
2. Create `master/PERMISSIONS.md` - canonical permission reference
3. Link from `README.md`

### Phase 2: Configuration Files
1. Update `claude/.claude/settings.json`
2. Expand `codex/.codex/rules/default.rules`
3. Add permissions to `gemini/.gemini/settings.json`

### Phase 3: Testing
1. Test each agent with common workflows:
   - `make build`
   - `git status/diff/commit/push`
   - File editing
   - Blocked commands (verify denials work)
2. Document any edge cases or issues

### Phase 4: Maintenance
1. Add `make validate-permissions` target to Makefile
2. Create `.agent/workflows/update-permissions.md`
3. Update `README.md` with permission management section

---

## 6. Open Questions & Decisions

### Q1: Should git push be allowlisted or always prompt?
**Decision**: Allowlist, but rely on agent protocol ("Push only when user asks")
**Rationale**: Enables productivity; agents should still confirm via conversation

### Q2: Are mv/cp commands safe to allowlist?
**Decision**: Allowlist with wildcards
**Rationale**: Agents need to reorganize files; less risky than rm

### Q3: Should git merge/rebase be allowlisted?
**Decision**: Allowlist
**Rationale**: Common workflow operations, user typically initiates

### Q4: What about git commit --amend?
**Decision**: Prompt (not allowlisted)
**Rationale**: Rewrites history; should require explicit confirmation

---

## 7. Future Enhancements

1. **Project-specific overrides**:
   - Pattern: `.claude/settings.local.json` (gitignored)
   - Use case: Per-project elevated permissions

2. **Skill-based permissions**:
   - Allow specific skills to request elevated permissions
   - Example: deployment skill needs `git push --force`

3. **Audit logging**:
   - Track when agents hit denied commands
   - Analyze patterns to refine rules

4. **Permission templates**:
   - Create templates for different project types
   - Example: `permissions-python.json`, `permissions-node.json`

5. **Testing framework**:
   - Automated tests for permission rules
   - Verify allowlist/denylist behavior

---

## 8. Testing Checklist

After implementation, verify:

- [ ] Claude can run `make build` without prompting
- [ ] Claude can run `git status/diff/log` without prompting
- [ ] Claude can run `git commit` without prompting
- [ ] Claude blocks `rm -rf` with error
- [ ] Claude blocks `git push --force` with error
- [ ] Codex can run `poetry install` without prompting
- [ ] Codex blocks `git reset` with forbidden error
- [ ] Codex blocks `sudo` commands with forbidden error
- [ ] Gemini can run `make` commands without prompting
- [ ] Gemini can edit files without prompting
- [ ] All agents prompt for `git commit --amend`
- [ ] All agents prompt for `mv` with important files

---

## 9. References

- [allow-deny-guide.md](./allow-deny-guide.md) - Comprehensive permission guide
- [master/AGENTS.md](../master/AGENTS.md) - Shared agent protocol
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Codex CLI Security](https://developers.openai.com/codex/security/)
- [Gemini CLI Configuration](https://google-gemini.github.io/gemini-cli/docs/get-started/configuration.html)

---

## Changelog

- **2026-01-21**: Initial plan created based on allow-deny-guide.md analysis
