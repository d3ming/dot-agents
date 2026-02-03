# PERMISSIONS.md: Canonical Permission Reference

**Purpose**: Define system-level permission defaults for all AI agents
**Scope**: Claude, Codex, Gemini
**Philosophy**: Hybrid allowlist + denylist approach

---

## Permission Philosophy

AI agents need filesystem and shell access to be productive, but unrestricted access creates risk. Our approach:

1. **Allowlist** common safe commands that agents use frequently
2. **Denylist** known-dangerous patterns that should never auto-run
3. **Prompt** for everything else (edge cases, ambiguous operations)

This balances productivity (fewer prompts) with safety (no destructive commands).

---

## Allowed Commands

Commands that bypass confirmation prompts. Agents can run these automatically.

### Build Tools
```bash
make              # Project build system
make <target>     # Any make target
```
**Rationale**: Central to development workflow; typically safe

### Git - Read Operations
```bash
git status        # Check working tree status
git diff          # Show changes
git log           # View commit history
git branch        # List/manage branches
```
**Rationale**: Read-only; no risk of data loss

### Git - Write Operations
```bash
git add           # Stage changes
git commit        # Create commits
git push          # Push to remote
git pull          # Pull from remote
git fetch         # Fetch from remote
git checkout      # Switch branches/restore files
git switch        # Switch branches (modern)
git merge         # Merge branches
git rebase        # Rebase branches (non-interactive)
git cherry-pick   # Cherry-pick commits
gh <cmd>          # GitHub CLI operations
```
**Rationale**: Core workflow operations; user typically initiates via conversation
**Note**: Agents should still confirm before pushing (per AGENTS.md protocol)

### File Operations - Safe
```bash
ls                # List directory contents
cat               # Display file contents
find              # Search for files
grep              # Search within files
rg                # Ripgrep (faster grep)
head              # Display file start
tail              # Display file end
wc                # Word/line count
tree              # Directory tree view
pwd               # Print working directory
mkdir             # Create directories
mv                # Move/rename files
cp                # Copy files
touch             # Create empty files
```
**Rationale**: Essential for file navigation and organization; low risk

### Language Runtimes
```bash
python            # Python interpreter
python3           # Python 3 interpreter
node              # Node.js runtime
npm               # Node package manager
pnpm              # Fast npm alternative
poetry            # Python dependency manager
uv                # Fast Python package installer
```
**Rationale**: Required for running code and managing dependencies

---

## Denied Commands

Commands that are **forbidden** and will be blocked entirely. Agents cannot run these even with user approval (user must run manually).

### Destructive File Operations
```bash
rm -rf            # Recursive force delete
rm -r             # Recursive delete
rmdir             # Remove directory
```
**Risk**: Irreversible data loss
**Mitigation**: User must run manually if truly needed

### Destructive Git Operations
```bash
git push --force  # Force push (rewrites history)
git push -f       # Force push (short form)
git reset         # Reset commits (loses work)
git restore       # Discard uncommitted changes
git clean         # Delete untracked files
git stash         # Stash changes (can lose work if misused)
git filter-branch # Rewrite history
git rebase -i     # Interactive rebase (history rewriting)
```
**Risk**: Loss of uncommitted work or history rewriting
**Mitigation**: Per AGENTS.md, these require explicit user request
**Exception**: Auto-stash during pull/rebase is acceptable (Git-initiated)

### System-Level Risks
```bash
sudo              # Superuser operations
chmod 777         # Overly permissive file permissions
chown             # Change file ownership
dd                # Low-level disk operations
mkfs              # Format filesystem
```
**Risk**: System-level changes, potential security vulnerabilities
**Mitigation**: Never allow agents to run privileged commands

### Arbitrary Code Execution
```bash
curl | bash       # Download and execute script
wget -O - | sh    # Download and execute script
```
**Risk**: Arbitrary code execution from untrusted sources
**Mitigation**: Block piped execution patterns

---

## Prompt Zone (Confirmation Required)

Commands not in allowlist or denylist require user confirmation:

### Git - Advanced Operations
```bash
git commit --amend    # Amend last commit (rewrites history)
git revert            # Revert commits
git tag               # Create tags
```
**Rationale**: Less common; user should explicitly approve

### File Operations - Potentially Risky
```bash
rm <file>             # Delete single file (without -rf)
chmod <mode>          # Change permissions (non-777)
ln -s                 # Create symlinks
```
**Rationale**: Can cause issues if misused; worth confirming

### System Operations
```bash
brew install          # Install system packages
apt install           # Install system packages
pip install           # Install Python packages globally
```
**Rationale**: Modifies system state; user should be aware

---

## Agent-Specific Syntax

### Claude Code
```json
{
  "permissions": {
    "allow": [
      "Bash(command:*)",     // Command with any arguments
      "Bash(command)",       // Command with no arguments
      "Edit",                // File editing
      "WebSearch"            // Web search
    ],
    "deny": [
      "Bash(dangerous:*)"    // Block dangerous commands
    ]
  }
}
```

### Codex CLI
```toml
[[rule]]
pattern = "command *"
decision = "allow"      # allow | prompt | forbidden

[[rule]]
pattern = "dangerous *"
decision = "forbidden"
```

### Gemini CLI
```json
{
  "tools": {
    "allowed": [
      "run_command(command)"
    ]
  }
}
```

---

## Alignment with AGENTS.md

These permissions enforce the protocols defined in `master/AGENTS.md`:

| AGENTS.md Protocol | Permission Implementation |
|-------------------|---------------------------|
| "Safe by default: git status/diff/log" | ✅ Allowlist read-only git |
| "Push only when user asks" | ⚠️ Allow push (rely on agent protocol) |
| "Destructive ops forbidden unless explicit" | ✅ Denylist rm -rf, reset, clean, restore |
| "No manual git stash" | ✅ Denylist git stash |
| "No amend unless asked" | ✅ Prompt for git commit --amend |
| "Branch changes require consent" | ✅ Allowlist checkout/switch (user initiates) |

---

## Testing Permissions

### Claude Code
No built-in test command; verify by observing agent behavior.

### Codex CLI
```bash
codex execpolicy check "git commit -m 'test'"
# Output: allowed

codex execpolicy check "rm -rf /"
# Output: forbidden
```

### Gemini CLI
No built-in test command; verify by observing agent behavior.

---

## Maintenance

### When to Update Permissions

1. **New tool adoption**: Add to allowlist if safe and frequently used
2. **Security incident**: Add to denylist if command caused issues
3. **Workflow changes**: Adjust based on team feedback
4. **Agent updates**: Review when agents gain new capabilities

### Update Process

1. Propose changes in this document
2. Update agent-specific configs:
   - `claude/.claude/settings.json`
   - `codex/.codex/rules/default.rules`
   - `gemini/.gemini/settings.json`
3. Test with `make validate-permissions` (when implemented)
4. Document in changelog below

---

## Changelog

- **2026-01-21**: Initial permissions defined based on allow-deny-guide.md

---

## References

- [allow-deny-guide.md](../docs/allow-deny-guide.md) - Comprehensive guide
- [AGENTS.md](./AGENTS.md) - Shared agent protocol
- [permission-defaults-plan.md](../docs/permission-defaults-plan.md) - Implementation plan
