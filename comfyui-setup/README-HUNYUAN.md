# HunyuanWorld-Mirror: Universal 3D World Reconstruction

## Overview

HunyuanWorld-Mirror is a state-of-the-art universal feed-forward model for comprehensive 3D geometric prediction developed by Tencent's Hunyuan team. Released in October 2025, it represents a significant advancement in 3D reconstruction technology.

## Key Capabilities

### Universal Geometric Prediction

HunyuanWorld-Mirror can simultaneously generate various 3D representations in a single forward pass:

1. **Point Clouds**: Dense 3D point representations
2. **Multi-View Depths**: Depth maps from multiple viewpoints
3. **Camera Parameters**: Intrinsic and extrinsic camera calibration
4. **Surface Normals**: Surface orientation information
5. **3D Gaussian Splats**: For real-time rendering

### Multi-Modal Prior Prompting

The model accepts diverse inputs and priors:

- **Images**: Single or multiple views
- **Videos**: Sequential frames for temporal consistency
- **Depth Maps**: Pre-computed or estimated depth
- **Camera Poses**: Known camera positions and orientations
- **Calibrated Intrinsics**: Camera focal length, principal point, etc.

## Architecture

### Core Components

1. **Multi-Modal Prior Encoding**
   - Lightweight encoding layers convert each prior modality into structured tokens
   - Supports flexible combination of different priors
   - Handles missing or partial prior information

2. **Feed-Forward Geometry Prediction**
   - Single-pass inference for efficiency
   - Unified architecture for all reconstruction tasks
   - Transformer-based attention mechanisms

3. **3D Gaussian Splatting (3DGS)**
   - Real-time rendering capability
   - High-quality visual output
   - Efficient memory usage

### Technical Specifications

- **Model Size**: Large-scale diffusion model
- **Input Resolution**: Flexible (typically 512x512 to 1024x1024)
- **Output Formats**: PLY, OBJ, GLB, SPLAT
- **Inference Speed**: ~1-5 seconds per frame (GPU-dependent)
- **Memory Requirements**: 12GB+ VRAM for optimal performance

## Use Cases

### 1. Single-View 3D Reconstruction

Convert a single image into a 3D model:

**Input**: Single RGB image
**Output**: 3D mesh, point cloud, or Gaussian splat

**Applications**:
- Product modeling from photos
- Virtual try-on systems
- AR/VR content creation
- Digital twin generation

**Example**:
```python
# Load single image
image = load_image("product.jpg")

# Reconstruct 3D
model = reconstruct_3d(
    image=image,
    mode="single_view",
    output_format="mesh"
)
```

### 2. Multi-View 3D Reconstruction

Create detailed 3D models from multiple viewpoints:

**Input**: Multiple images from different angles
**Output**: High-quality 3D model with complete coverage

**Applications**:
- Photogrammetry
- Cultural heritage digitization
- Architecture reconstruction
- Real estate virtual tours

**Example**:
```python
# Load multiple views
images = load_images(["view1.jpg", "view2.jpg", "view3.jpg"])

# Reconstruct with camera estimation
model = reconstruct_3d(
    images=images,
    mode="multi_view",
    estimate_cameras=True
)
```

### 3. Video to 3D Scene

Transform video footage into explorable 3D environments:

**Input**: Video file or frame sequence
**Output**: Complete 3D scene reconstruction

**Applications**:
- Video game asset creation
- Movie pre-visualization
- Urban planning
- Autonomous vehicle simulation

**Example**:
```python
# Load video
video = load_video("walkthrough.mp4")

# Extract and reconstruct
scene = reconstruct_3d(
    video=video,
    mode="video",
    temporal_consistency=True
)
```

### 4. Depth Estimation

Extract accurate depth information from images:

**Input**: RGB image
**Output**: Dense depth map

**Applications**:
- Robotics navigation
- Augmented reality
- Portrait mode effects
- 3D photo effects

### 5. Camera Calibration

Automatic camera parameter estimation:

**Input**: Single or multiple images
**Output**: Camera intrinsics and extrinsics

**Applications**:
- SLAM (Simultaneous Localization and Mapping)
- Structure from Motion
- Computer vision research
- Camera calibration tools

## Model Variants

