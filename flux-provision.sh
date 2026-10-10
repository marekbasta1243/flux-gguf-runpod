#!/usr/bin/env bash
# Sourced by the official RunPod start script immediately before ComfyUI launches.
set -e

COMFYUI_DIR="${COMFYUI_DIR:-/workspace/runpod-slim/ComfyUI}"
NODES_DIR="$COMFYUI_DIR/custom_nodes"

mkdir -p "$COMFYUI_DIR/models/unet" "$COMFYUI_DIR/models/vae" "$COMFYUI_DIR/models/clip" "$NODES_DIR"

fetch_model() {
  local url="$1"
  local dest="$2"
  local part="${dest}.part"

  if [ -s "$dest" ]; then
    echo "[FLUX setup] Already present: $dest"
    return 0
  fi

  echo "[FLUX setup] Downloading: $(basename "$dest")"
  if [ -s "$part" ]; then
    if ! curl -fL --retry 3 --retry-delay 2 -C - -o "$part" "$url"; then
      echo "[FLUX setup] Resume failed; retrying from beginning: $(basename "$dest")"
      rm -f "$part"
      curl -fL --retry 3 --retry-delay 2 -o "$part" "$url"
    fi
  else
    curl -fL --retry 3 --retry-delay 2 -o "$part" "$url"
  fi
  mv "$part" "$dest"
}

install_node() {
  local repo_url="$1"
  local node_name="$2"
  local node_dir="$NODES_DIR/$node_name"

  if [ ! -d "$node_dir/.git" ]; then
    if [ -e "$node_dir" ]; then
      rm -rf "$node_dir"
    fi
    echo "[FLUX setup] Cloning node: $node_name"
    git clone --depth 1 "$repo_url" "$node_dir"
  else
    echo "[FLUX setup] Node already present: $node_name"
  fi

  if [ -f "$node_dir/requirements.txt" ]; then
    echo "[FLUX setup] Installing Python requirements for $node_name"
    python -m pip install -r "$node_dir/requirements.txt"
  fi
}

install_node "https://github.com/city96/ComfyUI-GGUF.git" "ComfyUI-GGUF"
install_node "https://github.com/rgthree/rgthree-comfy.git" "rgthree-comfy"

fetch_model \
  "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q4_K_S.gguf" \
  "$COMFYUI_DIR/models/unet/flux1-dev-Q4_K_S.gguf"
fetch_model \
  "https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors" \
  "$COMFYUI_DIR/models/vae/ae.safetensors"
fetch_model \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" \
  "$COMFYUI_DIR/models/clip/clip_l.safetensors"
fetch_model \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors" \
  "$COMFYUI_DIR/models/clip/t5xxl_fp8_e4m3fn_scaled.safetensors"

echo "[FLUX setup] Models and custom nodes are ready. ComfyUI will now start."
