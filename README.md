# BUDDY Image Generation API

A FastAPI-based image generation service for the BUDDY AI assistant, deployed on Hugging Face Spaces.

## Features

- Stable Diffusion image generation via Hugging Face Spaces
- Cloudinary integration for image storage
- RESTful API endpoints
- Health monitoring
- Error handling and logging

## Deployment on Hugging Face Spaces

### 1. Create a New Space

1. Go to [Hugging Face Spaces](https://huggingface.co/spaces)
2. Click "Create new Space"
3. Choose "Docker" as the SDK
4. Set the Space name (e.g., "buddy-image-generator")
5. Set visibility (Public or Private)

### 2. Environment Variables

In your Space settings, add these environment variables:

```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### 3. Files Structure

Your Space should have these files:
- `app.py` - Main FastAPI application
- `requirements.txt` - Python dependencies
- `Dockerfile` - Container configuration
- `README.md` - This file

### 4. API Endpoints

- `GET /` - API information and status
- `GET /health` - Health check
- `POST /generate` - Generate image from text prompt

### 5. Usage Example

```bash
curl -X POST "https://your-space-name.hf.space/generate" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "a beautiful sunset over mountains"}'
```

Response:
```json
{
  "url": "https://res.cloudinary.com/.../image/upload/...",
  "prompt": "a beautiful sunset over mountains",
  "status": "success"
}
```

## Local Development

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set environment variables:
```bash
export CLOUDINARY_CLOUD_NAME=your_cloud_name
export CLOUDINARY_API_KEY=your_api_key
export CLOUDINARY_API_SECRET=your_api_secret
```

3. Run the application:
```bash
uvicorn app:app --host 0.0.0.0 --port 7860
```

## Troubleshooting

### Common Issues

1. **NumPy Version Conflict**: The app uses NumPy 1.24.3 to avoid compatibility issues
2. **Cache Directory Permissions**: Cache directories are set to `/tmp/` for write access
3. **Memory Issues**: The app uses CPU-only inference to avoid GPU memory problems

### Debug Endpoints

- `GET /health` - Check if the pipeline loaded successfully
- Check the Space logs for detailed error messages

## Integration with BUDDY Frontend

This API is designed to work with the BUDDY SwiftUI frontend. The frontend can:

1. Send text prompts to `/generate`
2. Display the returned image URL
3. Handle errors gracefully

## License

This project is part of the BUDDY AI assistant system. 