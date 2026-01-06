.PHONY: help setup build lint clean

# Default target
help:
	@echo "Usage:"
	@echo "  make setup    - One-time installation: install symlinks and bootstrap configs"
	@echo "  make build    - Compile shared skills into agent configs (run after editing skills)"
	@echo "  make lint     - Run secret scanning (gitleaks)"
	@echo "  make clean    - Remove generated build artifacts"

setup:
	@echo "🚀 Starting installation..."
	@./scripts/install.sh
	@$(MAKE) build

build:
	@echo "🔨 Compiling templates..."
	@./scripts/compile-gemini.py

lint:
	@echo "🔍 Running gitleaks..."
	@gitleaks detect --source . -v

clean:
	@echo "🧹 Cleaning up generated commands..."
	@rm -rf gemini/.gemini/commands/*.toml
