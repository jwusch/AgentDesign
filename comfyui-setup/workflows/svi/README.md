# SVI Workflow Templates

This directory contains example ComfyUI workflow templates for Stable Video Infinity.

## Available Workflows

### 1. svi-shot-basic-loop.json
**Purpose**: Single-scene infinite loop generation

**Use Case**: Extend a single image into a looping video of any length

**Inputs**:
- Input image
- Text prompt
- Loop count (determines total length)

**LoRA**: SVI-Shot

**Recommended Settings**:
- Clip Length: 3 seconds
- LoRA Strength: 0.9
- Resolution: 1024x576

---

### 2. svi-film-multi-scene.json
**Purpose**: Multi-scene narrative video generation

**Use Case**: Create story-driven videos with scene transitions

**Inputs**:
- Initial image
- Prompt queue (one per scene)
- Scene count

**LoRA**: SVI-Film or SVI-Film-Transitions

**Recommended Settings**:
- Scene Length: 8-10 seconds
- LoRA Strength: 0.85
- Resolution: 1280x720

---

### 3. svi-dance-controlnet.json
**Purpose**: Character animation with pose guidance

**Use Case**: Animate characters with dance or motion from reference

**Inputs**:
- Character image
- Pose sequence or reference video
- Text prompt

**LoRA**: SVI-Dance

**LoRA**: OpenPose ControlNet

**Recommended Settings**:
- LoRA Strength: 1.0
- ControlNet Strength: 0.8
- Resolution: 768x1024 (portrait)

---

### 4. svi-film-long-form.json
**Purpose**: Full-length film generation with advanced controls

**Use Case**: Professional video production with multiple scenes and transitions

**Inputs**:
- Scene prompt stream
- Style reference images
- Transition preferences

**LoRA**: SVI-Film-Transitions

**Recommended Settings**:
- Scene Length: 10-15 seconds
- LoRA Strength: 0.85
- Resolution: 1280x720 or 1920x1080
- Error Recycling: Every 2 clips

---

## How to Use Workflows

### Loading a Workflow

1. Start ComfyUI
2. Click "Load" button in the UI
3. Navigate to this directory
4. Select the desired workflow JSON file
5. The workflow will load in the canvas

### Customizing Workflows

Each workflow contains nodes that can be modified:

**Model Nodes**:
- `Load Checkpoint`: Select WAN 2.1 I2V model
- `Load LoRA`: Select SVI variant and set strength

**Generation Nodes**:
- `Empty Latent Image`: Set resolution
- `KSampler`: Set steps, guidance, seed

**Prompt Nodes**:
- `Text Prompt`: Enter your description
- `Prompt Queue`: For multi-scene workflows

**Loop Nodes**:
- `Loop Controller`: Set iteration count
- `Error Recycling`: Configure correction frequency

### Saving Custom Workflows

1. Modify the loaded workflow
2. Click "Save" in ComfyUI
3. Choose a filename
4. Save in this directory for easy access

## Workflow Node Reference

### Essential Nodes for SVI

**Input Nodes**:
- `Load Image`: Input image for I2V generation
- `Load Video`: For V2V workflows (with ControlNet)

**Model Nodes**:
- `WAN Model Loader`: Loads WAN 2.1 base model
- `LoRA Loader`: Applies SVI LoRA adapters
- `ControlNet Loader`: For pose/depth guidance (optional)

**Processing Nodes**:
- `VAE Encode`: Converts image to latent space
- `KSampler Advanced`: Main generation node with custom settings
- `VAE Decode`: Converts latent back to image/video

**Loop Nodes** (Custom from WanVideoWrapper):
- `Video Loop Controller`: Manages clip generation loop
- `Error Recycling Node`: Corrects drift and degradation
- `Clip Concatenator`: Merges clips into final video

**Output Nodes**:
- `Save Video`: Exports final video file
- `Preview Video`: Shows result in ComfyUI

## Common Modifications

### Changing Resolution

Find the `Empty Latent Image` node and modify:
```json
{
  "width": 1024,
  "height": 576
}
```

