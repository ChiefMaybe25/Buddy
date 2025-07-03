# Hugging Face Space FastAPI App
# This file should be uploaded to your Hugging Face Space

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from diffusers import StableDiffusionPipeline
import torch
from PIL import Image
import io

app = FastAPI(title="BUDDY-SD CPU Generator", version="1.0.0")

# Load model once at startup
def load_model():
    """Load Stable Diffusion model"""
    try:
        pipe = StableDiffusionPipeline.from_pretrained(
            "CompVis/stable-diffusion-v1-4",
            torch_dtype=torch.float32,  # Use float32 for CPU
            use_safetensors=True,
            safety_checker=None  # Disable safety checker for speed
        )
        print("✅ Model loaded successfully!")
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
        "message": "BUDDY-SD CPU Generator",
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
    """Generate image and return as raw bytes"""
    if pipe is None:
        raise HTTPException(
            status_code=500,
            detail="Model not loaded. Please check the logs."
        )
    
    try:
        print(f"Generating image for prompt: {request.prompt}")
        
        # Generate image
        image = pipe(
            request.prompt,
            num_inference_steps=50,  # Standard steps for CPU
            guidance_scale=7.5,
            height=512,
            width=512
        ).images[0]
        
        # Convert to bytes for API response
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='PNG')
        img_byte_arr = img_byte_arr.getvalue()
        
        print(f"✅ Image generated successfully for: {request.prompt}")
        
        # Return raw image bytes (not JSON)
        from fastapi.responses import Response
        return Response(
            content=img_byte_arr,
            media_type="image/png"
        )
        
    except Exception as e:
        print(f"❌ Generation error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Image generation failed: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860) 