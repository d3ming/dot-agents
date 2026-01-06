.PHONY: help setup build lint clean sync link-skill

# Default target
help:
	@echo "Usage:"
	@echo "  make setup    - One-time installation: install symlinks and bootstrap configs"
	@echo "  make build    - Relink shared skills + compile agent configs (run after editing skills)"
	@echo "  make link-skill NAME=<skill> - Link master skill into Codex+Claude"
	@echo "  make sync     - Sync Gemini configs from ~/.gemini back to the repository"
	@echo "  make lint     - Run secret scanning (gitleaks)"
	@echo "  make clean    - Remove generated build artifacts"

setup:
	@echo "🚀 Starting installation..."
	@$(MAKE) build
	@./scripts/install.sh

sync:
	@echo "🔄 Syncing Gemini configs..."
	@./scripts/sync-to-repo.sh

build:
	@echo "🔨 Building Gemini config..."
	@echo "🔗 Linking shared skills..."
	@./scripts/link-skill.sh
	@echo "# AUTO-GENERATED FILE. DO NOT EDIT." > gemini/.gemini/GEMINI.md
	@cat master/AGENTS.md >> gemini/.gemini/GEMINI.md
	@echo "" >> gemini/.gemini/GEMINI.md
	@cat master/gemini-extra.md >> gemini/.gemini/GEMINI.md
	@echo "✅ gemini/.gemini/GEMINI.md built."
	@echo "🔨 Compiling templates..."
	@./scripts/compile-gemini.py

link-skill:
	@./scripts/link-skill.sh $(NAME)

lint:
	@echo "🔍 Running gitleaks..."
	@gitleaks detect --source . -v

clean:
	@echo "🧹 Cleaning up generated commands..."
	@rm -rf gemini/.gemini/commands/*.toml
