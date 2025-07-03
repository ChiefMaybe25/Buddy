from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import sys
from pathlib import Path

# Set up environment variables for Hugging Face Spaces
os.environ["TRANSFORMERS_CACHE"] = "/tmp/transformers_cache"
os.environ["HF_HOME"] = "/tmp/hf_home"
os.environ["HF_DATASETS_CACHE"] = "/tmp/datasets_cache"

# Create cache directories
for cache_dir in ["/tmp/transformers_cache", "/tmp/hf_home", "/tmp/datasets_cache"]:
    Path(cache_dir).mkdir(parents=True, exist_ok=True)

# Import ML libraries after setting up environment
cloudinary_available = False
try:
    from diffusers import StableDiffusionPipeline
    import torch
    from io import BytesIO
    from PIL import Image
    import cloudinary
    import cloudinary.uploader
    cloudinary_available = True
except ImportError as e:
    print(f"Import error: {e}")
    print("Some ML libraries may not be available in this environment")
    StableDiffusionPipeline = None
    torch = None

app = FastAPI(title="BUDDY Image Generation API", version="1.0.0")

# Load the pipeline with better error handling
pipe = None
try:
    if torch is not None and StableDiffusionPipeline is not None:
        print("Loading Stable Diffusion pipeline...")
        pipe = StableDiffusionPipeline.from_pretrained(
            "CompVis/stable-diffusion-v1-4",
            torch_dtype=torch.float32,  # Use float32 for CPU compatibility
            low_cpu_mem_usage=False,    # Disable low memory usage if accelerate not available
            cache_dir="/tmp/transformers_cache"
        )
        pipe = pipe.to("cpu")
        print("Pipeline loaded successfully!")
    else:
        print("ML libraries not available - running in demo mode")
except Exception as e:
    print(f"Error loading pipeline: {e}")
    pipe = None

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
        "pipeline_loaded": pipe is not None,
        "endpoints": {
            "generate": "/generate (POST)",
            "health": "/health (GET)"
        }
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "pipeline_loaded": pipe is not None,
        "cloudinary_configured": bool(os.getenv("CLOUDINARY_CLOUD_NAME"))
    }

@app.post("/generate")
async def generate_image(request: PromptRequest):
    if pipe is None:
        raise HTTPException(
            status_code=503, 
            detail="Image generation service is not available. Pipeline failed to load."
        )
    
    if not all([os.getenv("CLOUDINARY_CLOUD_NAME"), 
                os.getenv("CLOUDINARY_API_KEY"), 
                os.getenv("CLOUDINARY_API_SECRET")]):
        raise HTTPException(
            status_code=500, 
            detail="Cloudinary configuration missing. Please set CLOUDINARY_* environment variables."
        )
    
    try:
        print(f"Generating image for prompt: {request.prompt}")
        image = pipe(request.prompt).images[0]
        buffer = BytesIO()
        image.save(buffer, format="PNG")
        buffer.seek(0)
        
        result = cloudinary.uploader.upload(
            buffer, 
            resource_type="image",
            folder="buddy-generated"
        )
        
        return {
            "url": result["secure_url"],
            "prompt": request.prompt,
            "status": "success"
        }
    except Exception as e:
        print(f"Image generation error: {e}")
        raise HTTPException(status_code=500, detail=f"Image generation failed: {str(e)}")

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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860) 