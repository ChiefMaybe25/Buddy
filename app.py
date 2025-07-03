from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import sys
from pathlib import Path

# Secure credential loading
try:
    from credential_loader import load_encrypted_credentials, check_credentials
    print("🔐 Loading encrypted credentials...")
    creds_loaded = load_encrypted_credentials()
    if not creds_loaded:
        print("⚠️  Failed to load encrypted credentials. Cloudinary may not work.")
    else:
        print("✅ Credentials loaded successfully!")
except ImportError as e:
    print(f"⚠️  Could not import credential loader: {e}")
    print("Cloudinary credentials may not be loaded securely.")

# Set up environment variables for Hugging Face Spaces
os.environ["TRANSFORMERS_CACHE"] = "/tmp/transformers_cache"
os.environ["HF_HOME"] = "/tmp/hf_home"
os.environ["HF_DATASETS_CACHE"] = "/tmp/datasets_cache"

# Create cache directories
for cache_dir in ["/tmp/transformers_cache", "/tmp/hf_home", "/tmp/datasets_cache"]:
    Path(cache_dir).mkdir(parents=True, exist_ok=True)

# Import required libraries
try:
    import cloudinary
    import cloudinary.uploader
    cloudinary_available = True
except ImportError as e:
    print(f"Import error: {e}")
    print("Cloudinary not available - image upload will fail")
    cloudinary_available = False

app = FastAPI(title="BUDDY Image Generation API", version="1.0.0")

# Cloudinary config (set your env vars in the Space settings for security)
if cloudinary_available:
    cloudinary.config(
        cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
        api_key=os.getenv("CLOUDINARY_API_KEY"),
        api_secret=os.getenv("CLOUDINARY_API_SECRET")
    )

class PromptRequest(BaseModel):
    prompt: str

class ChatRequest(BaseModel):
    prompt: str

@app.get("/")
async def root():
    return {
        "message": "BUDDY Image Generation API",
        "status": "running",
        "mode": "proxy_to_huggingface",
        "endpoints": {
            "generate": "/generate (POST)",
            "health": "/health (GET)",
            "chat": "/chat (POST)"
        }
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "mode": "proxy_to_huggingface",
        "cloudinary_configured": bool(os.getenv("CLOUDINARY_CLOUD_NAME"))
    }

@app.post("/generate")
async def generate_image(request: PromptRequest):
    """Proxy image generation request to Hugging Face Space"""
    import requests
    import json
    
    print(f"[BACKEND] Received image generation request: {request.prompt}")
    # Hugging Face Space URL
    hf_url = "https://chiefmaybe-buddy-sd.hf.space/generate"
    
    # Prepare the request for Hugging Face Space
    json_data = {"prompt": request.prompt}
    headers = {"Content-Type": "application/json"}
    
    try:
        print(f"[BACKEND] Forwarding to Hugging Face Space: {request.prompt}")
        # Send request to Hugging Face Space with 33-minute timeout
        response = requests.post(hf_url, json=json_data, headers=headers, timeout=2000)
        response.raise_for_status()
        print(f"[BACKEND] Received image bytes from Hugging Face Space for: {request.prompt}")
        
        # Get the image bytes from Hugging Face Space
        image_bytes = response.content
        
        # Upload to Cloudinary
        if not all([os.getenv("CLOUDINARY_CLOUD_NAME"), 
                    os.getenv("CLOUDINARY_API_KEY"), 
                    os.getenv("CLOUDINARY_API_SECRET")]):
            print("[BACKEND] Cloudinary configuration missing.")
            raise HTTPException(
                status_code=500, 
                detail="Cloudinary configuration missing. Please set CLOUDINARY_* environment variables."
            )
        print(f"[BACKEND] Uploading image to Cloudinary...")
        # Upload image bytes to Cloudinary
        result = cloudinary.uploader.upload(
            image_bytes, 
            resource_type="image",
            folder="buddy-generated"
        )
        print(f"[BACKEND] Cloudinary upload result: {result}")
        print(f"[BACKEND] Returning image URL to frontend: {result['secure_url']}")
        return {
            "url": result["secure_url"],
            "prompt": request.prompt,
            "status": "success"
        }
        
    except requests.exceptions.Timeout:
        print(f"[BACKEND] Timeout generating image for: {request.prompt}")
        raise HTTPException(
            status_code=408, 
            detail="Image generation timed out. Please try again."
        )
    except requests.exceptions.RequestException as e:
        print(f"[BACKEND] Error calling Hugging Face Space: {e}")
        raise HTTPException(
            status_code=503, 
            detail=f"Hugging Face Space is not available: {str(e)}"
        )
    except Exception as e:
        print(f"[BACKEND] Image generation error: {e}")
        raise HTTPException(
            status_code=500, 
            detail=f"Image generation failed: {str(e)}"
        )

@app.post("/chat")
async def chat_with_ollama(request: ChatRequest):
    """Chat endpoint that communicates with local Ollama instance"""
    try:
        import requests
        import json
        
        # Ollama API endpoint
        ollama_url = "http://localhost:11434/api/generate"
        
        # Prepare the request for Ollama
        ollama_request = {
            "model": "mistral",  # Using the mistral model
            "prompt": request.prompt,
            "stream": False
        }
        
        # Send request to Ollama
        response = requests.post(ollama_url, json=ollama_request, timeout=30)
        response.raise_for_status()
        
        # Parse Ollama response
        ollama_response = response.json()
        generated_text = ollama_response.get("response", "Sorry, I couldn't generate a response.")
        
        return {
            "response": generated_text,
            "status": "success"
        }
        
    except requests.exceptions.ConnectionError:
        raise HTTPException(
            status_code=503,
            detail="Ollama service is not available. Please make sure Ollama is running with 'ollama run mistral'"
        )
    except Exception as e:
        print(f"Chat error: {e}")
        raise HTTPException(status_code=500, detail=f"Chat failed: {str(e)}")

@app.get("/test-image")
async def test_image():
    return {
        "url": "https://res.cloudinary.com/dlix7tsir/image/upload/v1751526195/buddy-generated/mroqcbx2ffp2ro389fga.png",
        "prompt": "test image",
        "status": "success"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860) 