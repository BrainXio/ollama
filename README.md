# brainxio/ollama

## Overview
This repository provides a Docker Compose configuration for deploying Ollama, an open-source platform for running large language models locally. The setup supports CPU, NVIDIA GPU, and AMD GPU environments, with optional Tailscale for secure remote access and Traefik for HTTPS routing. It is designed to be modular, using profiles to select specific configurations, and is accessible to users with minimal Docker experience.

### Services
- **ollama-cpu**: Runs Ollama on CPU, binding to `127.0.0.1:11434` for local access.
- **ollama-gpu**: Runs Ollama on NVIDIA GPU, using GPU acceleration for faster model processing.
- **ollama-gpu-amd**: Runs Ollama on AMD GPU with ROCm support for GPU-accelerated models.
- **ollama-init-pull-cpu/gpu/gpu-amd**: Pulls specified models (e.g., `smollm2`) after the corresponding Ollama service starts, ensuring models are ready for use.
- **ollama-cpu-tailscale/gpu-tailscale/gpu-amd-tailscale**: Runs Ollama with Tailscale networking for secure remote access, using `network_mode: service:tailscale` to route traffic through the Tailscale service.
- **tailscale**: Provides secure, encrypted networking for remote access, with optional Traefik integration for HTTPS routing.

## Quick Start
Follow these steps to deploy Ollama:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/brainxio/ollama.git
   cd ollama
   ```
   This downloads the configuration files to your local machine.

2. **Set Up Environment**:
   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Edit `.env` to configure variables:
     - `OLLAMA_PORT=127.0.0.1:11434`: Binds Ollama to localhost on port 11434 (default).
     - `OLLAMA_VOLUME=ollama-data`: Uses a Docker volume for model storage (default). Set to `./ollama_data` for a local directory.
     - `TSAUTHKEY_PATH=tsauthkey`: Path to the Tailscale authentication key file.
     - `OLLAMA_NAME_SUFFIX=`: Optional suffix for Tailscale hostname (e.g., `-small` for `ollama-small`).
     - `OLLAMA_VERSION=latest`: Ollama image version (default).
     - `TAILSCALE_VERSION=stable`: Tailscale image version (default).
     - `OLLAMA_NETWORK_NAME=ollama-net`: Docker network name (default).
     - `OLLAMA_NETWORK_EXTERNAL=false`: Creates a new network (default). Set to `true` if using an existing network.
     - `OLLAMA_ENABLE_TRAEFIK=false`: Disables Traefik by default. Set to `true` for HTTPS routing.
     - `DOMAIN=yourdomain.com`: Required if `OLLAMA_ENABLE_TRAEFIK=true` for HTTPS access.
     - `IP_WHITELIST=0.0.0.0/0`: Allows all IPs for Traefik (default). Restrict to specific IPs (e.g., `192.168.1.0/24`) for security.
     - `OLLAMA_BASE_MODEL=smollm2`, `OLLAMA_EMBEDDING_MODEL=smollm2`, etc.: Models to pull (default: `smollm2`).
   - For Tailscale, create the auth key file:
     ```bash
     mkdir -p ~/.secrets
     echo "tskey-auth-abc123xyz789" > ~/.secrets/ollama-tsauthkey.key
     ```
   - If `OLLAMA_NETWORK_EXTERNAL=true`, create the network:
     ```bash
     docker network create ollama-net
     ```

3. **Launch the Stack**:
   Use Docker Compose profiles to deploy the desired configuration:
   - CPU with Docker volume:
     ```bash
     docker compose --profile cpu up -d
     ```
     Starts `ollama-cpu` and `ollama-init-pull-cpu`, using `ollama-data` volume.
   - CPU with Tailscale:
     ```bash
     docker compose --profile tailscale-cpu up -d
     ```
     Starts `ollama-cpu-tailscale`, `ollama-init-pull-cpu`, and `tailscale`.
   - NVIDIA GPU with local volume:
     ```bash
     echo "OLLAMA_VOLUME=./ollama_data" >> .env
     docker compose --profile gpu-nvidia up -d
     ```
     Starts `ollama-gpu` and `ollama-init-pull-gpu`, using `./ollama_data`.
   - AMD GPU with Tailscale and Traefik:
     ```bash
     echo "OLLAMA_ENABLE_TRAEFIK=true" >> .env
     echo "DOMAIN=yourdomain.com" >> .env
     docker compose --profile tailscale-gpu-amd up -d
     ```
     Starts `ollama-gpu-amd-tailscale`, `ollama-init-pull-gpu-amd`, and `tailscale` with Traefik routing.
   - Check running services:
     ```bash
     docker compose ps
     ```

4. **Access Ollama**:
   - Local: `http://localhost:11434/api/tags` (uses `OLLAMA_PORT=127.0.0.1:11434`).
   - Tailscale: `http://ollama.yourtailnet.ts.net:11434/api/tags` (or `ollama-small.yourtailnet.ts.net:11434` if `OLLAMA_NAME_SUFFIX=-small`).
   - Traefik: `https://ollama.yourdomain.com/api/tags` (requires `OLLAMA_ENABLE_TRAEFIK=true` and `DOMAIN` set).

