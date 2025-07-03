# B.U.D.D.Y. Assistant

## Overview
B.U.D.D.Y. is a cross-platform AI assistant app with the following architecture:

- **Frontend:** SwiftUI app (macOS/iOS)
- **Backend:** FastAPI (Python, runs locally, started with 4 workers for parallel/concurrent requests)
- **Image Generation:** Hugging Face Space (Docker runtime, runs in the cloud)
- **Image Hosting:** Cloudinary (for storing and serving generated images)
- **LLM Chat:** Local Ollama instance (for chat, runs on your machine)

## How It Works
1. **User enters a prompt in the SwiftUI app** (either for chat or image generation).
2. **Chat prompts** are sent to the FastAPI backend, which forwards them to a local Ollama LLM (e.g., mistral) and returns the response.
3. **Image prompts** are sent to the FastAPI backend, which forwards them to the Hugging Face Space `/generate` endpoint. The Space generates an image and returns it to the backend, which uploads it to Cloudinary and returns the image URL to the app.

## Setup Instructions

### 1. Backend (FastAPI)
- Install dependencies:
  ```sh
  pip install -r requirements.txt
  ```
- Set up Cloudinary credentials (see `env.example`).
- Start the backend:
  ```sh
  ./restart_backend.sh
  ```
  (This script will kill any running backend processes and start a new one with **4 workers** for parallel/concurrent requests.)

### 2. Hugging Face Space (Image Generation)
- The Space runs in the cloud using the Docker runtime.
- The backend is configured to send image generation requests to the public Space URL (e.g., `https://chiefmaybe-buddy-sd.hf.space/generate`).
- No local setup required for image generation.

### 3. Ollama (LLM Chat)
- Install Ollama on your local machine: https://ollama.com/
- Start the desired model (e.g., mistral):
  ```sh
  ollama run mistral
  ```
- The backend will connect to `http://localhost:11434/api/generate` for chat requests.

### 4. SwiftUI App
- The app communicates with the backend at `http://localhost:8000`.
- Make sure your backend is running before using the app.
- For iOS simulators, ensure network permissions are set if needed.

## What's NOT Included
- No zeroGPU, Streamlit, Gradio, or other future/alternative runtimes.
- No public content filtering or compliance features (personal use only).
- No multi-user or cloud-based LLM chat (Ollama is local only).

## Troubleshooting
- If image generation is slow, it's due to free CPU on Hugging Face Spaces.
- If chat doesn't work, make sure Ollama is running locally.
- If images don't appear, check Cloudinary credentials and backend logs.
- If chat or image requests block each other, make sure the backend is running with 4 workers (see `restart_backend.sh`).

## License
See LICENSE for details. 