# B.U.D.D.Y. (Basic Utility Droid Designed for You)

A cross-platform AI assistant for Mac and iPhone, built to run locally on your MacBook Pro (Apple M1, 16GB RAM) with a future-proof structure for easy cloud migration.

## 🚀 Project Overview

BUDDY is your personal AI assistant that can:
- Answer questions using LLMs (Ollama, running locally)
- Generate images using Stable Diffusion (Hugging Face Space or local SD)
- Process text and voice input
- **NEW: Analyze voice patterns for emotional intelligence**
- **NEW: Provide empathetic responses based on detected emotional states**
- **NEW: Offer mental health support and crisis detection**
- Run on both Mac and iPhone
- Store and deliver images via Cloudinary

## 🏗️ Local-First Architecture

1. **Frontend (SwiftUI app)**
   - User enters a prompt (text or image request)
   - Sends the prompt to the local backend (localhost or Mac IP)
2. **Backend (FastAPI or Node.js/Express, local)**
   - Handles API requests from the frontend
   - Forwards text prompts to Ollama (LLM, local)
   - Forwards image prompts to Hugging Face Space (or local SD)
   - Uploads generated images to Cloudinary
   - Returns answers and image URLs to the frontend
3. **Ollama (local)**
   - Runs LLMs (TinyLlama, Phi-2, Mistral 7B, etc.)
   - Backend communicates via HTTP API at http://localhost:11434
4. **Hugging Face Space (cloud) or local SD**
   - For image generation
5. **Cloudinary**
   - For image storage and delivery

### Diagram
```
SwiftUI App → Local Backend → (Text: Ollama → App) | (Image: HF Space/Local SD → Cloudinary → App)
```

## 🛠️ Local Setup Instructions

1. **Install Ollama** on your Mac: https://ollama.com/download
2. **Start Ollama** and run a model (e.g., `ollama run mistral`)
3. **Clone this repo** and set up your backend (FastAPI or Node.js)
4. **Install dependencies** (`pip install -r requirements.txt` or `npm install`)
5. **Start your backend** (`uvicorn app:app --reload` or `npm run dev`)
6. **Run the SwiftUI app** in Xcode
7. **Set up Cloudinary account** and add your credentials to `.env`
8. **(Optional) Set up Hugging Face Space for image generation**

## 🛣️ Roadmap & Current Step

### Core Features (Current)
- [x] Local-first pipeline: SwiftUI → Local backend → Local Ollama/Cloud APIs
- [x] Cloudinary for image storage
- [x] Hugging Face Space for image generation
- [x] Ollama running locally as backend LLM service
- [ ] Test full local pipeline (SwiftUI app → FastAPI backend → Ollama)
- [ ] (Optional) Local Stable Diffusion

### Voice Analysis & Emotional Intelligence (New)
- [ ] **Phase 1: Basic Voice Analysis**
  - [ ] Add voice recording capabilities to SwiftUI app
  - [ ] Implement real-time audio capture with AVAudioEngine
  - [ ] Create voice analysis endpoint in FastAPI backend
  - [ ] Basic emotion classification (calm, stressed, excited)
  - [ ] Audio feature extraction (pitch, rate, volume, tremors)

- [ ] **Phase 2: Emotional Intelligence**
  - [ ] Integrate emotion detection with Ollama responses
  - [ ] Add emotional state indicators in UI
  - [ ] Adaptive response generation based on detected emotions
  - [ ] Context-aware prompts for LLM (e.g., "User appears distressed")
  - [ ] Empathetic response templates

- [ ] **Phase 3: Advanced Mental Health Support**
  - [ ] Crisis detection algorithms
  - [ ] Emergency contact integration
  - [ ] Professional resource recommendations
  - [ ] Mental health disclaimers and safety features
  - [ ] Privacy controls for voice analysis