### Security Considerations
Security is critical when deploying Ollama to protect your server and data:
- **Restrict Local Access**: The default `OLLAMA_PORT=127.0.0.1:11434` binds to localhost, preventing external access. Avoid setting `OLLAMA_PORT=11434` unless necessary, as it exposes the service publicly.
- **Use Tailscale**: Tailscale provides encrypted, secure remote access. Ensure `TSAUTHKEY_PATH` points to a secure file, and store the auth key in a protected location (e.g., `~/.secrets` with restricted permissions).
- **Enable Traefik with IP Whitelisting**: Set `OLLAMA_ENABLE_TRAEFIK=true` and configure `IP_WHITELIST` to limit access to trusted IP ranges (e.g., `192.168.1.0/24`). Avoid `0.0.0.0/0` in production to prevent unauthorized access.
- **Secure Model Storage**: Use `OLLAMA_VOLUME=ollama-data` for a managed Docker volume to avoid exposing model data in a local directory. If using `./ollama_data`, ensure the directory has restricted permissions.
- **Keep Images Updated**: Use `OLLAMA_VERSION=latest` and `TAILSCALE_VERSION=stable` to receive security patches, but test updates in a non-production environment first.

## Directory Structure
```
.
├── docker-compose.yml              # Consolidated configuration for Ollama, supporting CPU/GPU, Tailscale, and Traefik
├── docs/
│   ├── using-ollama.md            # Guide for using Ollama
│   ├── using-tailscale.md         # Guide for Tailscale setup
├── .env.example                    # Environment variable template
├── .gitignore                      # Ignores sensitive files
├── .yamllint.yml                   # YAML linting configuration
├── CHANGELOG.md                    # Tracks project updates
├── LICENSE                         # MIT License
└── secrets/                        # Directory for Tailscale auth key
```

## Features
- **Modular Profiles**: Select configurations using profiles (`cpu`, `gpu-nvidia`, `gpu-amd`, `tailscale-cpu`, `tailscale-gpu-nvidia`, `tailscale-gpu-amd`).
- **Flexible Storage**: Store models in a Docker volume (`ollama-data`) or local directory (`./ollama_data`) via `OLLAMA_VOLUME`.
- **GPU Support**: Profiles for CPU, NVIDIA GPU, and AMD GPU (ROCm).
- **Secure Networking**: Local access via `127.0.0.1`, Tailscale for encrypted remote access, or Traefik for HTTPS routing with IP whitelisting.

## Troubleshooting
- **Network Issues**: Verify `ollama-network` exists if `OLLAMA_NETWORK_EXTERNAL=true` (`docker network ls`). Check Traefik logs if `OLLAMA_ENABLE_TRAEFIK=true`.
- **Tailscale Problems**: Ensure `TSAUTHKEY_PATH` points to a valid auth key and check the Tailscale admin console for connection issues.
- **Access Errors**: Confirm `.env` settings (`OLLAMA_PORT`, `DOMAIN`, `IP_WHITELIST`, `OLLAMA_ENABLE_TRAEFIK`) are correct. Test local access with `curl http://localhost:11434/api/tags`.
- **Volume Issues**: If using `OLLAMA_VOLUME=./ollama_data`, ensure the directory exists (`mkdir ollama_data`). For `ollama-data`, verify the volume exists (`docker volume ls`).

## License
[LICENSE](LICENSE) - MIT License.
