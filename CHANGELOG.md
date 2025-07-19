# Changelog

## [0.1.0] - 2025-07-18

- Initial release: Docker Compose setup for Ollama with CPU, NVIDIA GPU, and AMD GPU support. Ready to power your AI adventures!
- Added `.env.example` with documented variables, including `OLLAMA_BASE_MODEL` and `OLLAMA_INIT_MODEL` for picking your go-to models.
- Included YAML linting and GitHub workflows for validation, keeping our YAML crisp and clean.
- Added `docker-compose.extend.tailscaled.yml` for Tailscale integration, bringing secure tailnet access to Ollama with no public port exposure.
- Added `docker-compose.extend.local-ports.yml` to enable smooth local port access, moving ports from base `docker-compose.yml` to avoid Tailscale conflicts.
- Added `secrets/tailscale_authkey.txt` placeholder for secure Tailscale auth key storage, safely tucked away in `.gitignore`.
- Introduced `NAME_SUFFIX` in `.env.example` for consistent naming across containers and Tailscale hostname (e.g., `ollama-small`, `ollama-init-small`). Scope creep turned into a naming win!
- Fixed Tailscale authentication with `TS_EXTRA_ARGS` and `TS_USERSPACE=false` to ensure a login-free experience. No gatecrashers here!