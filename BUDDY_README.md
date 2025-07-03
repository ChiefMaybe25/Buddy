# B.U.D.D.Y. Assistant

## New UI & Voice Features (July 2025)
- Animated buddy avatar with bobbing and green glow when thinking
- Glowing 'please wait while I am thinking...' bubble for user feedback
- Custom app icon and avatar, themed as a friendly droid companion
- Modern, card-based UI with chat bubbles and image generator
- **Voice Input:** Speak to BUDDY using the microphone button (speech-to-text)
- **Voice Output:** BUDDY replies are spoken aloud using Apple TTS (with replay button)
- **iOS Device Support:** App runs on real iPhones (not just simulator)

## Current Progress
- Fully functional chat and image generation
- Voice input/output (speech-to-text and text-to-speech)
- iOS device support with proper network config
- All UI and assets updated for a beautiful, interactive experience

## Overview
B.U.D.D.Y. is a cross-platform AI assistant app with the following architecture:

- **Frontend:** SwiftUI app (macOS/iOS, now supports real iPhones)
- **Backend:** FastAPI (Python, runs locally, started with 4 workers for parallel/concurrent requests, must use 0.0.0.0 for iOS device access)
- **Image Generation:** Hugging Face Space (Docker runtime, runs in the cloud)
- **Image Hosting:** Cloudinary (for storing and serving generated images)
- **LLM Chat:** Local Ollama instance (for chat, runs on your machine)

## How It Works
1. **User enters or speaks a prompt in the SwiftUI app** (either for chat or image generation).
2. **Chat prompts** are sent to the FastAPI backend, which forwards them to a local Ollama LLM (e.g., mistral) and returns the response.
3. **Image prompts** are sent to the FastAPI backend, which forwards them to the Hugging Face Space `/generate` endpoint. The Space generates an image and returns it to the backend, which uploads it to Cloudinary and returns the image URL to the app.
4. **BUDDY replies are spoken aloud and can be replayed.**

## Setup Instructions

### 1. Backend (FastAPI)
- Install dependencies:
  ```sh
  pip install -r requirements.txt
  ```
- Set up Cloudinary credentials (see `env.example`).
- Start the backend (must use 0.0.0.0 for iOS device access):
  ```sh
  uvicorn app:app --host 0.0.0.0 --port 8000
  # or
  ./restart_backend.sh
  ```

### 2. Hugging Face Space (Image Generation)
- The Space runs in the cloud using the Docker runtime.
- The backend is configured to send image generation requests to the public Space URL (e.g., `https://chiefmaybe-buddy-sd.hf.space/generate`).

### 3. Ollama (LLM Chat)
- Install Ollama on your local machine: https://ollama.com/
- Start the desired model (e.g., mistral):
  ```sh
  ollama run mistral
  ```
- The backend will connect to `http://localhost:11434/api/generate` for chat requests.

### 4. SwiftUI App (iOS/macOS)
- Open `BUDDY.xcodeproj` in Xcode
- **For iOS device:**
  - Set the backend URL in the Swift code to your Mac's local IP (e.g., `http://192.168.1.10:8000`)
  - Make sure your iPhone and Mac are on the same Wi-Fi
  - Build and run on your iPhone (free Apple ID is fine)
  - Trust the developer certificate on your iPhone if prompted
- **For Simulator/Mac:**
  - You can use `http://localhost:8000`

## What's NOT Included
- No zeroGPU, Streamlit, Gradio, or other future/alternative runtimes.
- No public content filtering or compliance features (personal use only).
- No multi-user or cloud-based LLM chat (Ollama is local only).

## Troubleshooting
- If image generation is slow, it's due to free CPU on Hugging Face Spaces.
- If chat doesn't work, make sure Ollama is running locally.
- If images don't appear, check Cloudinary credentials and backend logs.
- If chat or image requests block each other, make sure the backend is running with 4 workers (see `restart_backend.sh`).
- **Could not connect to server (on iPhone):**
  - Make sure backend is running on your Mac with `--host 0.0.0.0`
  - Use your Mac's local IP in the app, not `localhost`
  - Both devices must be on the same Wi-Fi
  - Allow Python/Terminal through your Mac firewall
- **Microphone or speech not working**: Check Info.plist permissions and iOS Settings > Privacy

## Permissions (iOS)
- Add these to your Info.plist:
  - `NSMicrophoneUsageDescription`: This app needs access to your microphone for speech input.
  - `NSSpeechRecognitionUsageDescription`: This app uses speech recognition to let you talk to BUDDY.

## License
See LICENSE for details. 