Common resolutions:
- 512x288 (Fast, low VRAM)
- 768x432 (Balanced)
- 1024x576 (High quality)
- 1280x720 (Professional)
- 1920x1080 (4K, requires 24GB+ VRAM)

### Adjusting LoRA Strength

Find the `Load LoRA` node and modify:
```json
{
  "lora_name": "svi-shot_lora_rank_128_fp16.safetensors",
  "strength_model": 0.9,
  "strength_clip": 0.9
}
```

Recommended strengths:
- SVI-Shot: 0.8-1.0
- SVI-Film: 0.7-1.0
- SVI-Film-Transitions: 0.7-0.9
- SVI-Dance: 0.9-1.0

### Modifying Generation Steps

Find the `KSampler Advanced` node:
```json
{
  "steps": 35,
  "cfg": 7.5,
  "sampler_name": "euler_a",
  "scheduler": "normal"
}
```

Speed vs Quality:
- Fast: 20 steps, cfg 6.5
- Balanced: 35 steps, cfg 7.5
- Quality: 50 steps, cfg 8.5

### Changing Clip Length

Find the `Video Loop Controller` node:
```json
{
  "clip_length": 3,  // seconds
  "frame_rate": 30,
  "total_clips": 10
}
```

### Error Recycling Configuration

Find the `Error Recycling Node`:
```json
{
  "enabled": true,
  "frequency": 3,     // Recycle every N clips
  "strength": 0.5,    // Correction strength (0-1)
  "method": "blend"   // blend, replace, or adaptive
}
```

## Workflow Templates Explained

### Template 1: SVI-Shot Basic Loop

**Node Flow**:
```
Load Image (input.png)
    ↓
VAE Encode
    ↓
Load WAN Model
    ↓
Load SVI-Shot LoRA (0.9)
    ↓
Text Prompt ("your prompt")
    ↓
Loop Controller (10 iterations)
    ↓
┌─────────────────────┐
│ For each iteration: │
│  1. KSampler Gen    │
│  2. Error Recycle   │
│  3. Append Clip     │
│  4. Update Latent   │
└─────────────────────┘
    ↓
Concatenate Clips
    ↓
VAE Decode
    ↓
Save Video (output.mp4)
```

**Key Parameters**:
- LoRA: SVI-Shot (strength: 0.9)
- Clip Length: 3 seconds
- Steps: 35
- Guidance: 7.5
- Error Recycling: Every 3 clips

**Expected Output**:
- 30-second looping video (10 clips × 3 seconds)
- Consistent colors and motion
- Smooth transitions between clips

---

### Template 2: SVI-Film Multi-Scene

**Node Flow**:
```
Initial Image
    ↓
VAE Encode
    ↓
Load WAN Model
    ↓
Load SVI-Film-Transitions LoRA (0.85)
    ↓
Prompt Queue (scene list)
    ↓
Scene Controller (5 scenes)
    ↓
┌──────────────────────┐
│ For each scene:      │
│  1. Load Prompt      │
│  2. Generate Clip    │
│  3. Transition Blend │
│  4. Error Recycle    │
└──────────────────────┘
    ↓
Concatenate All Scenes
    ↓
VAE Decode
    ↓
Save Video (film.mp4)
```

**Key Parameters**:
- LoRA: SVI-Film-Transitions (strength: 0.85)
- Scene Length: 10 seconds
- Steps: 40
- Guidance: 8.0
- Transitions: Enabled (2 frame blend)

**Expected Output**:
- 50-second multi-scene video (5 scenes × 10 seconds)
- Smooth scene transitions
- Consistent visual style

---

### Template 3: SVI-Dance ControlNet

**Node Flow**:
```
Character Image + Reference Pose Video
    ↓
Pose Extractor (OpenPose)
    ↓
ControlNet Preprocessor
    ↓
Load WAN Model
    ↓
Load SVI-Dance LoRA (1.0)
    ↓
Load OpenPose ControlNet (0.8)
    ↓
Text Prompt ("character dancing...")
    ↓
Loop Through Pose Frames
    ↓
┌──────────────────────┐
│ For each frame set:  │
│  1. Apply Pose       │
│  2. Generate Frames  │
│  3. Error Recycle    │
└──────────────────────┘
    ↓
Concatenate
    ↓
VAE Decode
    ↓
Save Video (dance.mp4)
```

