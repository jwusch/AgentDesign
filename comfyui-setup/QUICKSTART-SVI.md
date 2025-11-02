# Stable Video Infinity - Quick Start Guide

Get up and running with SVI for infinite-length video generation in 15 minutes!

## Prerequisites

- ✅ ComfyUI installed
- ✅ NVIDIA GPU with 16GB+ VRAM
- ✅ 50GB free disk space
- ✅ Python 3.10+

## 5-Step Setup

### Step 1: Install ComfyUI-WanVideoWrapper (5 min)

```bash
cd ComfyUI/custom_nodes
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
cd ComfyUI-WanVideoWrapper
pip install -r requirements.txt
```

### Step 2: Download WAN 2.1 Base Model (10-30 min depending on internet speed)

Option A - Using HuggingFace CLI (Recommended):
```bash
pip install huggingface-hub
huggingface-cli download Wan-Video/Wan2.1-I2V-14B \
  --local-dir ComfyUI/models/wan/Wan2.1-I2V-14B \
  --local-dir-use-symlinks False
```

Option B - Manual Download:
1. Go to: https://huggingface.co/Wan-Video/Wan2.1-I2V-14B
2. Download all files to `ComfyUI/models/wan/Wan2.1-I2V-14B/`

### Step 3: Download SVI LoRA Models (5-15 min)

```bash
cd /path/to/comfyui-setup
python3 scripts/download_svi_models.py
```

Then copy models to ComfyUI:
```bash
cp models/loras/stable-video-infinity/*.safetensors ComfyUI/models/loras/
```

### Step 4: Install Flash Attention (2 min)

```bash
pip install flash-attn==2.8.0
```

### Step 5: Test Installation (2 min)

```bash
cd ComfyUI
python main.py
```

Open browser to: http://localhost:8188

## Your First SVI Video

### Quick Test - Single Scene Loop

1. **Load Workflow**:
   - In ComfyUI, click "Load"
   - Navigate to `comfyui-setup/workflows/svi/`
   - Open `svi-shot-basic-loop.json`

2. **Configure**:
   - Upload an input image
   - Enter prompt: "A peaceful lake with gentle ripples, sunset lighting"
   - Set clip length: 3 seconds
   - Set loop count: 5 (for 15-second total)

3. **Generate**:
   - Click "Queue Prompt"
   - Wait 2-5 minutes (depending on GPU)
   - Video will appear in output folder

### Workflow Nodes Explained

```
┌─────────────┐
│ Load Image  │ ← Your input image
└──────┬──────┘
       │
┌──────▼──────────┐
│ Load WAN Model  │ ← WAN 2.1 I2V 14B
└──────┬──────────┘
       │
┌──────▼──────────┐
│  Load SVI LoRA  │ ← svi-shot (strength: 0.9)
└──────┬──────────┘
       │
┌──────▼──────────┐
│  Text Prompt    │ ← Your description
└──────┬──────────┘
       │
┌──────▼──────────┐
│  Generate Clip  │ ← First 3 seconds
└──────┬──────────┘
       │
┌──────▼──────────┐
│  Loop & Extend  │ ← Error recycling + next clips
└──────┬──────────┘
       │
┌──────▼──────────┐
│  Concatenate    │ ← Merge all clips
└──────┬──────────┘
       │
┌──────▼──────────┐
│  Save Video     │ ← Output file
└─────────────────┘
```

## Common Use Cases

### Use Case 1: Extend a Short Video

**Scenario**: You have a 10-second clip and want 60 seconds

**Steps**:
1. Load `svi-shot-basic-loop.json`
2. Set loop count to 17 (10s base + 50s extension)
3. Use last frame of original video as input image
4. Match original video's style in prompt
5. Generate

**Settings**:
- LoRA: SVI-Shot (0.9)
- Clip Length: 3 seconds
- Resolution: 1024x576

### Use Case 2: Multi-Scene Narrative

**Scenario**: Create a 5-scene story video

**Steps**:
1. Load `svi-film-multi-scene.json`
2. Create prompt queue:
   ```
   Scene 1: "Opening establishing shot..."
   Scene 2: "Character introduction..."
   Scene 3: "Conflict arises..."
   Scene 4: "Resolution..."
   Scene 5: "Closing shot..."
   ```
3. Generate

**Settings**:
- LoRA: SVI-Film-Transitions (0.85)
- Scene Length: 8 seconds each
- Resolution: 1280x720

### Use Case 3: Dance Animation

**Scenario**: Animate a character dancing

**Steps**:
1. Load `svi-dance-controlnet.json`
2. Upload character image
3. Upload reference dance video or pose sequence
4. Generate

**Settings**:
- LoRA: SVI-Dance (1.0)
- ControlNet: OpenPose (0.8)
- Resolution: 768x1024

## Recommended Settings by GPU

### RTX 3090 / 4080 (16GB VRAM)

**Fast Mode**:
```yaml
Resolution: 768x432
Steps: 25
Guidance: 7.0
Clip Length: 2 seconds
LoRA Strength: 0.85
Generation Time: ~1 min per 10s
```

**Quality Mode**:
```yaml
Resolution: 1024x576
Steps: 35
Guidance: 7.5
Clip Length: 3 seconds
LoRA Strength: 0.9
Generation Time: ~3 min per 10s
```

### RTX 4090 / A6000 (24GB VRAM)

**Fast Mode**:
```yaml
Resolution: 1024x576
Steps: 30
Guidance: 7.5
Clip Length: 3 seconds
LoRA Strength: 0.9
Generation Time: ~1.5 min per 10s
```

**Quality Mode**:
```yaml
Resolution: 1280x720
Steps: 45
Guidance: 8.0
Clip Length: 4 seconds
LoRA Strength: 0.9
Generation Time: ~4 min per 10s
```

