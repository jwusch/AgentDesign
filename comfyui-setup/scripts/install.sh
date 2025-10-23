#!/bin/bash
set -e

echo "=========================================="
echo "ComfyUI + HunyuanWorld-Mirror Setup"
echo "=========================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SETUP_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$SETUP_DIR")"

echo -e "${BLUE}Project Root: ${PROJECT_ROOT}${NC}"
echo -e "${BLUE}ComfyUI Setup Directory: ${SETUP_DIR}${NC}"
echo ""

# Check Python version
echo -e "${BLUE}Checking Python version...${NC}"
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python version: $PYTHON_VERSION"

# Check if Python 3.10 or higher
REQUIRED_MAJOR=3
REQUIRED_MINOR=10
CURRENT_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
CURRENT_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

if [ "$CURRENT_MAJOR" -lt "$REQUIRED_MAJOR" ] || ([ "$CURRENT_MAJOR" -eq "$REQUIRED_MAJOR" ] && [ "$CURRENT_MINOR" -lt "$REQUIRED_MINOR" ]); then
    echo -e "${RED}Error: Python 3.10 or higher is required${NC}"
    exit 1
fi
echo -e "${GREEN}Python version check passed${NC}"
echo ""

# Check for CUDA
echo -e "${BLUE}Checking CUDA availability...${NC}"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv
    echo -e "${GREEN}CUDA GPU detected${NC}"
else
    echo -e "${RED}Warning: No CUDA GPU detected. The setup will continue but performance will be limited.${NC}"
fi
echo ""

# Create virtual environment
echo -e "${BLUE}Creating virtual environment...${NC}"
cd "$SETUP_DIR"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}Virtual environment created${NC}"
else
    echo -e "${GREEN}Virtual environment already exists${NC}"
fi
echo ""

# Activate virtual environment
echo -e "${BLUE}Activating virtual environment...${NC}"
source venv/bin/activate

# Upgrade pip
echo -e "${BLUE}Upgrading pip...${NC}"
pip install --upgrade pip wheel setuptools
echo ""

# Install ComfyUI
echo -e "${BLUE}Setting up ComfyUI...${NC}"
cd "$SETUP_DIR"
if [ ! -d "ComfyUI" ]; then
    echo "Cloning ComfyUI repository..."
    git clone https://github.com/comfyanonymous/ComfyUI.git
    cd ComfyUI
    echo -e "${GREEN}ComfyUI cloned successfully${NC}"
else
    echo "ComfyUI directory already exists, updating..."
    cd ComfyUI
    git pull
    echo -e "${GREEN}ComfyUI updated${NC}"
fi

# Install ComfyUI dependencies
echo -e "${BLUE}Installing ComfyUI dependencies...${NC}"
pip install -r requirements.txt
echo -e "${GREEN}ComfyUI dependencies installed${NC}"
echo ""

# Install additional ComfyUI requirements
echo -e "${BLUE}Installing additional ComfyUI requirements...${NC}"
cd "$SETUP_DIR"
pip install -r requirements-comfyui.txt
echo -e "${GREEN}Additional ComfyUI requirements installed${NC}"
echo ""

# Install ComfyUI Manager
echo -e "${BLUE}Setting up ComfyUI Manager...${NC}"
cd "$SETUP_DIR/ComfyUI/custom_nodes"
if [ ! -d "ComfyUI-Manager" ]; then
    echo "Cloning ComfyUI-Manager repository..."
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
    cd ComfyUI-Manager
    pip install -r requirements.txt 2>/dev/null || echo "No additional requirements for ComfyUI-Manager"
    cd "$SETUP_DIR"
    echo -e "${GREEN}ComfyUI-Manager installed successfully${NC}"
else
    echo "ComfyUI-Manager already exists, updating..."
    cd ComfyUI-Manager
    git pull
    pip install -r requirements.txt 2>/dev/null || echo "No additional requirements for ComfyUI-Manager"
    cd "$SETUP_DIR"
    echo -e "${GREEN}ComfyUI-Manager updated${NC}"
