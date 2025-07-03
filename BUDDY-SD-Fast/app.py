# BUDDY-SD-Fast: CPU Image Generator
# FastAPI app for image generation with CPU optimization

from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel
from diffusers import StableDiffusionPipeline
import torch
from PIL import Image
import io
import base64
import json

app = FastAPI(title="BUDDY-SD-Fast API", version="1.0.0")

# Load model once at startup with CPU optimization
def load_model():
    """Load Stable Diffusion model with CPU optimization"""
    try:
        pipe = StableDiffusionPipeline.from_pretrained(
            "CompVis/stable-diffusion-v1-4",
            torch_dtype=torch.float32,  # Use float32 for CPU compatibility
            use_safetensors=True,
            safety_checker=None,  # Disable safety checker for speed
            low_cpu_mem_usage=True  # Optimize for CPU memory usage
        )
        pipe = pipe.to("cpu")  # Explicitly move to CPU
        print("✅ Model loaded successfully with CPU optimization!")
        return pipe
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        return None

# Load the model
pipe = load_model()

class PromptRequest(BaseModel):
    prompt: str

@app.get("/")
async def root():
    return {
        "message": "BUDDY-SD-Fast API",
        "status": "running",
        "hardware": "CPU",
        "model": "Stable Diffusion v1.4",
        "endpoints": {
            "generate": "/generate (POST)",
            "health": "/health (GET)"
        }
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "model_loaded": pipe is not None,
        "hardware": "CPU"
    }

@app.post("/generate")
async def generate_image(request: PromptRequest):
    """Generate image with CPU-optimized settings - API endpoint"""
    if pipe is None:
        raise HTTPException(
            status_code=500,
            detail="Model not loaded. Please check the logs."
        )
    
    try:
        print(f"Generating image for prompt: {request.prompt}")
        
        # Generate image with CPU-optimized parameters
        image = pipe(
            request.prompt,
            num_inference_steps=20,  # Reduced steps for speed
            guidance_scale=7.5,
            height=512,
            width=512
        ).images[0]
        
        # Convert to bytes for API response
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='PNG')
        img_byte_arr = img_byte_arr.getvalue()
        
        print(f"✅ Image generated successfully for: {request.prompt}")
        return Response(content=img_byte_arr, media_type="image/png")
        
    except Exception as e:
        print(f"❌ Generation error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Image generation failed: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860) 