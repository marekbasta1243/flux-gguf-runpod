# ComfyUI FLUX GGUF pro RunPod — připravené zdrojové soubory

Tento projekt rozšiřuje oficiální obraz `runpod/comfyui:cuda13.0`. Ponechává jeho `/start.sh`; instalační skript se vloží do startu po inicializaci ComfyUI a aktivaci jeho Python prostředí.

Při startu Podu se pokusí nainstalovat uzly `ComfyUI-GGUF` a `rgthree-comfy` a stáhnout tyto soubory:
- `models/unet/flux1-dev-Q4_K_S.gguf`
- `models/vae/ae.safetensors`
- `models/clip/clip_l.safetensors`
- `models/clip/t5xxl_fp8_e4m3fn_scaled.safetensors`

## Co obsahuje balíček
- `Dockerfile` — recept pro sestavení vlastního obrazu.
- `flux-provision.sh` — instalace uzlů a stahování modelů při startu.
- `.github/workflows/publish-image.yml` — GitHub Actions sestaví obraz a publikuje jej do GitHub Container Registry (GHCR) při pushi do větve `main`.

## Důležité upozornění
Tento obraz nebyl v tomto prostředí otestován v reálném RunPod Podu. Neplať GPU za test, dokud nepotvrdíme úspěšné sestavení v GitHub Actions a nezkontrolujeme výsledný obraz.

Po úspěšném sestavení bude název obrazu přibližně `ghcr.io/TVE-UZIVATELSKE-JMENO/NAZEV-REPOZITARE:latest` (malými písmeny). GHCR může balíček vytvořit jako soukromý; pro použití bez přihlašovacích údajů jej lze v nastavení balíčku přepnout na Public. Nikdy nezveřejňuj tokeny ani hesla.

Modely se nestávají součástí Docker obrazu; stahují se při startu Podu. Bez trvalého úložiště se při novém Podu stáhnou znovu. Pokud se stahování nepodaří, skript díky `set -e` ukončí start a chybu uvidíš v logu — v takovém případě Pod nenechávej zbytečně běžet.
