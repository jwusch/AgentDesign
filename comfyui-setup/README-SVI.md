# Stable Video Infinity (SVI) for ComfyUI

## Overview

Stable Video Infinity (SVI) is a cutting-edge framework for generating arbitrarily long videos with high temporal consistency, plausible scene transitions, and controllable streaming storylines. This setup integrates SVI with WAN 2.1 in ComfyUI for professional-grade AI animation and video generation.

## What is Stable Video Infinity?

SVI enables infinite-length video generation through:
- **Error Recycling Mechanism**: Prevents motion drift and color degradation in extended sequences
- **Hybrid Causality Model**: Combines bidirectional attention within clips with clip-by-clip causality
- **LoRA-based Fine-tuning**: Requires minimal training data for custom adaptations
- **Multi-Scene Generation**: Create full-length films with smooth transitions

### Key Features

✨ **No Duration Limits**: Generate videos of ANY length
🎬 **Professional Quality**: High temporal consistency and minimal degradation
🔄 **Error Recycling**: Prevents drift in long sequences
🎭 **Multiple Variants**: Specialized LoRAs for different use cases
⚡ **Efficient**: LoRA-based approach requires minimal computational resources

## SVI Model Variants

### 1. SVI-Shot
**Purpose**: Single-scene generation from image + text

**Use Cases**:
- Extending a static image into a looping animation
- Creating animated backgrounds
- Product demonstrations

**Workflow**: Image + Text Prompt → Single-scene video

### 2. SVI-Film
**Purpose**: Multi-scene generation with prompt streams

**Use Cases**:
- Narrative storytelling with scene changes
- Music videos with multiple segments
- Advertisement sequences

**Workflow**: Image Sequence + Prompt Stream → Multi-scene video

### 3. SVI-Film-Transitions
**Purpose**: Enhanced scene transitions for cinematic quality

**Use Cases**:
- Professional video production
- Smooth scene transitions
- Cinematic effects

**Workflow**: Similar to SVI-Film with improved transition quality

### 4. SVI-Dance
**Purpose**: Skeleton-conditioned human animation

**Use Cases**:
- Dance videos from pose sequences
- Character animation
- Motion transfer

**Workflow**: Pose/Skeleton Sequence + Image → Animated character video

## Technical Architecture

### Hybrid Causality Model

SVI uses a unique approach inspired by filmmaking workflows:

```
Traditional Frame-by-Frame:
[Frame 1] → [Frame 2] → [Frame 3] → ... (Accumulates drift)

SVI Hybrid Causality:
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Clip 1    │ ──→ │   Clip 2    │ ──→ │   Clip 3    │
│ (Bidirect.) │     │ (Bidirect.) │     │ (Bidirect.) │
└─────────────┘     └─────────────┘     └─────────────┘
     ↕                   ↕                   ↕
  Review              Review              Review
  (Error Recycling)
```

- **Within-Clip**: Bidirectional attention for quality
- **Between-Clips**: Causal connection for consistency
- **Error Recycling**: Feedback loop prevents drift

### Base Model Requirements

- **WAN 2.1 I2V 14B**: Base image-to-video model
- **LoRA Adapters**: SVI-specific fine-tuned weights
- **ComfyUI-WanVideoWrapper**: Custom nodes for WAN integration

## Installation

### Prerequisites

- ComfyUI installed
- Python 3.10+
- PyTorch 2.5.0+ with CUDA support
- NVIDIA GPU with 16GB+ VRAM (24GB recommended for high quality)
- 50GB+ free disk space

### Step 1: Install ComfyUI-WanVideoWrapper

```bash
cd ComfyUI/custom_nodes
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
cd ComfyUI-WanVideoWrapper
pip install -r requirements.txt
```

### Step 2: Download WAN 2.1 Base Model

Download the WAN 2.1 I2V 14B model:

```bash
# Using HuggingFace CLI
huggingface-cli download Wan-Video/Wan2.1-I2V-14B \
  --local-dir ComfyUI/models/wan/ \
  --local-dir-use-symlinks False
```

Or manually from: https://huggingface.co/Wan-Video/Wan2.1-I2V-14B

Place in: `ComfyUI/models/wan/`

### Step 3: Download SVI LoRA Models

Run the provided download script:

```bash
cd comfyui-setup
python3 scripts/download_svi_models.py
```

Or manually download from:
https://huggingface.co/Kijai/WanVideo_comfy/tree/main/LoRAs/Stable-Video-Infinity

**Required Models**:
- `svi-shot_lora_rank_128_fp16.safetensors` (~250 MB)
- `svi-film_lora_rank_128_fp16.safetensors` (~250 MB)
- `svi-film-transitions_lora_rank_128_fp16.safetensors` (~250 MB)
- `svi-dance_lora_rank_128_fp16.safetensors` (~250 MB)

