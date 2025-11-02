#!/usr/bin/env python3
"""
Download Stable Video Infinity LoRA models from HuggingFace.

This script downloads the SVI LoRA models required for infinite-length
video generation with WAN 2.1 in ComfyUI.
"""

import os
import sys
import urllib.request
from pathlib import Path


# SVI LoRA models to download
SVI_MODELS = {
    "svi-shot_lora_rank_128_fp16.safetensors": {
        "url": "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/svi-shot_lora_rank_128_fp16.safetensors",
        "description": "SVI-Shot: Single-scene generation from image + text",
        "size": "~250 MB"
    },
    "svi-film_lora_rank_128_fp16.safetensors": {
        "url": "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/svi-film_lora_rank_128_fp16.safetensors",
        "description": "SVI-Film: Multi-scene generation with prompt streams",
        "size": "~250 MB"
    },
    "svi-film-transitions_lora_rank_128_fp16.safetensors": {
        "url": "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/svi-film-transitions_lora_rank_128_fp16.safetensors",
        "description": "SVI-Film-Transitions: Enhanced scene transitions",
        "size": "~250 MB"
    },
    "svi-dance_lora_rank_128_fp16.safetensors": {
        "url": "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Stable-Video-Infinity/svi-dance_lora_rank_128_fp16.safetensors",
        "description": "SVI-Dance: Skeleton-conditioned human animation",
        "size": "~250 MB"
    }
}


def download_file(url: str, destination: Path, description: str):
    """Download a file with progress indication."""
    print(f"\nDownloading: {description}")
    print(f"URL: {url}")
    print(f"Destination: {destination}")

    if destination.exists():
        print(f"✓ File already exists, skipping download")
        return True

    try:
        def progress_hook(count, block_size, total_size):
            """Display download progress."""
            percent = int(count * block_size * 100 / total_size)
            sys.stdout.write(f"\rProgress: {percent}%")
            sys.stdout.flush()

        urllib.request.urlretrieve(url, destination, reporthook=progress_hook)
        print(f"\n✓ Successfully downloaded!")
        return True

    except Exception as e:
        print(f"\n✗ Error downloading file: {e}")
        if destination.exists():
            destination.unlink()
        return False


def main():
    """Main download function."""
    # Determine the models directory
    script_dir = Path(__file__).parent
    models_dir = script_dir.parent / "models" / "loras" / "stable-video-infinity"

    # Create directory if it doesn't exist
    models_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 80)
    print("Stable Video Infinity LoRA Model Downloader")
    print("=" * 80)
    print(f"\nModels will be saved to: {models_dir}")
    print(f"\nTotal models to download: {len(SVI_MODELS)}")
    print("\nNote: Each model is approximately 250 MB. Total download size: ~1 GB")

    # Ask for confirmation
    response = input("\nProceed with download? (y/n): ").strip().lower()
    if response != 'y':
        print("Download cancelled.")
        return

    # Download each model
    success_count = 0
    failed_models = []

    for filename, info in SVI_MODELS.items():
        destination = models_dir / filename

        if download_file(info["url"], destination, info["description"]):
            success_count += 1
        else:
            failed_models.append(filename)

    # Summary
    print("\n" + "=" * 80)
    print("Download Summary")
    print("=" * 80)
    print(f"✓ Successfully downloaded: {success_count}/{len(SVI_MODELS)} models")

    if failed_models:
        print(f"\n✗ Failed downloads:")
        for model in failed_models:
            print(f"  - {model}")
        print("\nYou can manually download failed models from:")
        print("https://huggingface.co/Kijai/WanVideo_comfy/tree/main/LoRAs/Stable-Video-Infinity")
    else:
        print("\n✓ All models downloaded successfully!")
        print("\nNext steps:")
        print("1. Install ComfyUI-WanVideoWrapper custom node")
        print("2. Load the SVI workflows from workflows/svi/ directory")
        print("3. Place WAN 2.1 base model in ComfyUI/models/wan/")

    print("\n" + "=" * 80)


if __name__ == "__main__":
    main()