**Ultra Quality**:
```yaml
Resolution: 1920x1080
Steps: 50
Guidance: 8.5
Clip Length: 4 seconds
LoRA Strength: 1.0
Generation Time: ~8 min per 10s
```

### H100 / A100 (40GB+ VRAM)

**Production Mode**:
```yaml
Resolution: 1920x1080
Steps: 50
Guidance: 9.0
Clip Length: 5 seconds
LoRA Strength: 1.0
Batch Size: 2
Generation Time: ~3 min per 10s
```

## Troubleshooting

### ❌ "Out of Memory" Error

**Solution**:
1. Reduce resolution to 512x288
2. Reduce clip length to 1-2 seconds
3. Lower steps to 20
4. Clear VRAM: Add "VRAMDebug" node before generation

### ❌ Models Not Found

**Solution**:
1. Check paths:
   ```bash
   ls ComfyUI/models/wan/
   ls ComfyUI/models/loras/
   ```
2. Ensure models are in correct directories
3. Restart ComfyUI

### ❌ Color Shift in Long Videos

**Solution**:
1. Enable error recycling (every 3 clips)
2. Reduce LoRA strength to 0.8
3. Use SVI-Film-Transitions instead of SVI-Shot

### ❌ Choppy Motion

**Solution**:
1. Increase steps to 40+
2. Increase guidance to 8.0+
3. Use shorter clip lengths
4. Enable temporal consistency in model settings

### ❌ Slow Generation

**Solution**:
1. Ensure Flash Attention is installed:
   ```bash
   python -c "import flash_attn; print(flash_attn.__version__)"
   ```
2. Enable xFormers:
   ```bash
   pip install xformers
   ```
3. Use FP16 precision
4. Reduce resolution

## Tips for Best Results

### Prompt Writing

✅ **Good Prompts**:
- "A serene forest path with dappled sunlight, gentle camera dolly forward, cinematic lighting"
- "Waves crashing on a rocky shore at golden hour, slow motion, 4k quality"
- "Character walking through neon-lit cyberpunk streets, rain falling, reflections on wet ground"

❌ **Poor Prompts**:
- "forest"
- "water moving"
- "person walking"

### Key Principles

1. **Be Specific**: Describe lighting, camera movement, style
2. **Stay Consistent**: Use similar prompts across clips
3. **Use Cinematic Terms**: "dolly", "pan", "tracking shot", etc.
4. **Specify Quality**: "4k", "highly detailed", "professional"

### Clip Length Strategy

- **1-2 seconds**: Maximum control, best for complex scenes
- **3-4 seconds**: Balanced, recommended for most use cases
- **5+ seconds**: Faster generation, risk of drift

### LoRA Mixing

You can combine multiple SVI LoRAs:
- SVI-Film (0.6) + SVI-Transitions (0.3) = Smooth multi-scene
- SVI-Shot (0.7) + SVI-Dance (0.3) = Character in static scene

## Next Steps

Once comfortable with basics:

1. **Read Full Documentation**: [README-SVI.md](README-SVI.md)
2. **Explore Advanced Workflows**: Check `workflows/svi/` directory
3. **Join Community**: ComfyUI Discord, Reddit
4. **Experiment**: Try different settings, LoRA combinations
5. **Share Results**: Help improve workflows

## Advanced Topics

### Error Recycling Configuration

The error recycling mechanism can be tuned:

```python
# In workflow JSON
"error_recycling": {
    "enabled": true,
    "frequency": 3,  # Every 3 clips
    "strength": 0.5, # How much to correct (0-1)
    "method": "blend" # blend, replace, or adaptive
}
```

### Custom LoRA Training

To train your own SVI LoRA:

1. Clone SVI repository:
   ```bash
   git clone https://github.com/vita-epfl/Stable-Video-Infinity.git
   ```

2. Prepare dataset (minimum 10 video clips)

3. Run training script:
   ```bash
   python train_lora.py \
     --dataset_path ./my_videos \
     --output_path ./my_svi_lora \
     --rank 128 \
     --steps 5000
   ```

4. Convert to ComfyUI format:
   ```bash
   python convert_to_comfyui.py \
     --input ./my_svi_lora \
     --output ./my_svi_lora_comfyui.safetensors
   ```

### Batch Processing

Generate multiple videos in sequence:

1. Create batch config file: `batch_config.json`
2. Use batch workflow: `svi-batch-process.json`
3. Queue all jobs at once
4. ComfyUI will process sequentially

## Resources

- **Documentation**: [README-SVI.md](README-SVI.md)
- **Workflows**: `workflows/svi/` directory
- **SVI GitHub**: https://github.com/vita-epfl/Stable-Video-Infinity
- **Tutorial Video**: https://youtu.be/43lh-3kV3bs
- **Discord**: ComfyUI server, #video-generation channel

## Checklist

Before generating your first video, ensure:

- [ ] ComfyUI-WanVideoWrapper installed
- [ ] WAN 2.1 I2V model downloaded
- [ ] SVI LoRA models in correct directory
- [ ] Flash Attention installed
- [ ] ComfyUI starts without errors
- [ ] Example workflow loads successfully
- [ ] Test image prepared
- [ ] Prompt written

## Expected Results

**First Generation** (with default settings):
- Time: 2-5 minutes for 10-second video
- Quality: Good temporal consistency
- Issues: Minor color shifts possible (normal)

**After Tuning**:
- Time: Optimized for your GPU
- Quality: High consistency, minimal drift
- Issues: Resolved through parameter adjustment

---

**Ready to create infinite videos!** 🎬

For detailed information and advanced techniques, see [README-SVI.md](README-SVI.md)
