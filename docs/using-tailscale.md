# Using Tailscale with Ollama

Tailscale is a super handy tool that creates a private network (called a tailnet) between your devices, so you can access Ollama securely from anywhere without exposing it to the open internet. It's like giving Ollama its own secret tunnel!

## Why Use Tailscale?
- **Secure Access**: Connect to Ollama from your phone, laptop, or another machine without worrying about public ports or firewalls.
- **Easy Setup**: No complicated VPN configs—just add a key and go.
- **Custom Names**: With `NAME_SUFFIX` in `.env`, you can name your Ollama instance something like "ollama-small" for easy spotting in your tailnet.

## Setup Steps
1. **Get a Tailscale Account**: Sign up for free at tailscale.com. It's quick and no credit card needed.

2. **Generate an Auth Key**:
   - Log in to the Tailscale admin console (tailscale.com/login).
   - Go to Settings > Keys and click "Generate auth key".
   - Choose "Reusable" so you can use it for multiple setups, and set it to expire if you want extra security.
   - Copy the key (it starts with "tskey-auth-").

3. **Add the Key Locally**:
   - Create a `secrets/` folder in your Ollama repo if it doesn't exist: `mkdir secrets`.
   - Save the key in `secrets/tailscale_authkey.txt`: `echo "tskey-auth-yourkeyhere" > secrets/tailscale_authkey.txt`.
   - This file is ignored by Git, so your key stays private.

4. **Customize (Optional)**:
   - In `.env`, set `NAME_SUFFIX` (e.g., `NAME_SUFFIX=-small`) to give your Ollama a unique name in Tailscale, like "ollama-small".

5. **Start Ollama with Tailscale**:
   - Use the command for your hardware, like for NVIDIA GPU: `docker compose -f docker-compose.yml -f docker-compose.extend.tailscaled.yml --profile gpu-nvidia up -d`.
   - Tailscale will start a sidecar container (e.g., "ollama-tailscale-small") and connect Ollama to your tailnet.

## Accessing Ollama
- Open the Tailscale admin console (Machines page) to find your Ollama's hostname (e.g., "ollama-small.yourtailnet.ts.net").
- Test it with: `curl http://ollama-small.yourtailnet.ts.net:11434/api/tags`.
- You can access it from any device in your tailnet—no local ports needed!

## Troubleshooting
- **Logs**: Check Tailscale logs with `docker logs ollama-tailscale-small` (replace with your suffix). Look for "Logged in" to confirm authentication.
- **Key Issues**: If it asks for login, double-check your auth key is reusable and not expired. Generate a new one if needed.
- **Conflicts**: If you see network errors, make sure no ports are set in `docker-compose.extend.tailscaled.yml`—Tailscale handles access via the tailnet.

For more on Tailscale, check their docs at tailscale.com/docs. Happy networking!