Place in: `ComfyUI/models/loras/`

### Step 4: Install Additional Dependencies

```bash
pip install flash-attn==2.8.0
```

## Directory Structure

After installation, your directory structure should look like:

```
ComfyUI/
├── models/
│   ├── wan/
│   │   └── Wan2.1-I2V-14B/
│   │       ├── model_index.json
│   │       ├── unet/
│   │       ├── vae/
│   │       └── text_encoder/
│   └── loras/
│       ├── svi-shot_lora_rank_128_fp16.safetensors
│       ├── svi-film_lora_rank_128_fp16.safetensors
│       ├── svi-film-transitions_lora_rank_128_fp16.safetensors
│       └── svi-dance_lora_rank_128_fp16.safetensors
└── custom_nodes/
    └── ComfyUI-WanVideoWrapper/
```

## Usage Workflows

### Basic Image-to-Video with SVI-Shot

1. Load WAN 2.1 I2V model
2. Load SVI-Shot LoRA (strength: 0.8-1.0)
3. Input image
4. Input text prompt
5. Generate video
6. Loop structure for infinite length

**Workflow Nodes**:
```
Load Image → Load WAN Model → Apply SVI-Shot LoRA → Generate Video → Save
```

### Multi-Scene Video with SVI-Film

1. Load WAN 2.1 I2V model
2. Load SVI-Film LoRA
3. Create prompt stream (one prompt per scene)
4. Input initial image
5. Generate with loop structure

**Workflow Nodes**:
```
Prompt Queue → Load WAN Model → Apply SVI-Film LoRA → Video Loop → Concatenate → Save
```

### Video-to-Video with ControlNet (Dance/Motion)

1. Load WAN 2.1 I2V model
2. Load SVI-Dance LoRA
3. Extract pose/skeleton from reference video
4. Apply ControlNet for guidance
5. Generate with character image

**Workflow Nodes**:
```
Input Video → Pose Extraction → Load WAN Model → Apply SVI-Dance LoRA → ControlNet → Generate → Save
```

## Advanced Configuration

### Loop Structure for Infinite Length

The key to infinite-length video is the loop structure with error recycling:

```python
# Pseudo-code for loop structure
for clip_index in range(num_clips):
    # Generate current clip
    current_clip = generate_clip(
        previous_frame=last_frame,
        prompt=prompts[clip_index],
        lora=svi_lora
    )

    # Error recycling: review and correct
    if has_drift(current_clip):
        current_clip = error_recycle(current_clip, previous_clips)

    # Append to sequence
    video_sequence.append(current_clip)
    last_frame = current_clip[-1]
```

### Padding Settings

⚠️ **Important**: SVI requires modified padding settings different from standard WAN 2.1:

In ComfyUI workflow:
- **Padding Mode**: `constant` (not `replicate`)
- **Padding Value**: `0.0`

This prevents edge artifacts in long sequences.

### LoRA Strength Recommendations

| Model Variant | Recommended Strength | Range |
|---------------|---------------------|-------|
| SVI-Shot | 0.9 | 0.8-1.0 |
| SVI-Film | 0.85 | 0.7-1.0 |
| SVI-Film-Transitions | 0.8 | 0.7-0.9 |
| SVI-Dance | 1.0 | 0.9-1.0 |

### Generation Parameters

**For High Quality**:
- Resolution: 1024x576 or 1280x720
- Steps: 30-50
- Guidance Scale: 7.5-9.0
- Clip Length: 2-4 seconds per clip
- FPS: 24-30

**For Speed**:
- Resolution: 512x288 or 768x432
- Steps: 20-30
- Guidance Scale: 6.0-7.5
- Clip Length: 1-2 seconds per clip
- FPS: 15-24

## Workflow Examples

### Example 1: Extending a 15-Second Clip to 1 Minute

**Objective**: Extend a short video to full length with consistency

**Setup**:
1. Model: WAN 2.1 + SVI-Shot LoRA
2. Input: 15-second clip (450 frames @ 30fps)
3. Target: 60 seconds (1800 frames)
4. Structure: Generate in 3-second clips (90 frames each)

**Process**:
1. Extract last frame of input clip
2. Loop 15 times:
   - Generate 3-second extension
   - Apply error recycling
   - Append to sequence
3. Concatenate all clips

**Settings**:
- LoRA Strength: 0.9
- Steps: 35
- Guidance: 7.5
- Resolution: 1024x576

### Example 2: Multi-Scene Narrative Video

**Objective**: Create a story-driven video with scene changes

**Setup**:
1. Model: WAN 2.1 + SVI-Film LoRA
2. Scenes: 5 different scenes, 10 seconds each
3. Total: 50 seconds

