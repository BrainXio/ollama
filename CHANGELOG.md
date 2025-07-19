# Changelog

## [0.1.0] - 2025-07-18

- Initial release: Docker Compose setup for Ollama with CPU, NVIDIA GPU, and AMD GPU support.
- Added `.env.example` with documented variables, including `OLLAMA_BASE_MODEL` and `OLLAMA_EMBEDDING_MODEL` for customizable model pulling.
- Included YAML linting and GitHub workflows for validation.
- Added `docker-compose.extend.tailscaled.yml` for optional Tailscale integration with secure networking via a sidecar container.
- Added `docker-compose.extend.local-ports.yml` for local port access, moving ports from base docker-compose.yml to avoid conflicts with Tailscale.
- Added `secrets/tailscale_authkey.txt` placeholder for Tailscale auth key, ignored in `.gitignore`.