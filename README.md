# BUDDY AI Assistant

A cross-platform AI assistant with local LLM chat and cloud-based image generation.

## Features

- **Local LLM Chat**: Ollama running locally for instant, private conversations
- **Cloud Image Generation**: Stable Diffusion via Hugging Face Spaces (CPU-only)
- **Image Storage**: Cloudinary integration for generated images
- **Cross-Platform**: SwiftUI app for iOS and macOS
- **Local-First**: Chat stays private on your machine

## Architecture

### Local Components (Your Mac)
- **SwiftUI Frontend**: User interface for chat and image generation
- **FastAPI Backend**: Lightweight proxy server (`localhost:8000`)
- **Ollama**: Local LLM service for chat (`localhost:11434`)

### Cloud Components
- **Hugging Face Space**: CPU-based image generation (`chiefmaybe-buddy-sd.hf.space`)
- **Cloudinary**: Image storage and delivery

## Setup Instructions

### 1. Backend (FastAPI)
```bash
# Install dependencies
pip install -r requirements.txt

# Set up Cloudinary credentials (see env.example)
export CLOUDINARY_CLOUD_NAME=your_cloud_name
export CLOUDINARY_API_KEY=your_api_key
export CLOUDINARY_API_SECRET=your_api_secret

# Start the backend
./restart_backend.sh
```

### 2. Ollama (LLM Chat)
```bash
# Install Ollama: https://ollama.com/
# Start the desired model
ollama run mistral
```

### 3. SwiftUI App
- Open `BUDDY.xcodeproj` in Xcode
- Build and run on your device or simulator
- App connects to backend at `http://localhost:8000`

### 4. Hugging Face Space (Image Generation)
- The Space runs in the cloud using the Docker runtime.
- The backend is configured to send image generation requests to the public Space URL (e.g., `https://chiefmaybe-buddy-sd.hf.space/generate`).
- **Important:** In `requirements.txt`, pin `huggingface_hub==0.19.4` for compatibility with `diffusers==0.24.0`.
- Do **not** include `streamlit` or `xformers`.

## How It Works

### Chat Flow
1. User enters prompt in SwiftUI app
2. Backend forwards to local Ollama instance
3. Ollama generates response
4. Response displayed in app

### Image Generation Flow
1. User enters image prompt in SwiftUI app
2. Backend forwards to Hugging Face Space
3. Space generates image (5-10 minutes)
4. Backend uploads image to Cloudinary
5. Cloudinary URL returned to app
6. Image displayed in app

## API Endpoints

- `GET /` - API information
- `GET /health` - Health check
- `POST /chat` - Chat with Ollama
- `POST /generate` - Generate image via Hugging Face Space

## Environment Variables

Required in `env.example`:
```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

## Troubleshooting

- **ImportError: cannot import name 'cached_download' from 'huggingface_hub'**
  - Pin `huggingface_hub==0.19.4` in your requirements.txt and rebuild the Space.
- **Chat not working**: Ensure Ollama is running with `ollama run mistral`
- **Images not generating**: Check Hugging Face Space is running
- **Images not displaying**: Verify Cloudinary credentials
- **Backend issues**: Use `./restart_backend.sh` to restart

## Current Status

- ✅ Local chat pipeline working
- ✅ Cloud image generation working
- ✅ SwiftUI frontend connected
- ✅ Cloudinary integration working

## License

This project is part of the BUDDY AI assistant system. 