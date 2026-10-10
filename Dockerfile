# Custom RunPod ComfyUI image. ComfyUI is still started by the official /start.sh.
FROM runpod/comfyui:cuda13.0

USER root
COPY flux-provision.sh /opt/flux-provision.sh

# Add the downloader's dependencies, then run provisioning after the official
# start script has initialized ComfyUI and activated its Python environment.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git curl ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    chmod 755 /opt/flux-provision.sh; \
    grep -q '^log_cuda_venv_diagnostics$' /start.sh; \
    sed -i '/^log_cuda_venv_diagnostics$/i source /opt/flux-provision.sh' /start.sh