### Cloud Migration (Future)
- [ ] Containerize backend and Ollama with Docker
- [ ] Deploy to paid cloud server (Render, Paperspace, AWS, etc.)
- [ ] Update frontend to use cloud API endpoint
- [ ] Scale voice analysis for cloud deployment

### Migration to Cloud
- Containerize your backend and Ollama (Docker)
- Deploy containers to a paid cloud server
- Move environment variables/secrets to cloud host
- Update frontend API endpoint

## 🧠 Emotional Intelligence Features

### Voice Analysis Capabilities
- **Real-time emotion detection** from voice patterns
- **Acoustic feature analysis**: pitch, speaking rate, volume, voice tremors
- **Emotional state classification**: calm, stressed, excited, distressed
- **Adaptive response generation** based on detected emotions

### Mental Health Support
- **Crisis detection** for severe emotional distress
- **Emergency contact integration** for safety
- **Professional resource recommendations**
- **Privacy-first design** with local processing options

### Ethical Considerations
- **NOT a replacement for professional mental health care**
- **Clear disclaimers** about AI limitations
- **User consent** required for voice analysis
- **Privacy controls** to disable emotion detection
- **Crisis intervention** protocols for severe distress

## 🔒 Security & Privacy
- All API keys and secrets are stored as environment variables
- No secrets in code or repo
- **Voice data privacy**: Local processing when possible
- **Emotional data protection**: Secure handling of sensitive information
- **User control**: Option to disable voice analysis features

## 📚 See buddyoverview.txt and techstack.txt for more details

## 🚀 Project Overview

BUDDY is your personal AI assistant that can:
- Generate images using Stable Diffusion
- Process text and voice input
- Run on both Mac and iPhone
- Work entirely in the cloud (no local server required)

## 🏗️ Architecture

### Frontend (SwiftUI)
- **Platform**: iOS & macOS
- **Framework**: SwiftUI with Swift Package Manager
- **Location**: `BUDDY/` directory (Xcode project)

### Backend Services
- **Image Generation**: FastAPI + Stable Diffusion (Hugging Face Spaces)
- **Image Storage**: Cloudinary (free tier)
- **LLM**: Ollama (local) or Hugging Face APIs (cloud)
- **Voice-to-Text**: Hugging Face Whisper API

## 📁 Project Structure

```
BUDDY/
├── app.py                          # FastAPI image generation service
├── requirements.txt                # Python dependencies
├── Dockerfile                      # Container configuration
├── README.md                       # Hugging Face Spaces deployment guide
├── BUDDY_README.md                 # This comprehensive project guide
├── techstack.txt                   # Technical specifications
├── buddyoverview.txt               # Project overview and goals
├── backend/                        # Node.js backend (alternative)
│   ├── index.js
│   ├── package.json
│   └── Sources/main.swift
├── BUDDY/                          # SwiftUI iOS/macOS app
│   ├── BUDDYApp.swift
│   ├── Assets.xcassets/
│   └── Info.plist
└── BUDDY.xcodeproj/               # Xcode project files
```

## 🛠️ Tech Stack

### Development Environment
- **Device**: 2020 MacBook Pro M1
- **OS**: macOS Sequoia
- **IDE**: Cursor Version 1.1.6
- **Xcode**: Version 16.4

### Core Technologies
- **Frontend**: SwiftUI (iOS & macOS)
- **Backend**: FastAPI (Python) + Node.js/Express (alternative)
- **AI Models**: Ollama (local LLMs), Stable Diffusion
- **Voice Analysis**: AVAudioEngine, librosa, scikit-learn
- **Emotion Detection**: Pre-trained voice emotion recognition models
- **Cloud Services**: Cloudinary, Hugging Face Spaces
- **Package Managers**: Homebrew, npm, Swift Package Manager

## 🚀 Quick Start

### 1. Local Development Setup

