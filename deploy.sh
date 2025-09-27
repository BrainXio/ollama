#!/bin/bash

# Hardcoded base profiles
declare -a BASE_PROFILES=("cpu" "nvidia-gpu" "amd-gpu" "traefik-cpu" "traefik-nvidia-gpu" "traefik-amd-gpu" "tailscale-cpu" "tailscale-nvidia-gpu" "tailscale-amd-gpu")

# Function to detect NVIDIA GPU and Container Toolkit configuration
detect_nvidia() {
  if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi --query-gpu=name --format=csv,noheader >/dev/null 2>&1; then
    # Check daemon.json for NVIDIA runtime configuration
    if [ -f "$HOME/.config/docker/daemon.json" ]; then
      if grep -q '"nvidia"' "$HOME/.config/docker/daemon.json" && (grep -q '"path": *"nvidia-container-runtime"' "$HOME/.config/docker/daemon.json" || grep -q '"runtimeArgs": \[\]' "$HOME/.config/docker/daemon.json"); then
        echo "NVIDIA GPU and Container Toolkit configured"
        return 0
      fi
    elif [ -f "/etc/docker/daemon.json" ]; then
      if grep -q '"nvidia"' "/etc/docker/daemon.json" && (grep -q '"path": *"nvidia-container-runtime"' "/etc/docker/daemon.json" || grep -q '"runtimeArgs": \[\]' "/etc/docker/daemon.json"); then
        echo "NVIDIA GPU and Container Toolkit configured"
        return 0
      fi
    fi
    echo "NVIDIA GPU detected, but configuration in ~/.config/docker/daemon.json not found or incomplete"
    return 1
  else
    echo "NVIDIA GPU not detected"
    return 1
  fi
}

# Function to detect AMD ROCm GPU
detect_amd_rocm() {
  if command -v rocm-smi >/dev/null 2>&1 && rocm-smi --showhw >/dev/null 2>&1; then
    # Check for ROCm device access (simplified for root/rootless)
    if [ -e "/dev/dri" ] && [ -e "/dev/kfd" ]; then
      echo "AMD ROCm GPU detected"
      return 0
    else
      echo "Warning: AMD ROCm detected, but devices not accessible (root/rootless issue)"
      return 1
    fi
  else
    echo "AMD ROCm GPU not detected"
    return 1
  fi
}

# Filter applicable profiles based on hardware
declare -a APPLICABLE_PROFILES=()

for PROFILE in "${BASE_PROFILES[@]}"; do
  case "$PROFILE" in
    "cpu"|"traefik-cpu"|"tailscale-cpu")
      APPLICABLE_PROFILES+=("$PROFILE")  # Always applicable
      ;;
    "nvidia-gpu"|"traefik-nvidia-gpu"|"tailscale-nvidia-gpu")
      if detect_nvidia; then
        APPLICABLE_PROFILES+=("$PROFILE")
      fi
      ;;
    "amd-gpu"|"traefik-amd-gpu"|"tailscale-amd-gpu")
      if detect_amd_rocm; then
        APPLICABLE_PROFILES+=("$PROFILE")
      fi
      ;;
  esac
done

# Check if applicable profiles are available
if [ ${#APPLICABLE_PROFILES[@]} -eq 0 ]; then
  echo "Error: No applicable profiles available for this host"
  exit 1
fi

# Parse command line arguments for --version
VERSION_ARG=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --version=*)
      VERSION_ARG="${1#--version=}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# Set OLLAMA_VERSION
if [ -n "$VERSION_ARG" ]; then
  OLLAMA_VERSION="${VERSION_ARG#v}"  # Strip leading 'v' if present
  echo "Using specified version: $OLLAMA_VERSION"
else
  # Fetch the latest tagged release from GitHub
  LATEST_RELEASE=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest)
  if [ -n "$LATEST_RELEASE" ]; then
    OLLAMA_VERSION=$(echo "$LATEST_RELEASE" | grep -o '"tag_name": *"[^"]*' | grep -o '[^"]*$' | sed 's/^v//')
    if [ -n "$OLLAMA_VERSION" ]; then
      echo "Using latest tagged release: $OLLAMA_VERSION"
      # Extract and save release notes to ollama-deploy.md
      RELEASE_NOTES=$(echo "$LATEST_RELEASE" | grep -o '"body": *"[^"]*' | grep -o '[^"]*$' | sed 's/\\n/\n/g')
      if [ -n "$RELEASE_NOTES" ]; then
        echo -e "# Ollama Release Notes\n\n$RELEASE_NOTES" > ollama-deploy.md
        echo "Release notes saved to ollama-deploy.md"
      else
        echo "Warning: No release notes available for $OLLAMA_VERSION"
      fi
    else
      echo "Error: Could not determine latest tagged release, using default: latest"
      OLLAMA_VERSION="latest"
    fi
  else
    echo "Error: Failed to fetch latest release, using default: latest"
    OLLAMA_VERSION="latest"
  fi