**Key Parameters**:
- LoRA: SVI-Dance (strength: 1.0)
- ControlNet: OpenPose (strength: 0.8)
- Steps: 45
- Guidance: 8.5
- Frame-by-frame pose matching

**Expected Output**:
- Character performing the dance from pose reference
- Consistent character appearance
- Smooth motion following poses

---

## Advanced Techniques

### Technique 1: Multi-LoRA Blending

Combine multiple SVI LoRAs for unique effects:

```json
{
  "lora_1": {
    "name": "svi-film",
    "strength": 0.6
  },
  "lora_2": {
    "name": "svi-transitions",
    "strength": 0.3
  }
}
```

### Technique 2: Dynamic Prompt Interpolation

Smoothly transition between different prompts:

```json
{
  "prompt_1": "Sunny day in the park",
  "prompt_2": "Rainy evening in the park",
  "interpolation_steps": 10
}
```

### Technique 3: Conditional Scene Branching

Create different paths based on content:

```json
{
  "condition": "if outdoor scene",
  "then": "use lighting LoRA",
  "else": "use indoor LoRA"
}
```

### Technique 4: Hierarchical Generation

Generate long videos in hierarchical structure:

1. Generate key frames (1 frame per 5 seconds)
2. Generate intermediate clips between key frames
3. Apply error recycling at both levels

## Troubleshooting Workflows

### Workflow Won't Load

**Error**: "Missing nodes" or "Unknown node type"

**Solution**:
1. Ensure ComfyUI-WanVideoWrapper is installed
2. Update ComfyUI to latest version
3. Check custom node compatibility

### Workflow Runs But No Output

**Error**: Workflow completes but no video file

**Solution**:
1. Check output path in "Save Video" node
2. Ensure output directory exists
3. Check disk space
4. Verify VAE Decode node is connected

### Slow Generation

**Issue**: Workflow takes too long

**Solutions**:
1. Reduce steps (35 → 25)
2. Lower resolution (1024x576 → 768x432)
3. Reduce clip length (4s → 2s)
4. Enable FP16 mode in settings

### Poor Quality Results

**Issue**: Blurry or inconsistent output

**Solutions**:
1. Increase steps (35 → 45)
2. Raise guidance (7.5 → 8.5)
3. Increase LoRA strength (0.8 → 0.9)
4. Enable error recycling more frequently

## Creating Custom Workflows

### Basic Workflow Template

Start with this minimal structure:

```json
{
  "nodes": [
    {
      "id": 1,
      "type": "LoadImage",
      "properties": {},
      "widgets_values": ["input.png"]
    },
    {
      "id": 2,
      "type": "WANModelLoader",
      "properties": {},
      "widgets_values": ["Wan2.1-I2V-14B"]
    },
    {
      "id": 3,
      "type": "LoraLoader",
      "properties": {},
      "widgets_values": ["svi-shot_lora_rank_128_fp16.safetensors", 0.9, 0.9]
    }
  ],
  "links": [
    [1, 1, 0, 2, 0, "IMAGE"],
    [2, 2, 0, 3, 0, "MODEL"]
  ]
}
```

### Adding Custom Nodes

To extend workflows with custom nodes:

1. Create node in ComfyUI UI
2. Configure parameters
3. Export workflow (Save button)
4. Edit JSON if needed
5. Test and iterate

## Best Practices

1. **Start Simple**: Use basic loops before complex multi-scene
2. **Test Settings**: Try different parameters on short clips first
3. **Save Versions**: Keep working versions of workflows
4. **Document Changes**: Add notes in workflow JSON
5. **Share**: Contribute improved workflows to community

## Resources

- **Video Tutorial**: https://youtu.be/43lh-3kV3bs
- **Official Workflows**: https://github.com/vita-epfl/Stable-Video-Infinity/tree/main/comfyui_workflow
- **ComfyUI Docs**: https://comfyui.readthedocs.io/
- **Discord**: #video-generation channel

---

For detailed usage instructions, see [QUICKSTART-SVI.md](../QUICKSTART-SVI.md) and [README-SVI.md](../README-SVI.md)