```bash
# Install Python dependencies
pip install -r requirements.txt

# Set environment variables
export CLOUDINARY_CLOUD_NAME=your_cloud_name
export CLOUDINARY_API_KEY=your_api_key
export CLOUDINARY_API_SECRET=your_api_secret

# Run the FastAPI server
uvicorn app:app --host 0.0.0.0 --port 7860
```

### 2. Hugging Face Spaces Deployment

1. Create a new Space on Hugging Face
2. Choose "Docker" as SDK
3. Upload: `app.py`, `requirements.txt`, `Dockerfile`
4. Set environment variables in Space settings
5. Deploy

### 3. iOS/macOS App Development

1. Open `BUDDY.xcodeproj` in Xcode
2. Build and run on simulator or device
3. Configure API endpoints to point to your deployed services

## 🔍 Troubleshooting

### Common Issues

1. **NumPy Version Conflicts**
   - Solution: Use NumPy 1.24.3 (pinned in requirements.txt)

2. **Cache Directory Permissions**
   - Solution: Cache directories set to `/tmp/` for write access

3. **Memory Issues**
   - Solution: CPU-only inference to avoid GPU memory problems

4. **Import Errors**
   - Solution: Install dependencies with `pip install -r requirements.txt`

### Debug Commands

```bash
# Check API health
curl https://your-space-name.hf.space/health

# Test image generation
curl -X POST "https://your-space-name.hf.space/generate" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "test image"}'
```

## 📚 Development Guidelines

### Code Style
- **Python**: Follow PEP 8 standards
- **Swift**: Use SwiftFormat for consistent formatting
- **JavaScript**: Use Prettier for formatting

### Environment Management
- Use Miniconda for Python environments
- Use Homebrew for system dependencies
- Use Swift Package Manager for iOS dependencies

### Testing
- Test API endpoints locally before deployment
- Use Xcode simulator for iOS app testing
- Validate image generation with various prompts

## 🔐 Security Considerations

- Store API keys in environment variables
- Use HTTPS for all API communications
- Implement rate limiting for production use
- Validate user inputs on both frontend and backend

## 📈 Future Enhancements

1. **Advanced AI Features**
   - Multi-modal input (text + image + voice)
   - Conversation memory and context
   - Custom AI model fine-tuning
   - **Voice emotion recognition and adaptive responses**

2. **User Experience**
   - Voice commands and responses
   - **Real-time emotional state indicators**
   - **Empathetic response generation**
   - Gesture-based interactions
   - Dark/light mode themes

3. **Mental Health Support**
   - **Crisis detection and intervention**
   - **Professional resource integration**
   - **Emergency contact management**
   - **Privacy controls for voice analysis**

4. **Integration**
   - Calendar and reminder integration
   - File management capabilities
   - Third-party service connections
   - **Mental health service referrals**

## 🤝 Contributing

1. Follow the established code style
2. Test changes thoroughly
3. Update documentation as needed
4. Use meaningful commit messages

## 📄 License

This project is part of the BUDDY AI assistant system.

---

**Last Updated**: July 2025
**Version**: 1.0.0
**Status**: Active Development 

## 🛠️ Build Plan Amendment (July 2025)

- The current deployment uses a Docker-based Hugging Face Space with CPU-only hardware for maximum backend flexibility and custom FastAPI integration.
- ZeroGPU is not available for Docker Spaces; it is only available for Gradio/Streamlit SDK Spaces.
- After the full frontend (SwiftUI) implementation is complete and the main framework is working, we will:
  1. Attempt to build a new Gradio-based Space using ZeroGPU for much faster image generation.
  2. Use the Gradio/ZeroGPU Space as the primary image generation endpoint if stable.
  3. Retain the Docker/CPU Space as a backup for reliability and fallback.
- Previous attempts to use Gradio/ZeroGPU had dependency/version conflicts with our pinned requirements. We will revisit this after the main app is functional, and may need to adjust requirements or use a simplified pipeline for the Gradio version.
- This approach ensures we have a robust, flexible, and scalable system with both fast and reliable options. 