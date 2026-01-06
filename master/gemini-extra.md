## Commands & Tooling
- Prioritize `make` commands over direct script execution (e.g., `make setup` instead of `./scripts/install.sh`).
- Available `make` commands:
  - `make setup`: Full installation (symlinks + bootstrap configs).
  - `make build`: Compile templates into agent configs.
  - `make sync`: Sync Gemini configs from ~/.gemini back to repo.
  - `make lint`: Run secret scanning (gitleaks).
  - `make clean`: Remove generated artifacts.
