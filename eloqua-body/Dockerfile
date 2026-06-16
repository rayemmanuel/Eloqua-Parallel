FROM python:3.10-slim

# Install system dependencies needed for OpenCV and MediaPipe
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application files
COPY . .

# Create uploads directory and set permissions for Hugging Face Spaces (user 1000)
RUN mkdir -p uploads_body && chmod 777 uploads_body

# Hugging Face Spaces requires exposing port 7860
EXPOSE 7860

# Run uvicorn on port 7860
CMD ["uvicorn", "main_body:app", "--host", "0.0.0.0", "--port", "7860"]
