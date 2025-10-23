#!/bin/bash
set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=========================================="
echo -e "Starting ComfyUI with HunyuanWorld-Mirror"
echo -e "==========================================${NC}"
echo ""

# Check if virtual environment exists
if [ ! -d "$SETUP_DIR/venv" ]; then
    echo -e "${RED}Error: Virtual environment not found${NC}"
    echo "Please run install.sh first"
    exit 1
fi

# Activate virtual environment
echo -e "${BLUE}Activating virtual environment...${NC}"
source "$SETUP_DIR/venv/bin/activate"

# Check if ComfyUI exists
if [ ! -d "$SETUP_DIR/ComfyUI" ]; then
    echo -e "${RED}Error: ComfyUI not found${NC}"
    echo "Please run install.sh first"
    exit 1
fi

# Start ComfyUI
echo -e "${GREEN}Starting ComfyUI...${NC}"
cd "$SETUP_DIR/ComfyUI"

# Set environment variables for better performance
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
export CUDA_VISIBLE_DEVICES=0

# Start ComfyUI with arguments
python main.py --listen 0.0.0.0 --port 8188 "$@"
