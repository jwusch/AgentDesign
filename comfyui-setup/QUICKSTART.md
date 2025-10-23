# Quick Start Guide: ComfyUI + HunyuanWorld-Mirror

Get up and running with 3D reconstruction in 5 minutes!

## Prerequisites Check

```bash
# Check Python version (need 3.10+)
python3 --version

# Check CUDA availability (optional but recommended)
nvidia-smi

# Check disk space (need 50GB+)
df -h
```

## Installation (One Command)

```bash
cd comfyui-setup
bash scripts/install.sh
```

Wait 5-15 minutes for installation to complete.

## Download Models

### Quick Download (Recommended)

```bash
# Activate environment
source comfyui-setup/venv/bin/activate

# Install huggingface-hub
pip install huggingface-hub

# Download model (this may take 10-30 minutes)
huggingface-cli download tencent/HunyuanWorld-Mirror \
  --local-dir comfyui-setup/models/hunyuan/checkpoints/
```

### Manual Download

1. Go to: https://huggingface.co/tencent/HunyuanWorld-Mirror
2. Download all model files
3. Place in: `comfyui-setup/models/hunyuan/checkpoints/`

## Start ComfyUI

```bash
cd comfyui-setup
bash scripts/start.sh
```

Open browser to: http://localhost:8188

## Load Example Workflow

1. Click "Load" in ComfyUI
2. Select: `comfyui-setup/workflows/hunyuan_basic_workflow.json`
3. Upload an image
4. Click "Queue Prompt"
5. Wait for 3D reconstruction to complete!

## First Reconstruction

### Single Image to 3D Model

1. **Load Model Node**: Set model path to your checkpoint directory
2. **Load Image Node**: Upload your image (JPG/PNG)
3. **Reconstruction Node**: Select "single_view" mode
4. **Export Node**: Choose output format (PLY, OBJ, GLB)
5. **Queue Prompt**: Start processing

**Expected Time**: 2-5 seconds per image (with GPU)

### View Results

Output files will be in:
```
comfyui-setup/ComfyUI/outputs/hunyuan/
```

Open with:
- **Blender**: For PLY, OBJ files
- **MeshLab**: For PLY files
- **Windows 3D Viewer**: For GLB files
- **Online Viewer**: https://3dviewer.net/

## Common Issues

### Issue: "CUDA out of memory"
**Fix**:
```bash
# Edit start.sh, change max_split_size_mb to 256
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256
```

### Issue: "Model not found"
**Fix**: Verify model files are in correct location:
```bash
ls -la comfyui-setup/models/hunyuan/checkpoints/
```

### Issue: "Custom nodes not showing"
**Fix**:
```bash
# Copy custom nodes manually
cp -r comfyui-setup/custom_nodes/* comfyui-setup/ComfyUI/custom_nodes/
# Restart ComfyUI
```

## Next Steps

1. **Read Full Documentation**: See `README.md` for detailed features
2. **Explore HunyuanWorld-Mirror**: See `README-HUNYUAN.md` for capabilities
3. **Try Multi-View**: Use multiple images for better quality
4. **Experiment**: Adjust settings and explore different workflows

## Quick Reference

### File Locations

| What | Where |
|------|-------|
| ComfyUI | `comfyui-setup/ComfyUI/` |
| Models | `comfyui-setup/models/hunyuan/checkpoints/` |
| Workflows | `comfyui-setup/workflows/` |
| Outputs | `comfyui-setup/ComfyUI/outputs/` |
| Custom Nodes | `comfyui-setup/custom_nodes/` |

### Commands

| Task | Command |
|------|---------|
| Install | `bash scripts/install.sh` |
| Start | `bash scripts/start.sh` |
| Update | `git pull && pip install -r requirements*.txt --upgrade` |
| Activate Env | `source venv/bin/activate` |

### Web Interface

- **URL**: http://localhost:8188
- **API**: http://localhost:8188/api/
- **Docs**: Click "?" in interface

## Support

Having issues? Check:
1. Installation logs in terminal
2. ComfyUI console output
3. README.md troubleshooting section
4. GitHub issues

## Tips for Best Results

✅ **DO**:
- Use high-quality, well-lit images
- Try multiple views for better coverage
- Start with smaller images (512x512) to test
- Enable depth estimation for better results

❌ **DON'T**:
- Use blurry or low-res images
- Expect perfect results from single view
- Process huge images initially (start small)
- Skip the depth/camera estimation nodes

Happy 3D Reconstructing! 🎉
