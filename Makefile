.PHONY: help setup build lint clean link-skill

# Default target
help:
	@echo "Usage:"
	@echo "  make setup    - One-time installation: install symlinks and bootstrap configs"
	@echo "  make build    - Relink shared skills + compile Gemini commands (run after editing skills)"
	@echo "  make link-skill NAME=<skill> - Link master skill into Codex+Claude"
	@echo "  make lint     - Run secret scanning (gitleaks)"
	@echo "  make clean    - Remove generated build artifacts"

setup:
	@echo "🚀 Starting installation..."
	@$(MAKE) build
	@./scripts/install.sh

build:
	@echo "🔨 Building Gemini commands..."
	@echo "🔗 Linking shared skills..."
	@./scripts/link-skill.sh
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