### HunyuanWorld-Mirror v1.0

- **Release**: October 2025
- **Focus**: Universal 3D reconstruction
- **Strengths**: Single and multi-view reconstruction
- **VRAM**: 12GB+ recommended

### HunyuanWorld-Mirror v1.1 (WorldMirror)

- **Release**: October 2025
- **Focus**: 3D world creation from video/multi-view images
- **Enhancements**: Improved temporal consistency
- **VRAM**: 16GB+ recommended

## Technical Details

### Input Specifications

**Image Requirements**:
- Format: JPG, PNG, BMP
- Resolution: 512x512 minimum, 1024x1024 recommended
- Color space: RGB
- Bit depth: 8-bit or 16-bit

**Video Requirements**:
- Format: MP4, AVI, MOV
- Frame rate: 30fps recommended
- Resolution: 720p minimum, 1080p recommended
- Codec: H.264 or H.265

### Output Specifications

**Point Cloud (PLY)**:
- Format: Binary or ASCII PLY
- Points: 10K to 1M points
- Attributes: Position, color, normal

**Mesh (OBJ)**:
- Format: Wavefront OBJ + MTL
- Triangles: 50K to 500K faces
- Textures: Optional UV mapping

**Gaussian Splat (SPLAT)**:
- Format: Custom splat format
- Gaussians: Variable count
- Rendering: Real-time capable

**3D Model (GLB)**:
- Format: Binary glTF 2.0
- PBR Materials: Supported
- Animations: Optional

## Performance Benchmarks

### Reconstruction Quality

| Method | PSNR↑ | SSIM↑ | LPIPS↓ |
|--------|-------|-------|--------|
| HunyuanWorld-Mirror | **28.5** | **0.92** | **0.08** |
| DUSt3R | 26.3 | 0.88 | 0.12 |
| NeRF | 27.1 | 0.89 | 0.11 |
| 3DGS | 27.8 | 0.90 | 0.09 |

### Speed Comparison

| Task | HunyuanWorld-Mirror | Traditional Methods |
|------|---------------------|---------------------|
| Single-view reconstruction | 2s | 30-60s |
| Multi-view (5 views) | 5s | 2-5min |
| Video (100 frames) | 30s | 10-30min |

*Benchmarks on NVIDIA A100 GPU

### Memory Usage

| Input Size | VRAM Usage | RAM Usage |
|------------|------------|-----------|
| 512x512 | 8GB | 4GB |
| 1024x1024 | 12GB | 8GB |
| 2048x2048 | 20GB | 16GB |

## Advanced Features

### 1. Prior Integration

Combine multiple priors for better results:

```python
reconstruction = model.reconstruct(
    image=image,
    depth_prior=depth_map,
    camera_prior=camera_params,
    normal_prior=normal_map
)
```

### 2. Uncertainty Estimation

Get confidence maps for predictions:

```python
result = model.reconstruct_with_uncertainty(
    image=image,
    return_confidence=True
)

depth = result.depth
confidence = result.confidence_map  # 0-1 values
```

### 3. Semantic Segmentation Integration

Combine with semantic understanding:

```python
reconstruction = model.reconstruct(
    image=image,
    semantic_mask=segmentation,
    preserve_boundaries=True
)
```

### 4. Texture Optimization

Enhance texture quality post-reconstruction:

```python
model.optimize_texture(
    mesh=reconstructed_mesh,
    source_images=images,
    iterations=100
)
```

## Comparison with Other Methods

### vs. NeRF (Neural Radiance Fields)

| Feature | HunyuanWorld-Mirror | NeRF |
|---------|---------------------|------|
| Speed | Fast (single pass) | Slow (per-scene training) |
| Generalization | Excellent | Poor (per-scene) |
| Novel view synthesis | Good | Excellent |
| Real-time rendering | Yes (3DGS) | No |
| Training required | No | Yes |

### vs. Traditional Photogrammetry

| Feature | HunyuanWorld-Mirror | Photogrammetry |
|---------|---------------------|----------------|
| Input requirements | Flexible | Strict (overlap, lighting) |
| Processing time | Fast | Slow |
| Quality | High | Very High |
| Automation | Fully automatic | Manual steps required |
| Hardware | GPU required | CPU sufficient |

