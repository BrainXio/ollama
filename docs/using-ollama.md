# Using Ollama

Ollama is like a friendly toolbox for running AI models on your own computer, without needing fancy cloud services. It's open-source, which means anyone can peek at how it works or make it better.

## What Can Ollama Do?
- Run popular AI models like Llama, Qwen, or Gemma right on your machine.
- Use your computer's GPU (if you have one) to make things faster.
- Chat with models, generate text, or even build custom apps.

## Official Resources
- **GitHub Repository**: The main home for Ollama's code is at github.com/ollama/ollama. You can find the source code, report bugs, or see what's new there.
- **Model Registry**: Ollama models are hosted at registry.ollama.ai, where you can pull them from. Browse the library at ollama.com/library to see available models like Llama 3.2 or Qwen 2.5.

## Tips for Using Ollama in This Repo
- **Start Simple**: Use the commands in README.md to launch Ollama with your hardware (CPU, NVIDIA, or AMD).
- **Customize Models**: Edit `OLLAMA_BASE_MODEL` and `OLLAMA_EMBEDDING_MODEL` in `.env` to try different models.
- **Access the API**: Once running, test with `curl http://localhost:11434/api/tags` to list loaded models.
- **Integrate with Tailscale**: For remote access, add `docker-compose.extend.tailscaled.yml` as described in README.md or docs/using-tailscale.md.

For more on Ollama, visit ollama.com or their GitHub. If you're new, start with their quickstart guide—it's super easy!