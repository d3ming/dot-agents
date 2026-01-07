This folder contains reference repos


## Codex Settings Repos
- https://github.com/steipete/agent-scripts/

## Claude Code Settings Repos
- https://github.com/feiskyer/claude-code-settings
- https://github.com/fcakyon/claude-codex-settings

## Note:
We set up reference repos in this directory with `--depth 1` to avoid downloading the entire history. The reference repos themselves are gitignored.

```bash
# setup script
git clone --depth 1 git@github.com:steipete/agent-scripts.git
```
