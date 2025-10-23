# ComfyUI with HunyuanWorld-Mirror Setup

This directory contains a complete setup for running ComfyUI with HunyuanWorld-Mirror, Tencent's universal 3D world reconstruction model.

## What is HunyuanWorld-Mirror?

HunyuanWorld-Mirror is a cutting-edge feed-forward model for comprehensive 3D geometric prediction that:
- Integrates diverse geometric priors (camera poses, calibrated intrinsics, depth maps)
- Generates multiple 3D representations (point clouds, meshes, depth maps, surface normals, 3D Gaussians)
- Performs all predictions in a single forward pass
- Supports single-view, multi-view, and video-based 3D reconstruction

## Features

- **Universal 3D Reconstruction**: Convert images and videos to 3D models
- **Multi-Modal Prior Prompting**: Use depth, camera, and other priors
- **Multiple Output Formats**: Point clouds, meshes, Gaussian splats
- **Depth & Normal Estimation**: Extract geometric information from images
- **Camera Parameter Estimation**: Automatic camera calibration
- **ComfyUI Integration**: Easy-to-use visual workflow interface
- **ComfyUI Manager**: Built-in extension manager for installing custom nodes, models, and workflows

## Directory Structure

```
comfyui-setup/
├── ComfyUI/                    # ComfyUI installation (created by install.sh)
├── HunyuanWorld-Mirror/        # HunyuanWorld-Mirror repository (created by install.sh)
├── custom_nodes/               # Custom ComfyUI nodes for Hunyuan
│   ├── __init__.py
│   └── hunyuan_nodes.py
├── models/                     # Model files directory
│   └── hunyuan/
│       ├── checkpoints/        # Place model checkpoints here
│       ├── configs/            # Model configurations
│       └── vae/                # VAE models
├── scripts/                    # Installation and utility scripts
│   ├── install.sh             # Main installation script
│   └── start.sh               # ComfyUI startup script
├── workflows/                  # Example workflows
│   └── hunyuan_basic_workflow.json
├── requirements-comfyui.txt    # ComfyUI dependencies
├── requirements-hunyuan.txt    # HunyuanWorld-Mirror dependencies
└── README.md                   # This file
```

## Prerequisites

- **Operating System**: Linux (Ubuntu 20.04+ recommended) or Windows with WSL2
- **Python**: 3.10 or higher
- **CUDA**: 12.4 or higher (for GPU acceleration)
- **GPU**: NVIDIA GPU with 12GB+ VRAM recommended
- **Storage**: 50GB+ free space for models and dependencies
- **Memory**: 16GB+ RAM recommended

## Installation

### Quick Start

```bash
# Navigate to the setup directory
cd comfyui-setup

# Run the installation script
bash scripts/install.sh
```

The installation script will:
1. Check system requirements
2. Create a Python virtual environment
3. Clone ComfyUI repository
4. Install ComfyUI Manager extension
5. Clone HunyuanWorld-Mirror repository
6. Install all dependencies
7. Set up custom nodes
8. Create necessary directory structure

### Manual Installation

If you prefer to install manually or need to troubleshoot:

```bash
# 1. Create virtual environment
cd comfyui-setup
python3 -m venv venv
source venv/bin/activate

# 2. Install PyTorch with CUDA support
pip install torch==2.4.0 torchvision==0.19.0 --extra-index-url https://download.pytorch.org/whl/cu124

# 3. Clone ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt
cd ..

# 4. Install ComfyUI Manager
cd ComfyUI/custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
pip install -r requirements.txt
cd ../../..

# 5. Clone HunyuanWorld-Mirror
git clone https://github.com/Tencent-Hunyuan/HunyuanWorld-Mirror.git
cd HunyuanWorld-Mirror
pip install -e .
cd ..

# 6. Install additional dependencies
pip install -r requirements-comfyui.txt
pip install -r requirements-hunyuan.txt

# 7. Copy custom nodes
cp -r custom_nodes/* ComfyUI/custom_nodes/
```

## Model Download

After installation, you need to download the HunyuanWorld-Mirror model weights:

### Option 1: Using Hugging Face CLI

```bash
# Install huggingface-hub
pip install huggingface-hub

# Download models
huggingface-cli download tencent/HunyuanWorld-Mirror \
  --local-dir models/hunyuan/checkpoints/ \
  --local-dir-use-symlinks False
```

