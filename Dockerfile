FROM python:3.10-slim

# Set environment variables for Hugging Face cache directories
ENV TRANSFORMERS_CACHE=/tmp/transformers_cache
ENV HF_HOME=/tmp/hf_home
ENV HF_DATASETS_CACHE=/tmp/datasets_cache
ENV PYTHONPATH=/app

# Create cache directories with proper permissions
RUN mkdir -p /tmp/transformers_cache /tmp/hf_home /tmp/datasets_cache && \
    chmod -R 777 /tmp/transformers_cache && \
    chmod -R 777 /tmp/hf_home && \
    chmod -R 777 /tmp/datasets_cache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies with specific NumPy version first
RUN pip install --no-cache-dir numpy==1.24.3
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Expose port
EXPOSE 7860

# Run the application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7860"] 