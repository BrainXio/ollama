# Using Ollama

Ollama is an open-source platform for running AI models locally, supporting CPU and GPU acceleration for tasks like text generation and embeddings.

## What Can Ollama Do?
- Run models like Llama, Qwen, or Gemma on your machine.
- Leverage GPU (NVIDIA/AMD) for faster processing.
- Build chatbots, generate text, or integrate with apps via API.

## Official Resources
- **GitHub**: [github.com/ollama/ollama](https://github.com/ollama/ollama) for source code and issues.
- **Model Registry**: Browse models at [ollama.com/library](https://ollama.com/library), pull from [registry.ollama.ai](https://registry.ollama.ai).

## Tips for Using Ollama
- **Start**: Follow `README.md` to launch with CPU, NVIDIA GPU, or AMD GPU profiles.
- **Customize Models**: Set `OLLAMA_BASE_MODEL` and `OLLAMA_EMBEDDING_MODEL` in `.env` (e.g., `qwen2.5:7b-instruct-q4_K_M`, `nomic-embed-text`).
- **Access API**: Test with `curl http://localhost:11434/api/tags` (use `OLLAMA_HOST_PORT` if customized).
- **Secure Remote Access**: Use `docker-compose.add.tailscale.yml` or `docker-compose.add.traefik-tailscale.yml` (see [Using Tailscale](using-tailscale.md)).
- **Volume Options**: Default local bind (`./ollama_data`) or Docker volume (`ollama-data`) with `docker-compose.add.volume.yml`.

For more, visit [ollama.com](https://ollama.com) or their [quickstart guide](https://ollama.com/docs).