### Option 2: Manual Download

1. Visit: https://huggingface.co/tencent/HunyuanWorld-Mirror
2. Download the following files:
   - `world_mirror_v1.pth` (main model checkpoint)
   - `config.yaml` (model configuration)
   - Any additional files listed in the repository

3. Place downloaded files in:
   ```
   comfyui-setup/models/hunyuan/checkpoints/
   ```

### Model Files Structure

```
models/hunyuan/
├── checkpoints/
│   ├── world_mirror_v1.pth
│   └── config.yaml
├── configs/
│   └── (additional configs if any)
└── vae/
    └── (VAE weights if separate)
```

## Usage

### Starting ComfyUI

```bash
# From the comfyui-setup directory
bash scripts/start.sh
```

Or manually:

```bash
cd comfyui-setup
source venv/bin/activate
cd ComfyUI
python main.py --listen 0.0.0.0 --port 8188
```

Then open your browser and navigate to:
```
http://localhost:8188
```

### Loading Example Workflow

1. Start ComfyUI (see above)
2. In the ComfyUI interface, click "Load" button
3. Navigate to `comfyui-setup/workflows/`
4. Load `hunyuan_basic_workflow.json`
5. Upload an input image
6. Click "Queue Prompt" to run the workflow

### Using ComfyUI Manager

ComfyUI Manager is a powerful extension that makes it easy to manage custom nodes, models, and other extensions.

**Accessing ComfyUI Manager:**

1. Start ComfyUI
2. Look for the **"Manager"** button in the interface (usually in the menu bar)
3. Click it to open the Manager panel

**Key Features:**

- **Install Custom Nodes**: Browse and install thousands of community-created nodes
  - Click "Install Custom Nodes"
  - Search or browse available nodes
  - Click "Install" on any node you want
  - Restart ComfyUI to use the new nodes

- **Install Models**: Download models directly through the interface
  - Click "Install Models"
  - Choose from Checkpoints, LoRAs, VAEs, ControlNet, and more
  - Select models and click "Install"

- **Update Extensions**: Keep all your custom nodes up to date
  - Click "Update All" to update all installed extensions
  - Or update individual nodes selectively

- **Install Missing Nodes**: Automatically install nodes required by workflows
  - Load a workflow that uses custom nodes you don't have
  - Manager will detect missing nodes
  - Click "Install Missing Nodes"

**Recommended Extensions for 3D Work:**

Through ComfyUI Manager, you can install additional nodes that complement HunyuanWorld-Mirror:

- **ComfyUI-3D-Pack**: Additional 3D processing nodes
- **ControlNet nodes**: For better control over generation
- **Image processing nodes**: For pre-processing input images
- **Video processing nodes**: For video-to-3D workflows

**Troubleshooting:**

If Manager button doesn't appear:
1. Verify installation: `ls ComfyUI/custom_nodes/ComfyUI-Manager`
2. Restart ComfyUI completely
3. Check console for error messages

### Available Nodes

The setup includes the following custom nodes:

1. **Load HunyuanWorld-Mirror Model**
   - Loads the model from checkpoints
   - Configure device (CUDA/CPU)

2. **HunyuanWorld 3D Reconstruction**
   - Main reconstruction node
   - Modes: single_view, multi_view, video
   - Output formats: point_cloud, mesh, gaussian_splat

3. **HunyuanWorld Depth Estimation**
   - Estimate depth maps from images
   - Optional normalization

4. **HunyuanWorld Camera Estimation**
   - Estimate camera intrinsics and extrinsics
   - Useful for multi-view reconstruction

5. **Export HunyuanWorld 3D**
   - Export to PLY, OBJ, GLB, or SPLAT format
   - Specify output directory and filename

## Example Workflows

### Basic Single-View Reconstruction

```
Load Image → Load Model → Depth Estimation → 3D Reconstruction → Export
```

### Multi-View Reconstruction

```
Load Images → Load Model → Camera Estimation → 3D Reconstruction → Export
```

### Video to 3D Scene

```
Load Video → Extract Frames → Load Model → Multi-View Reconstruction → Export
```

## Configuration

### Performance Tuning

Edit `scripts/start.sh` to adjust CUDA settings:

