# 🚀 BUDDY-SD-Fast: CPU Image Generator

## Overview
Image generation using Stable Diffusion with CPU processing. This is the image generation service for the BUDDY AI assistant.

## Features
- 🎯 **Reliable Generation**: 5-10 minutes generation time
- 🔄 **Stable Performance**: CPU-based for consistent results
- 📱 **API Compatible**: Works with existing BUDDY backend
- 🆓 **Free Hosting**: Uses Hugging Face Spaces free tier

## Setup Instructions

### 1. Create Hugging Face Space
1. Go to [Hugging Face Spaces](https://huggingface.co/spaces)
2. Click "Create new Space"
3. Choose settings:
   - **Owner**: Your username
   - **Space name**: `BUDDY-SD-Fast`
   - **SDK**: **Docker** (for FastAPI)
   - **Hardware**: **CPU**
   - **License**: MIT

### 2. Upload Files
Upload these files to your Space:
- `app.py` - Main FastAPI application
- `requirements.txt` - Dependencies (see below for important pinning)
- `README.md` - This file

### 3. Pin Required Package Versions
**Important:** For compatibility with `diffusers==0.24.0`, you must pin `huggingface_hub==0.19.4` in your `requirements.txt`:

```
diffusers==0.24.0
transformers==4.36.0
torch==2.1.0
torchvision==0.16.0
huggingface_hub==0.19.4
```

- Do **not** include `streamlit` or `xformers` (not needed for CPU/FastAPI setup).

### 4. Deploy
The Space will automatically build and deploy. Check the logs for any issues.

## API Usage

### Endpoint
```
POST https://chiefmaybe-buddy-sd.hf.space/generate
```

### Request Format
```json
{
  "prompt": "your prompt here"
}
```

### Response
Returns image bytes (PNG format) that can be uploaded to Cloudinary.

## Integration with BUDDY Backend

### Current Backend Configuration
Your local backend (`app.py`) is configured to call this endpoint:

```python
# Current configuration in your local app.py
hf_url = "https://chiefmaybe-buddy-sd.hf.space/generate"
```

### Backend Logic
```python
# Your backend forwards requests to this space
response = requests.post(hf_url, json=json_data, headers=headers, timeout=2000)
```

## Performance

### Expected Times
- **Simple prompts**: 5-7 minutes
- **Complex prompts**: 8-10 minutes
- **Timeout**: 33 minutes (as configured in your backend)

### Optimization
- Uses `torch.float32` for CPU compatibility
- `low_cpu_mem_usage=True` for memory efficiency
- Disabled safety checker for speed
- Model loaded once at startup

## Troubleshooting

### Common Issues
1. **ImportError: cannot import name 'cached_download' from 'huggingface_hub'**
   - This means your `huggingface_hub` version is too new for `diffusers==0.24.0`.
   - **Solution:** Pin `huggingface_hub==0.19.4` in your `requirements.txt` and rebuild.
2. **Model loading fails**: Check CPU availability
3. **Generation timeout**: System will automatically retry
4. **Memory issues**: Reduce inference steps in settings

### Debug Commands
```bash
# Test API endpoint
curl -X POST "https://chiefmaybe-buddy-sd.hf.space/generate" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "test prompt"}'

# Check Space status
curl "https://chiefmaybe-buddy-sd.hf.space/health"
```

## Files Structure
```
BUDDY-SD-Fast/
├── app.py              # Main FastAPI application
├── requirements.txt    # Dependencies
└── README.md          # This documentation
```

## Status
- ✅ **Ready for deployment**
- ✅ **API compatible with existing backend**
- ✅ **Performance optimized for CPU**
- ✅ **Free tier hosting**

---
**Part of BUDDY AI Assistant System**
**Image Generation Service** 