fi

# Display menu and get user selection
echo "Applicable profiles based on host hardware:"
for i in "${!APPLICABLE_PROFILES[@]}"; do
  echo "$((i+1)). ${APPLICABLE_PROFILES[$i]}"
done
echo "0. Exit"
read -p "Select a profile (1-${#APPLICABLE_PROFILES[@]}, 0 to exit): " CHOICE

# Validate choice
if [ "$CHOICE" -eq 0 ]; then
  echo "Exiting..."
  exit 0
elif ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt ${#APPLICABLE_PROFILES[@]} ]; then
  echo "Error: Invalid selection"
  exit 1
fi

PROFILE=${APPLICABLE_PROFILES[$((CHOICE-1))]}
TAILSCALE_HOSTNAME="$(hostname)-ollama"

# Check for Tailscale profile and handle tsauthkey
if [[ "$PROFILE" == *"tailscale"* ]]; then
  TSAUTHKEY_PATH="${TSAUTHKEY_PATH:-./secrets/tsauthkey}"  # Default to ./secrets/tsauthkey if not set in .env
  if [ ! -f "$TSAUTHKEY_PATH" ]; then
    echo "Error: tsauthkey file not found at $TSAUTHKEY_PATH"
    echo "A Tailscale authentication key is required. Generate one at:"
    echo "https://login.tailscale.com/admin/authkeys"
    read -p "Would you like to create a new key now? (y/n): " CREATE_KEY
    if [ "$CREATE_KEY" = "y" ] || [ "$CREATE_KEY" = "Y" ]; then
      read -s -p "Enter the new Tailscale auth key: " NEW_KEY
      echo
      if [ -n "$NEW_KEY" ]; then
        echo "$NEW_KEY" > "$TSAUTHKEY_PATH"
        echo "tsauthkey created at $TSAUTHKEY_PATH"
        chmod 600 "$TSAUTHKEY_PATH"  # Secure permissions
      else
        echo "Error: No key provided, tsauthkey not created"
        exit 1
      fi
    else
      echo "Please create a tsauthkey file at $TSAUTHKEY_PATH and rerun the script"
      exit 1
    fi
  fi
fi

# Detect GPU for logging purposes only
if [[ "$PROFILE" == *"gpu"* ]]; then
  if [[ "$PROFILE" == *"nvidia"* ]]; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n 1)
    if [ -n "$GPU_NAME" ]; then
      echo "NVIDIA GPU detected: $GPU_NAME"
      VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -n 1)
      if [ -n "$VRAM_MB" ]; then
        VRAM_GB=$(( (VRAM_MB + 1023) / 1024 )) # Ceiling division
        echo "Raw GPU VRAM detected: ${VRAM_MB} MB"
      fi
    else
      echo "Warning: NVIDIA GPU not detected or nvidia-smi not available"
    fi
  elif [[ "$PROFILE" == *"amd"* ]]; then
    GPU_NAME=$(rocm-smi --showproductname 2>/dev/null | grep "Card model" | cut -d ':' -f2- | tr -d '[:space:]')
    if [ -n "$GPU_NAME" ]; then
      echo "AMD ROCm GPU detected: $GPU_NAME"
    else
      echo "Warning: AMD ROCm GPU not detected or rocm-smi not available"
    fi
  fi
else
  CPU_CORES=$(nproc)
  if [ -n "$CPU_CORES" ]; then
    echo "Detected CPU Cores: ${CPU_CORES}"
  else
    echo "Warning: Unable to detect CPU cores"
  fi
fi

# Echo the detection results for testing
echo "Selected Profile: $PROFILE"
echo "OLLAMA_VERSION: $OLLAMA_VERSION"
if [[ "$PROFILE" == *"gpu"* ]]; then
  if [[ "$PROFILE" == *"nvidia"* ]]; then
    echo "Detected GPU: ${GPU_NAME:-N/A}"
    echo "Detected GPU VRAM: ${VRAM_GB:-N/A} GB"
  else
    echo "Detected AMD ROCm GPU: ${GPU_NAME:-N/A}"
  fi
else
  echo "Detected CPU Cores: ${CPU_CORES:-N/A}"
fi
echo "Proposed TAILSCALE_HOSTNAME: $TAILSCALE_HOSTNAME"
if [[ "$PROFILE" == *"tailscale"* ]]; then
  echo "TSAUTHKEY_PATH: $TSAUTHKEY_PATH"
fi

# Export TAILSCALE_HOSTNAME and OLLAMA_VERSION for Docker Compose to use
export TAILSCALE_HOSTNAME
export OLLAMA_VERSION

# Deploy with Docker Compose, applying TAILSCALE_HOSTNAME and OLLAMA_VERSION
docker compose --profile "$PROFILE" up -d --force-recreate
