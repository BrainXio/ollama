# Ollama AI Server

Welcome to the `brainxio/ollama` repository! This project sets up an Ollama AI server using Docker Compose, with support for CPU, NVIDIA GPU, and AMD GPU. It’s designed to be easy to use, even if you’re new to Ollama or Docker.

## What is Ollama?

Ollama is an open-source platform for running large language models locally. It supports models like Qwen and Nomic Embed, with options for GPU acceleration to improve performance.

## Getting Started

### Prerequisites

* Docker and Docker Compose installed.
* For GPU support: NVIDIA CUDA or AMD ROCm drivers.
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

3) Start Ollama

   Choose a profile based on your hardware:

   - CPU: `docker compose --profile cpu up -d`
   - NVIDIA GPU: `docker compose --profile gpu-nvidia up -d`
   - AMD GPU: `docker compose --profile gpu-amd up -d`

   This starts Ollama and pulls initial models (Qwen2.5 7B Instruct, Nomic Embed Text).

4) Access Ollama

   The Ollama API is available on the configured host port (default: 11434). Test it with:

   ```bash
   curl http://localhost:11434/api/tags
   ```

   If you set a different `OLLAMA_HOST_PORT` in `.env`, use that port in the URL (e.g., `curl http://localhost:YOUR_PORT/api/tags`).

5) Linting (Optional)

   Validate YAML files using the provided config:

   ```bash
   yamllint docker-compose.yml
   ```

## Additional Files

- `LICENSE`: MIT License.
- `.github/`: GitHub workflows (e.g., CI for linting and validation).
- `.yamllint.yml`: YAML linting configuration.
- `.env.example`: Template for environment variables.
- `CHANGELOG.md`: Tracks project updates.