**Prompt Stream**:
```
Scene 1: "A lone spaceship drifting through a nebula"
Scene 2: "The ship approaching a mysterious planet"
Scene 3: "Landing sequence on the alien surface"
Scene 4: "Exploring crystalline structures"
Scene 5: "Discovery of ancient artifacts"
```

**Process**:
1. Load SVI-Film LoRA
2. Queue all prompts
3. Generate each scene with smooth transitions
4. Error recycling ensures consistency

**Settings**:
- LoRA Strength: 0.85
- Steps: 40
- Guidance: 8.0
- Resolution: 1280x720

### Example 3: Dance Video from Pose Sequence

**Objective**: Animate a character dancing from pose reference

**Setup**:
1. Model: WAN 2.1 + SVI-Dance LoRA
2. Input: Character image + dance pose video
3. Output: Character performing the dance

**Process**:
1. Extract pose sequence from reference video
2. Load character image
3. Apply SVI-Dance LoRA
4. Use ControlNet with pose guidance
5. Generate frame sequences
6. Error recycling for smooth motion

**Settings**:
- LoRA Strength: 1.0
- ControlNet Strength: 0.8
- Steps: 45
- Guidance: 8.5
- Resolution: 768x1024 (portrait)

## Troubleshooting

### Issue: Color Shift in Long Videos

**Symptom**: Colors gradually change or desaturate over time

**Solutions**:
1. Reduce clip length (shorter segments)
2. Increase error recycling frequency
3. Lower LoRA strength slightly (0.85 instead of 0.9)
4. Use color correction in post-processing

### Issue: Motion Drift

**Symptom**: Subject gradually moves out of frame or changes position

**Solutions**:
1. Ensure proper padding settings (constant, 0.0)
2. Use higher guidance scale (8.0-9.0)
3. Reduce generation steps per clip
4. Enable error recycling at every clip boundary

### Issue: Repetitive Actions

**Symptom**: Character or objects repeat the same motion

**Solutions**:
1. Vary prompts between clips
2. Use SVI-Film instead of SVI-Shot for multi-scene
3. Inject slight variations in conditioning
4. Reduce clip overlap

### Issue: Scene Transition Artifacts

**Symptom**: Visible seams or glitches between clips

**Solutions**:
1. Use SVI-Film-Transitions LoRA
2. Increase overlap between clips (2-3 frames)
3. Apply blending in post-processing
4. Ensure consistent resolution throughout

### Issue: Out of Memory (OOM)

**Symptom**: CUDA out of memory errors

**Solutions**:
1. Reduce resolution (use 512x288 or 768x432)
2. Generate shorter clips (1-2 seconds)
3. Clear VRAM between clips:
   ```python
   torch.cuda.empty_cache()
   ```
4. Use FP8 quantization if available
5. Enable CPU offloading for VAE

### Issue: Slow Generation

**Symptom**: Takes too long to generate videos

**Solutions**:
1. Reduce steps (20-30 instead of 40-50)
2. Use lower resolution
3. Ensure Flash Attention is installed
4. Use FP16 or FP8 precision
5. Enable xFormers optimization

## Performance Optimization

### VRAM Management

| Resolution | Clip Length | VRAM Usage | Recommendation |
|------------|-------------|------------|----------------|
| 512x288 | 2s (48 frames) | 8-10 GB | Minimum setup |
| 768x432 | 3s (72 frames) | 12-14 GB | Balanced |
| 1024x576 | 4s (96 frames) | 16-18 GB | High quality |
| 1280x720 | 4s (96 frames) | 20-24 GB | Professional |

### Speed Optimizations

1. **Flash Attention**: 30-40% faster inference
   ```bash
   pip install flash-attn==2.8.0
   ```

2. **xFormers**: Memory-efficient attention
   ```bash
   pip install xformers
   ```

3. **FP8 Quantization**: 2x faster with minimal quality loss
   - Requires: NVIDIA 4090 or H100

4. **Compile Mode**: PyTorch 2.0+ compilation
   ```python
   model = torch.compile(model, mode="reduce-overhead")
   ```

## Best Practices

### 1. Prompt Engineering

✅ **Do**:
- Use detailed, descriptive prompts
- Maintain consistent subject description across clips
- Specify camera movement explicitly
- Include lighting and mood descriptions

❌ **Don't**:
- Use vague or abstract prompts
- Change subject dramatically between clips
- Mix different art styles in one sequence
- Use conflicting instructions

**Example Good Prompt**:
```
"A majestic red dragon flying through cloudy skies at sunset,
cinematic lighting, smooth camera pan following the dragon,
highly detailed scales, fantasy art style"
```

**Example Bad Prompt**:
```
"dragon flying"
```

