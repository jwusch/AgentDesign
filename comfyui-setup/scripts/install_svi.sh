#!/bin/bash

################################################################################
# Stable Video Infinity (SVI) Setup Script for ComfyUI
################################################################################
#
# This script sets up Stable Video Infinity for infinite-length video generation
# with WAN 2.1 in ComfyUI.
#
# Usage:
#   bash install_svi.sh
#
# Requirements:
#   - ComfyUI already installed
#   - NVIDIA GPU with 16GB+ VRAM
#   - Python 3.10+
#   - 50GB+ free disk space
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"
COMFYUI_DIR="$SETUP_DIR/ComfyUI"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Stable Video Infinity (SVI) Setup for ComfyUI        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Check Prerequisites
print_step "Checking prerequisites..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
print_success "Python $PYTHON_VERSION found"

# Check if ComfyUI exists
if [ ! -d "$COMFYUI_DIR" ]; then
    print_warning "ComfyUI not found at $COMFYUI_DIR"
    print_step "Please install ComfyUI first using: bash scripts/install.sh"
    exit 1
fi
print_success "ComfyUI found at $COMFYUI_DIR"

# Check CUDA availability
if command -v nvidia-smi &> /dev/null; then
    print_success "NVIDIA GPU detected"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader | head -1
else
    print_warning "NVIDIA GPU not detected. SVI requires GPU for practical use."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 2: Install ComfyUI-WanVideoWrapper
print_step "Installing ComfyUI-WanVideoWrapper..."

CUSTOM_NODES_DIR="$COMFYUI_DIR/custom_nodes"
WAN_WRAPPER_DIR="$CUSTOM_NODES_DIR/ComfyUI-WanVideoWrapper"

if [ -d "$WAN_WRAPPER_DIR" ]; then
    print_warning "ComfyUI-WanVideoWrapper already exists. Updating..."
    cd "$WAN_WRAPPER_DIR"
    git pull
else
    print_step "Cloning ComfyUI-WanVideoWrapper..."
    mkdir -p "$CUSTOM_NODES_DIR"
    cd "$CUSTOM_NODES_DIR"
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
    cd ComfyUI-WanVideoWrapper
fi

print_step "Installing WanVideoWrapper dependencies..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    print_success "WanVideoWrapper installed"
else
    print_warning "No requirements.txt found in WanVideoWrapper"
fi

# Step 3: Create directory structure for SVI
print_step "Creating directory structure..."

mkdir -p "$COMFYUI_DIR/models/loras"
mkdir -p "$COMFYUI_DIR/models/wan"
mkdir -p "$SETUP_DIR/models/loras/stable-video-infinity"
mkdir -p "$SETUP_DIR/workflows/svi"

print_success "Directory structure created"

# Step 4: Install Flash Attention
print_step "Installing Flash Attention 2..."

# Try to install flash-attn
if pip install flash-attn==2.8.0; then
    print_success "Flash Attention installed successfully"
else
    print_warning "Flash Attention installation failed. This is optional but recommended."
    print_warning "You can try installing it manually later: pip install flash-attn==2.8.0"
fi

# Step 5: Download SVI LoRA models
print_step "Downloading SVI LoRA models..."

echo ""
echo "SVI requires the following LoRA models:"
echo "  1. svi-shot_lora_rank_128_fp16.safetensors (~250 MB)"
echo "  2. svi-film_lora_rank_128_fp16.safetensors (~250 MB)"
echo "  3. svi-film-transitions_lora_rank_128_fp16.safetensors (~250 MB)"
echo "  4. svi-dance_lora_rank_128_fp16.safetensors (~250 MB)"
echo ""
echo "Total download size: ~1 GB"
echo ""

