.PHONY: help setup build lint clean
.DEFAULT_GOAL := setup

# Default target
help:
	@echo "Usage:"
	@echo "  make          - Full install (idempotent); safe to run anytime"
	@echo "  make setup    - Full install (idempotent); safe to run anytime"
	@echo "  make build    - Relink shared skills + generate Gemini commands (run after editing skills)"
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

lint:
	@echo "🔍 Running gitleaks..."
	@gitleaks detect --source . -v

clean:
	@echo "🧹 Cleaning up generated commands..."
	@rm -rf gemini/.gemini/commands/*.toml
