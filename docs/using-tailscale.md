# Using Tailscale with Ollama

Tailscale creates a secure, private network (tailnet) for accessing Ollama remotely without exposing public ports. It’s like a private tunnel for your AI server.

## Why Use Tailscale?
- **Secure Access**: Connect to Ollama from any device in your tailnet safely.
- **Simple Setup**: Minimal configuration with an auth key.
- **Custom Names**: Use `CONTAINER_NAME_SUFFIX` (e.g., `-small`) for unique hostnames like `ollama-small`.

## Setup Steps
1. **Get a Tailscale Account**: Sign up at [tailscale.com](https://tailscale.com) (free, no credit card required).
2. **Generate an Auth Key**:
   - Log in to the Tailscale admin console.
   - Go to Settings > Keys, click "Generate auth key," select "Reusable," and set an expiration (optional).
   - Copy the key (starts with `tskey-auth-`).
3. **Add the Key Locally**:
   - Create the file specified in `TSAUTHKEY_PATH` (default: `~/.secrets/ollama-tsauthkey.key`):
     ```bash
     mkdir -p ~/.secrets
     echo "tskey-auth-yourkeyhere" > ~/.secrets/ollama-tsauthkey.key
     ```
   - This file is ignored by Git for security.
4. **Customize (Optional)**:
   - In `.env`, set `CONTAINER_NAME_SUFFIX` (e.g., `CONTAINER_NAME_SUFFIX=-small`) for a hostname like `ollama-small`.
5. **Start Ollama with Tailscale**:
   - For CPU: `docker compose -f docker-compose.yml -f docker-compose.add.tailscale.yml --profile cpu up -d`
   - For NVIDIA GPU: `docker compose -f docker-compose.yml -f docker-compose.add.tailscale.yml --profile gpu-nvidia up -d`
   - For AMD GPU: `docker compose -f docker-compose.yml -f docker-compose.add.tailscale.yml --profile gpu-amd up -d`
   - For Traefik+Tailscale: Use `-f docker-compose.add.traefik-tailscale.yml` instead.
   - A sidecar container (e.g., `ollama-tailscale-small-ts`) connects Ollama to your tailnet.

## Accessing Ollama
- Find the Tailscale hostname (e.g., `ollama-small.yourtailnet.ts.net`) in the Tailscale admin console (Machines page).
- Test with: `curl http://ollama-small.yourtailnet.ts.net:11434/api/tags`.
- Access from any tailnet device without local ports.

## Troubleshooting
- **Logs**: Check `docker logs ollama-tailscale-small-ts` for "Logged in" confirmation.
- **Key Issues**: Ensure the auth key is reusable and not expired. Regenerate if needed.
- **Network Errors**: Avoid setting ports in `add.tailscale.yml` or `add.traefik-tailscale.yml`—Tailscale uses the tailnet.

For more, see [Tailscale docs](https://tailscale.com/docs).