read -p "Download SVI LoRA models now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$SCRIPT_DIR"
    python3 download_svi_models.py

    # Copy models to ComfyUI loras directory
    if [ "$(ls -A $SETUP_DIR/models/loras/stable-video-infinity/*.safetensors 2>/dev/null)" ]; then
        print_step "Copying LoRA models to ComfyUI..."
        cp "$SETUP_DIR/models/loras/stable-video-infinity"/*.safetensors "$COMFYUI_DIR/models/loras/"
        print_success "LoRA models copied to ComfyUI/models/loras/"
    else
        print_warning "No LoRA models found to copy"
    fi
else
    print_warning "Skipping LoRA download. You can run later: python3 scripts/download_svi_models.py"
fi

# Step 6: Download WAN 2.1 base model
print_step "Checking WAN 2.1 base model..."

if [ "$(ls -A $COMFYUI_DIR/models/wan/ 2>/dev/null)" ]; then
    print_success "WAN model directory has content"
else
    echo ""
    echo "WAN 2.1 I2V 14B model is required (~28 GB)"
    echo ""
    echo "Download options:"
    echo "  1. Using HuggingFace CLI (recommended):"
    echo "     pip install huggingface-hub"
    echo "     huggingface-cli download Wan-Video/Wan2.1-I2V-14B \\"
    echo "       --local-dir $COMFYUI_DIR/models/wan/Wan2.1-I2V-14B \\"
    echo "       --local-dir-use-symlinks False"
    echo ""
    echo "  2. Manual download from:"
    echo "     https://huggingface.co/Wan-Video/Wan2.1-I2V-14B"
    echo ""

    read -p "Install HuggingFace CLI and download WAN model now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Installing HuggingFace CLI..."
        pip install huggingface-hub

        print_step "Downloading WAN 2.1 model (this will take a while)..."
        huggingface-cli download Wan-Video/Wan2.1-I2V-14B \
            --local-dir "$COMFYUI_DIR/models/wan/Wan2.1-I2V-14B" \
            --local-dir-use-symlinks False

        print_success "WAN 2.1 model downloaded"
    else
        print_warning "Skipping WAN model download. Install manually before using SVI."
    fi
fi

# Step 7: Install additional dependencies
print_step "Installing additional dependencies..."

pip install xformers || print_warning "xFormers installation failed (optional)"

# Step 8: Summary and next steps
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           SVI Setup Complete!                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

print_success "Installation summary:"
echo ""
echo "  ✓ ComfyUI-WanVideoWrapper installed"
echo "  ✓ Directory structure created"

if command -v python3 -c "import flash_attn" &> /dev/null 2>&1; then
    echo "  ✓ Flash Attention installed"
else
    echo "  ⚠ Flash Attention not available"
fi

if [ "$(ls -A $COMFYUI_DIR/models/loras/*.safetensors 2>/dev/null)" ]; then
    echo "  ✓ SVI LoRA models ready"
else
    echo "  ⚠ SVI LoRA models not downloaded"
fi

if [ "$(ls -A $COMFYUI_DIR/models/wan/ 2>/dev/null)" ]; then
    echo "  ✓ WAN 2.1 model ready"
else
    echo "  ⚠ WAN 2.1 model not downloaded"
fi

echo ""
echo "Next Steps:"
echo "───────────"
echo ""
echo "1. Start ComfyUI:"
echo "   cd $COMFYUI_DIR"
echo "   python main.py"
echo ""
echo "2. Open browser to: http://localhost:8188"
echo ""
echo "3. Load SVI workflows from:"
echo "   $SETUP_DIR/workflows/svi/"
echo ""
echo "4. See documentation:"
echo "   - Quick Start: $SETUP_DIR/QUICKSTART-SVI.md"
echo "   - Full Docs: $SETUP_DIR/README-SVI.md"
echo ""
echo "5. Download official workflows from:"
echo "   https://github.com/vita-epfl/Stable-Video-Infinity/tree/main/comfyui_workflow"
echo ""

print_success "Setup complete! Start creating infinite-length videos! 🎬"
echo ""
