# BUDDY AI Assistant

A cross-platform AI assistant with local LLM chat, cloud-based image generation, and now full voice input/output and iOS device support.

## Features

- **Local LLM Chat**: Ollama running locally for instant, private conversations
- **Cloud Image Generation**: Stable Diffusion via Hugging Face Spaces (CPU-only)
- **Image Storage**: Cloudinary integration for generated images
- **Cross-Platform**: SwiftUI app for iOS and macOS
- **Local-First**: Chat stays private on your machine
- **Voice Input**: Speak to BUDDY using the microphone button (speech-to-text)
- **Voice Output**: BUDDY replies are spoken aloud using Apple TTS (with replay button)
- **iOS Device Support**: App runs on real iPhones (not just simulator)
- **Modern UI**: Animated avatar, glowing 'thinking' bubble, scrollable chat history, and card-based design

## Architecture

### Local Components (Your Mac)
- **SwiftUI Frontend**: User interface for chat and image generation
- **FastAPI Backend**: Lightweight proxy server (now accessible via your Mac's local IP for iOS devices)
- **Ollama**: Local LLM service for chat

### Cloud Components
- **Hugging Face Space**: CPU-based image generation
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

# Start the backend (must use 0.0.0.0 for iOS device access)
uvicorn app:app --host 0.0.0.0 --port 8000
# or
./restart_backend.sh
```

### 2. Ollama (LLM Chat)
```bash
# Install Ollama: https://ollama.com/
# Start the desired model
ollama run mistral
```

### 3. SwiftUI App (iOS/macOS)
- Open `BUDDY.xcodeproj` in Xcode
- **For iOS device:**
  - Set the backend URL in the Swift code to your Mac's local IP (e.g., `http://192.168.1.10:8000`)
  - Make sure your iPhone and Mac are on the same Wi-Fi
  - Build and run on your iPhone (free Apple ID is fine)
  - Trust the developer certificate on your iPhone if prompted
- **For Simulator/Mac:**
  - You can use `http://localhost:8000`

### 4. Hugging Face Space (Image Generation)
- The Space runs in the cloud using the Docker runtime.
- The backend is configured to send image generation requests to the public Space URL (e.g., `https://chiefmaybe-buddy-sd.hf.space/generate`).

## How It Works

### Chat Flow
1. User enters or speaks a prompt in the SwiftUI app
2. Backend forwards to local Ollama instance
3. Ollama generates response
4. Response displayed in app and spoken aloud

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

## Permissions (iOS)
- Add these to your Info.plist:
  - `NSMicrophoneUsageDescription`: This app needs access to your microphone for speech input.
  - `NSSpeechRecognitionUsageDescription`: This app uses speech recognition to let you talk to BUDDY.

## Troubleshooting

- **Could not connect to server (on iPhone):**
  - Make sure backend is running on your Mac with `--host 0.0.0.0`
  - Use your Mac's local IP in the app, not `localhost`
  - Both devices must be on the same Wi-Fi
  - Allow Python/Terminal through your Mac firewall
- **ImportError: cannot import name 'cached_download' from 'huggingface_hub'**
  - Pin `huggingface_hub==0.19.4` in your requirements.txt and rebuild the Space.
- **Chat not working**: Ensure Ollama is running with `ollama run mistral`
- **Images not generating**: Check Hugging Face Space is running
- **Images not displaying**: Verify Cloudinary credentials
- **Backend issues**: Use `./restart_backend.sh` to restart
- **Microphone or speech not working**: Check Info.plist permissions and iOS Settings > Privacy

## Current Progress

- Fully functional chat and image generation pipeline
- Voice input/output (speech-to-text and text-to-speech)
- iOS device support with proper network config
- Custom app icon and animated avatar (Buddy) in the UI
- Animated green glow and 'thinking' bubble when Buddy is processing
- Modern, friendly card-based UI with chat bubbles and image generator
- All assets are crisp for 1x, 2x, 3x resolutions

## License

This project is part of the BUDDY AI assistant system. 