# B.U.D.D.Y. (Basic Utility Droid Designed for You)

A cross-platform AI assistant for Mac and iPhone, built with SwiftUI frontend and cloud-based AI services.

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

## 🔧 API Endpoints

### Image Generation Service (`app.py`)

- `GET /` - API information and status
- `GET /health` - Health check
- `POST /generate` - Generate image from text prompt

**Example Usage:**
```bash
curl -X POST "https://your-space-name.hf.space/generate" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "a cute robot assistant"}'
```

**Response:**
```json
{
  "url": "https://res.cloudinary.com/.../image/upload/...",
  "prompt": "a cute robot assistant",
  "status": "success"
}
```

## 🎯 Features & Capabilities

### ✅ Implemented
- FastAPI image generation service
- Cloudinary integration
- Hugging Face Spaces deployment
- Basic error handling and logging
- Health monitoring endpoints

### 🚧 In Progress
- SwiftUI frontend development
- Voice-to-text integration
- LLM integration (Ollama/Hugging Face)
- Cross-platform compatibility

### 📋 Planned
- Authentication system
- Conversation history
- Voice synthesis (TTS)
- Advanced UI/UX features
- Mobile app deployment

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
   - Multi-modal input (text + image)
   - Conversation memory and context
   - Custom AI model fine-tuning

2. **User Experience**
   - Voice commands and responses
   - Gesture-based interactions
   - Dark/light mode themes

3. **Integration**
   - Calendar and reminder integration
   - File management capabilities
   - Third-party service connections

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