```bash
# For systems with less VRAM
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256

# For multi-GPU systems
export CUDA_VISIBLE_DEVICES=0,1
```

### Model Configuration

Model parameters can be adjusted in the custom nodes or by modifying:
```
models/hunyuan/checkpoints/config.yaml
```

## Troubleshooting

### Installation Issues

**Problem**: `CUDA out of memory`
- **Solution**: Reduce batch size, close other GPU applications, or use CPU mode

**Problem**: `Module not found: gsplat`
- **Solution**: Install gsplat separately:
  ```bash
  pip install gsplat --extra-index-url https://download.pytorch.org/whl/cu124
  ```

**Problem**: `No module named 'HunyuanWorld'`
- **Solution**: Ensure HunyuanWorld-Mirror is installed:
  ```bash
  cd HunyuanWorld-Mirror
  pip install -e .
  ```

### Runtime Issues

**Problem**: ComfyUI doesn't show custom nodes
- **Solution**:
  1. Check that custom_nodes are copied to ComfyUI/custom_nodes/
  2. Restart ComfyUI
  3. Check console for error messages

**Problem**: Model loading fails
- **Solution**:
  1. Verify model files are in correct directory
  2. Check file permissions
  3. Ensure sufficient disk space

**Problem**: Slow inference
- **Solution**:
  1. Use GPU mode instead of CPU
  2. Reduce input image resolution
  3. Enable mixed precision (if supported)

## Performance Tips

1. **GPU Memory Management**
   - Use `--lowvram` flag when starting ComfyUI if you have limited VRAM
   - Process images in smaller batches

2. **Speed Optimization**
   - Use lower resolution inputs for faster preview
   - Enable model caching
   - Use FP16 mode for faster inference (if supported)

3. **Quality Settings**
   - Higher resolution inputs = better 3D quality
   - Multi-view reconstruction provides better results than single-view
   - Use depth priors when available for improved accuracy

## Advanced Usage

### Custom Priors

You can provide custom depth maps or camera parameters:

```python
# In the reconstruction node
camera_params = {
    "fx": 500.0,
    "fy": 500.0,
    "cx": 256.0,
    "cy": 256.0
}
```

### Batch Processing

Process multiple images in sequence:
1. Use ComfyUI's batch processing features
2. Queue multiple prompts
3. Monitor progress in the interface

### Integration with Other Nodes

HunyuanWorld-Mirror nodes can be combined with:
- ControlNet for guided generation
- Depth estimation nodes from other sources
- Post-processing effects

## Resources

- **HunyuanWorld-Mirror GitHub**: https://github.com/Tencent-Hunyuan/HunyuanWorld-Mirror
- **ComfyUI GitHub**: https://github.com/comfyanonymous/ComfyUI
- **Hugging Face Model**: https://huggingface.co/tencent/HunyuanWorld-Mirror
- **Paper**: Check the GitHub repository for research papers

## System Requirements Summary

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| GPU VRAM | 8GB | 12GB+ |
| RAM | 8GB | 16GB+ |
| Storage | 30GB | 50GB+ |
| CUDA | 12.4 | 12.4+ |
| Python | 3.10 | 3.10+ |

## License

This setup combines multiple projects:
- ComfyUI: GPL-3.0 License
- HunyuanWorld-Mirror: Check repository for license
- Custom nodes: MIT License

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review HunyuanWorld-Mirror GitHub issues
3. Check ComfyUI documentation
4. Open an issue in this repository

## Credits

- **HunyuanWorld-Mirror**: Tencent Hunyuan Team
- **ComfyUI**: comfyanonymous and contributors
- **Integration**: Custom nodes and workflows by this project

## Updates

To update the installation:

```bash
cd comfyui-setup

# Update ComfyUI
cd ComfyUI
git pull
cd ..

# Update HunyuanWorld-Mirror
cd HunyuanWorld-Mirror
git pull
pip install -e . --upgrade
cd ..

# Update dependencies
source venv/bin/activate
pip install -r requirements-comfyui.txt --upgrade
pip install -r requirements-hunyuan.txt --upgrade
```

---

For detailed information about HunyuanWorld-Mirror capabilities and architecture, see [README-HUNYUAN.md](README-HUNYUAN.md)