fi
echo ""

# Install HunyuanWorld-Mirror
echo -e "${BLUE}Setting up HunyuanWorld-Mirror...${NC}"
cd "$SETUP_DIR"
if [ ! -d "HunyuanWorld-Mirror" ]; then
    echo "Cloning HunyuanWorld-Mirror repository..."
    git clone https://github.com/Tencent-Hunyuan/HunyuanWorld-Mirror.git
    echo -e "${GREEN}HunyuanWorld-Mirror cloned successfully${NC}"
else
    echo "HunyuanWorld-Mirror directory already exists, updating..."
    cd HunyuanWorld-Mirror
    git pull
    cd ..
    echo -e "${GREEN}HunyuanWorld-Mirror updated${NC}"
fi

# Install HunyuanWorld-Mirror dependencies
echo -e "${BLUE}Installing HunyuanWorld-Mirror dependencies...${NC}"
pip install -r requirements-hunyuan.txt
echo -e "${GREEN}HunyuanWorld-Mirror dependencies installed${NC}"
echo ""

# Install HunyuanWorld-Mirror
echo -e "${BLUE}Installing HunyuanWorld-Mirror package...${NC}"
cd "$SETUP_DIR/HunyuanWorld-Mirror"
pip install -e .
echo -e "${GREEN}HunyuanWorld-Mirror installed${NC}"
echo ""

# Create ComfyUI custom node for HunyuanWorld-Mirror
echo -e "${BLUE}Creating ComfyUI custom node for HunyuanWorld-Mirror...${NC}"
cd "$SETUP_DIR"
mkdir -p ComfyUI/custom_nodes/HunyuanWorld-Mirror
ln -sf "$SETUP_DIR/HunyuanWorld-Mirror" "$SETUP_DIR/ComfyUI/custom_nodes/HunyuanWorld-Mirror-src" 2>/dev/null || true
echo -e "${GREEN}Custom node link created${NC}"
echo ""

# Create models directory structure
echo -e "${BLUE}Creating models directory structure...${NC}"
cd "$SETUP_DIR"
mkdir -p models/hunyuan/{checkpoints,configs,vae}
mkdir -p ComfyUI/models/checkpoints
mkdir -p ComfyUI/models/vae
mkdir -p ComfyUI/models/hunyuan
echo -e "${GREEN}Models directory structure created${NC}"
echo ""

echo -e "${GREEN}=========================================="
echo -e "Installation Complete!"
echo -e "==========================================${NC}"
echo ""
echo -e "${BLUE}Installed Components:${NC}"
echo "  ✓ ComfyUI - Main application"
echo "  ✓ ComfyUI Manager - Plugin manager for easy extension installation"
echo "  ✓ HunyuanWorld-Mirror - 3D reconstruction model"
echo "  ✓ Custom nodes for HunyuanWorld-Mirror"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Download HunyuanWorld-Mirror models from:"
echo "   https://huggingface.co/tencent/HunyuanWorld-Mirror"
echo ""
echo "2. Place model files in: $SETUP_DIR/models/hunyuan/checkpoints/"
echo ""
echo "3. To start ComfyUI, run:"
echo "   cd $SETUP_DIR"
echo "   source venv/bin/activate"
echo "   cd ComfyUI"
echo "   python main.py"
echo ""
echo "4. Access ComfyUI at: http://localhost:8188"
echo ""
echo "5. Use ComfyUI Manager to install additional custom nodes:"
echo "   - Click the 'Manager' button in ComfyUI interface"
echo "   - Browse and install nodes, models, and extensions"
echo ""
echo -e "${BLUE}For more information:${NC}"
echo "   Model download: $SETUP_DIR/README-HUNYUAN.md"
echo "   Quick start: $SETUP_DIR/QUICKSTART.md"
echo "   Full guide: $SETUP_DIR/README.md"
