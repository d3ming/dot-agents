# GEMINI.md: Gemini-specific additions (writable by Gemini).

IMPORTANT: This file intentionally does NOT include the shared agent rules.
At the start of each Gemini session, run the `init-agent` command to load:
`master/AGENTS.md`.

## Gemini-specific notes
- This file is writable by Gemini; avoid putting shared rules here.
- Keep instructions short and minimal; shared rules live in `master/AGENTS.md`.

## Gemini Added Memories
- The project uses .tmp/ for temporary files, logs/ for detailed execution/audit logs, and reports/ for summary reports. .geminiignore is configured to allow reading of these folders.