### 2. Clip Length Strategy

- **Short Clips (1-2s)**: Better consistency, more control, but more processing
- **Medium Clips (3-4s)**: Balanced approach, recommended for most cases
- **Long Clips (5-8s)**: Faster generation, but higher risk of drift

**Recommendation**: Start with 3-second clips, adjust based on results

### 3. Error Recycling Frequency

- **Every Clip**: Maximum consistency, slowest
- **Every 3 Clips**: Balanced approach
- **Every 5 Clips**: Faster, acceptable for simple scenes

### 4. Quality vs. Speed Trade-offs

**Maximum Quality**:
- Resolution: 1280x720
- Steps: 50
- Guidance: 8.5
- LoRA: 0.9
- Error Recycling: Every clip
- **Time**: ~5 minutes per 10-second clip (RTX 4090)

**Balanced**:
- Resolution: 1024x576
- Steps: 35
- Guidance: 7.5
- LoRA: 0.85
- Error Recycling: Every 3 clips
- **Time**: ~2 minutes per 10-second clip (RTX 4090)

**Fast Preview**:
- Resolution: 768x432
- Steps: 20
- Guidance: 6.5
- LoRA: 0.8
- Error Recycling: Every 5 clips
- **Time**: ~30 seconds per 10-second clip (RTX 4090)

## Integration with Other Tools

### ControlNet Integration

Supported ControlNet types:
- **OpenPose**: For dance and character animation
- **Depth**: For 3D-consistent camera movement
- **Canny**: For edge-guided generation
- **Temporal**: For motion consistency

### Post-Processing Pipeline

Recommended workflow:
1. Generate video with SVI
2. Upscale with Video Upscaler (e.g., Real-ESRGAN)
3. Interpolate frames with RIFE/FILM
4. Color grade in DaVinci Resolve or After Effects
5. Apply stabilization if needed

### Combining with Other Models

**SVI + Depth Estimation**:
- Generate depth maps with DepthAnything
- Use as ControlNet conditioning
- Achieve 3D-consistent motion

**SVI + Segmentation**:
- Extract subject masks with SAM
- Apply different prompts to different regions
- Create composite scenes

## Example Workflows (JSON)

### Workflow 1: SVI-Shot Basic Loop

See: `workflows/svi/svi-shot-basic-loop.json`

**Description**: Simple infinite loop for single-scene animation

**Parameters**:
- Model: WAN 2.1 I2V
- LoRA: SVI-Shot (0.9)
- Clip Length: 3 seconds
- Loop Count: Unlimited

### Workflow 2: SVI-Film Multi-Scene

See: `workflows/svi/svi-film-multi-scene.json`

**Description**: Multi-scene narrative with transitions

**Parameters**:
- Model: WAN 2.1 I2V
- LoRA: SVI-Film-Transitions (0.85)
- Scene Count: 5
- Scene Length: 10 seconds each

### Workflow 3: SVI-Dance ControlNet

See: `workflows/svi/svi-dance-controlnet.json`

**Description**: Character animation with pose guidance

**Parameters**:
- Model: WAN 2.1 I2V
- LoRA: SVI-Dance (1.0)
- ControlNet: OpenPose
- Resolution: 768x1024

## Resources

### Official Links

- **SVI GitHub**: https://github.com/vita-epfl/Stable-Video-Infinity
- **SVI Homepage**: https://stable-video-infinity.github.io/homepage/
- **LoRA Models**: https://huggingface.co/Kijai/WanVideo_comfy
- **ComfyUI-WanVideoWrapper**: https://github.com/kijai/ComfyUI-WanVideoWrapper

### Community

- **ComfyUI Discord**: Ask in #video-generation channel
- **GitHub Issues**: Report bugs and request features
- **Reddit**: r/StableDiffusion, r/ComfyUI

### Related Research

- **Paper**: "Stable Video Infinity: Infinite-Length Video Generation with Error Recycling"
- **ArXiv**: Check SVI GitHub for paper link
- **WAN 2.1**: https://github.com/Wan-Video/Wan2.1

## License

- **SVI**: Check official repository for license
- **WAN 2.1**: Apache 2.0
- **LoRA Models**: CC-BY-NC (Non-commercial use)

## Credits

- **SVI Team**: VITA Lab, EPFL
- **Kijai**: ComfyUI wrapper and LoRA conversions
- **WAN Team**: Base video generation model
- **Community Contributors**: Workflow improvements and testing

## Updates and Changelog

### 2025-11-02
- Initial setup documentation
- Added all SVI LoRA variants
- Created example workflows
- Installation scripts and guides

---

**Next Steps**: See [QUICKSTART-SVI.md](QUICKSTART-SVI.md) for a quick start guide with minimal configuration.
