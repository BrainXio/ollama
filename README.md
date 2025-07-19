# Ollama AI Server

Welcome to the `brainxio/ollama` repository! This project sets up an Ollama AI server using Docker Compose, with support for CPU, NVIDIA GPU, and AMD GPU. It’s designed to be easy to use, even if you’re new to Ollama or Docker.

## What is Ollama?

Ollama is an open-source platform for running large language models locally. It supports models like Qwen and Nomic Embed, with options for GPU acceleration to improve performance.

## Getting Started

### Prerequisites

* Docker and Docker Compose installed.
* For GPU support: NVIDIA CUDA or AMD ROCm drivers.
* For Tailscale integration: A Tailscale account and a reusable auth key from the admin console (Settings > Keys).
* Basic command line familiarity.

### Setup Steps

1) Clone the Repository

   Clone the project and navigate to the directory:

   ```bash
   git clone https://github.com/brainxio/ollama.git
   cd ollama
   ```

2) Configure Environment (Optional)

   Copy the example file to create your own settings:

   ```bash
   cp .env.example .env
   ```

   Edit `.env` to customize Ollama settings (e.g., `OLLAMA_HOST`, `OLLAMA_MODELS`). Defaults are beginner-friendly.

3) Configure Tailscale (Optional)

   To enable Tailscale for secure networking:

   - Generate a reusable auth key in the Tailscale admin console (Settings > Keys).
   - Create a `secrets/` directory and add your auth key to `secrets/tailscale_authkey.txt`:

     ```bash
     mkdir secrets
     echo "tskey-auth-abc123xyz789" > secrets/tailscale_authkey.txt
     ```

     Replace `tskey-auth-abc123xyz789` with your actual key.

4) Start Ollama

   Choose a profile and networking mode based on your hardware:

   - CPU (local ports): `docker compose --profile cpu -f docker-compose.yml -f docker-compose.extend.local-ports.yml up -d`
   - NVIDIA GPU (local ports): `docker compose --profile gpu-nvidia -f docker-compose.yml -f docker-compose.extend.local-ports.yml up -d`
   - AMD GPU (local ports): `docker compose --profile gpu-amd -f docker-compose.yml -f docker-compose.extend.local-ports.yml up -d`
   - CPU (with Tailscale): `docker compose --profile cpu --profile tailscaled -f docker-compose.yml -f docker-compose.extend.tailscaled.yml up -d`
   - NVIDIA GPU (with Tailscale): `docker compose --profile gpu-nvidia --profile tailscaled -f docker-compose.yml -f docker-compose.extend.tailscaled.yml up -d`
   - AMD GPU (with Tailscale): `docker compose --profile gpu-amd --profile tailscaled -f docker-compose.yml -f docker-compose.extend.tailscaled.yml up -d`

   This starts Ollama, pulls initial models (configured in `.env`), and applies the chosen networking mode.

5) Access Ollama

   - With local ports: The Ollama API is available on the configured host port (default: 11434). Test it with:

     ```bash
     curl http://localhost:11434/api/tags
     ```

     If you set a different `OLLAMA_HOST_PORT` in `.env`, use that port (e.g., `curl http://localhost:YOUR_PORT/api/tags`).

   - With Tailscale: Find the Tailscale IP or MagicDNS hostname (e.g., `ollama-server.yourtailnet.ts.net`) in the Tailscale admin console (Machines page). Test it with:

     ```bash
     curl http://ollama-server.yourtailnet.ts.net:11434/api/tags
     ```

6) Linting (Optional)

   Validate YAML files using the provided config:

   ```bash
   yamllint docker-compose.yml
   yamllint docker-compose.extend.local-ports.yml
   yamllint docker-compose.extend.tailscaled.yml
   ```

## Additional Files

- `LICENSE`: MIT License.
- `.github/`: GitHub workflows (e.g., CI for linting and validation).
- `.yamllint.yml`: YAML linting configuration.
- `.env.example`: Template for environment variables.
- `CHANGELOG.md`: Tracks project updates.
- `docker-compose.extend.local-ports.yml`: Optional override for local port access.
- `docker-compose.extend.tailscaled.yml`: Optional override for Tailscale networking.
- `secrets/tailscale_authkey.txt`: Placeholder for Tailscale auth key.