### vs. Depth Estimation Models

| Feature | HunyuanWorld-Mirror | DPT/MiDaS |
|---------|---------------------|-----------|
| Output | Full 3D + depth | Depth only |
| Multi-view | Native support | Single view |
| Camera estimation | Built-in | Not available |
| 3D export | Yes | No |

## Research Papers

HunyuanWorld-Mirror is based on cutting-edge research:

1. **"Universal 3D World Reconstruction with Any-Prior Prompting"**
   - Authors: Tencent Hunyuan Team
   - Date: October 2025
   - Topics: Multi-modal priors, feed-forward reconstruction

2. **Related Work**:
   - Gaussian Splatting for Real-Time Radiance Field Rendering
   - DUSt3R: Geometric 3D Vision Made Easy
   - Zero-1-to-3: Zero-shot One Image to 3D Object

## Integration Examples

### Python API

```python
from hunyuan_world import WorldMirror

# Initialize model
model = WorldMirror.from_pretrained(
    "tencent/HunyuanWorld-Mirror",
    device="cuda"
)

# Single view reconstruction
output = model.reconstruct(
    image="input.jpg",
    mode="single_view",
    output_format=["mesh", "depth", "normal"]
)

# Export results
output.save_mesh("output.obj")
output.save_depth("depth.png")
output.save_normal("normal.png")
```

### ComfyUI Workflow

See `workflows/hunyuan_basic_workflow.json` for a complete example.

### REST API

```python
import requests

response = requests.post(
    "http://localhost:8188/api/hunyuan/reconstruct",
    files={"image": open("input.jpg", "rb")},
    data={"mode": "single_view", "format": "mesh"}
)

result = response.json()
```

## Best Practices

### 1. Input Preparation

- Use well-lit, high-quality images
- Avoid motion blur and compression artifacts
- Ensure good texture and detail visibility
- Use multiple views when possible

### 2. Parameter Tuning

- Start with default settings
- Adjust based on input quality
- Use depth priors for better accuracy
- Enable camera estimation for multi-view

### 3. Post-Processing

- Clean up artifacts in 3D editing software
- Retopologize meshes for game engines
- Optimize texture maps
- Apply PBR materials

### 4. Performance Optimization

- Use batch processing for multiple images
- Enable mixed precision (FP16) for speed
- Reduce resolution for previews
- Cache intermediate results

## Limitations

### Current Limitations

1. **Transparent Objects**: Limited support for glass, water, etc.
2. **Specular Surfaces**: Shiny metals can be challenging
3. **Thin Structures**: Hair, wires may not reconstruct well
4. **Scale Ambiguity**: Single-view reconstruction lacks absolute scale
5. **Occluded Regions**: Hidden areas are hallucinated

### Recommended Solutions

- Use multi-view for better coverage
- Provide depth priors for difficult materials
- Manual cleanup in 3D software for critical details
- Combine with traditional methods for best quality

## Future Developments

Planned improvements:
- Enhanced temporal consistency for video
- Better handling of transparent materials
- Improved texture resolution
- Faster inference speeds
- Mobile device support

## Related Models from Hunyuan

### HunyuanWorld-1.0

- Text-to-3D world generation
- Interactive environment creation
- Consumer GPU support (lite version)

### Hunyuan3D-2.0

- Image to high-resolution 3D assets
- Texture generation
- PBR material support

### HunyuanVideo

- Text-to-video generation
- Can be combined with World-Mirror for 3D video

## Community Resources

- **GitHub**: https://github.com/Tencent-Hunyuan/HunyuanWorld-Mirror
- **Hugging Face**: https://huggingface.co/tencent/HunyuanWorld-Mirror
- **Demo**: https://huggingface.co/spaces/tencent/HunyuanWorld-Mirror
- **Discord**: Check GitHub for community links

## Citation

If you use HunyuanWorld-Mirror in your research, please cite:

```bibtex
@article{hunyuanworld2025,
  title={Universal 3D World Reconstruction with Any-Prior Prompting},
  author={Tencent Hunyuan Team},
  journal={arXiv preprint},
  year={2025}
}
```

## License

Check the official repository for license information:
https://github.com/Tencent-Hunyuan/HunyuanWorld-Mirror

---

Last updated: October 2025
