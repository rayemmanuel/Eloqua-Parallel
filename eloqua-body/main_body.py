import multiprocessing
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import shutil, os
from body_language import analyze_video

# Required on Windows when using ProcessPoolExecutor / multiprocessing.
# Prevents recursive spawning of child processes when the module is
# imported by a subprocess spawned from the pool.
multiprocessing.freeze_support()

app = FastAPI(title="Eloqua Body Language Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.get("/")
def root():
    return {"message": "Eloqua Body Language Service is running."}

@app.post("/analyze-body")
async def analyze_body(video: UploadFile = File(...)):
    video_path = f"uploads_body/{video.filename}"
    with open(video_path, "wb") as f:
        shutil.copyfileobj(video.file, f)

    result = analyze_video(video_path)
    os.remove(video_path)
    return result