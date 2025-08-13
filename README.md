# brainxio/ollama

## Overview
This repository contains the configuration and documentation for deploying Ollama, an open-source platform for running large language models locally. It includes modular Docker Compose setups with overrides for Tailscale, Traefik, ports, and volumes, supporting CPU, NVIDIA GPU, and AMD GPU.

## Quick Start
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/brainxio/ollama.git
   cd ollama
   ```
2. **Set Up Environment**:
   - Copy `.env.example` to `.env` and configure: `CONTAINER_NAME_SUFFIX=-small`, `TSAUTHKEY_PATH=~/.secrets/ollama-tsauthkey.key`, `DOMAIN=yourdomain.com`, `IP_WHITELIST=your_ip/32`, `OLLAMA_BASE_MODEL`, `OLLAMA_EMBEDDING_MODEL` (if needed).
   - For Tailscale, create the auth key file:
     ```bash
     mkdir -p ~/.secrets
     echo "tskey-auth-abc123xyz789" > ~/.secrets/ollama-tsauthkey.key
     ```
3. **Launch the Stack**:
   - Base (local bind `./ollama_data`): `docker compose up -d`
   - Add Ports (local bind): `docker compose -f docker-compose.yml -f docker-compose.add.ports.yml --profile cpu up -d`
   - Add Ports (GPU, local bind): `docker compose -f docker-compose.yml -f docker-compose.add.ports.yml --profile gpu-nvidia up -d` or `--profile gpu-amd`
   - Add Volume (`ollama-data`): `docker compose -f docker-compose.yml -f docker-compose.add.volume.yml --profile cpu up -d`
   - Add Tailscale: `docker compose -f docker-compose.yml -f docker-compose.add.tailscale.yml --profile cpu up -d`
   - Add Traefik: `docker compose -f docker-compose.yml -f docker-compose.add.traefik.yml --profile cpu up -d`
   - Add Traefik-Tailscale: `docker compose -f docker-compose.yml -f docker-compose.add.traefik-tailscale.yml --profile cpu up -d`
   - Add Traefik-Tailscale-Volume: `docker compose -f docker-compose.yml -f docker-compose.add.traefik-tailscale.yml -f docker-compose.add.volume.yml --profile cpu up -d`
   - Check status: `docker compose ps`
4. **Access**:
   - Local: `http://localhost:11434/api/tags` (with ports, use `OLLAMA_HOST_PORT` if customized).
   - Traefik: `https://ollama.yourdomain.com/api/tags` (set `DOMAIN` in `.env`).
   - Tailscale: Use Tailscale hostname (e.g., `ollama-small.yourtailnet.ts.net:11434`, based on `CONTAINER_NAME_SUFFIX`).

## Directory Structure
```
.
├── docker-compose.yml              # Base Ollama configuration with CPU/GPU profiles
├── docker-compose.add.ports.yml    # Adds local port mapping
├── docker-compose.add.volume.yml   # Switches to Docker volume ollama-data
├── docker-compose.add.tailscale.yml # Adds Tailscale networking
├── docker-compose.add.traefik.yml  # Adds Traefik routing
├── docker-compose.add.traefik-tailscale.yml # Combines Traefik with Tailscale
├── .env.example                    # Environment variable template
├── .gitignore                      # Ignores sensitive files
├── .yamllint.yml                   # YAML linting configuration
├── CHANGELOG.md                    # Tracks project updates
├── LICENSE                         # MIT License
└── secrets/                        # Directory for Tailscale auth key
```

## Features
- **Modular Overrides**: Combine Tailscale, Traefik, ports, or volumes (local bind `./ollama_data` or Docker volume `ollama-data`) as needed.
- **GPU Support**: Profiles for CPU, NVIDIA GPU, and AMD GPU.
- **Flexible Networking**: Local ports, Tailscale for secure remote access, or Traefik for reverse proxy with HTTPS.

## Troubleshooting
- **Network Issues**: Check Traefik logs and ensure `traefik-net` network exists.
- **Tailscale Problems**: Verify `TSAUTHKEY_PATH` points to a valid auth key and check Tailscale admin console.
- **Access Errors**: Ensure `.env` settings (`OLLAMA_HOST_PORT`, `DOMAIN`, `IP_WHITELIST`) match your setup.
- **Volume Issues**: Confirm `./ollama_data` exists for local bind or use `add.volume.yml` for `ollama-data`.

## Contributing
Fork the repository, make your changes, and submit a pull request. Open issues for bugs or feature ideas.

## License
[LICENSE](LICENSE) - MIT License.