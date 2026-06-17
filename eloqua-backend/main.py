from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Depends, BackgroundTasks
from document_processor import extract_text, generate_talking_points, check_coverage, check_relevance
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
import shutil, os, httpx, json, secrets, datetime, uuid as _uuid
import asyncio, time
from jose import jwt, JWTError

import bcrypt
import config

from database import init_db, Session, User, FeedPostModel, FeedCommentModel, PostLike, AnalysisJob
from analyzer import full_analysis
from prompts import get_prompt, get_all_categories
from document_processor import extract_text, generate_talking_points, check_coverage, chat_with_coach

app = FastAPI(title="Eloqua Backend API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

init_db()

security = HTTPBearer()


# ── Auth helpers ───────────────────────────────────────────────────────────────

def hash_password(plain: str) -> str:
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()

def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode(), hashed.encode())

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=config.JWT_EXPIRE_HOURS)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, config.JWT_SECRET, algorithm=config.JWT_ALGORITHM)
    return encoded_jwt

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> User:
    """Decodes JWT and retrieves the corresponding user."""
    token = credentials.credentials
    try:
        payload = jwt.decode(token, config.JWT_SECRET, algorithms=[config.JWT_ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token: missing subject.")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token.")
    
    user = User.get_or_none(User.id == user_id)
    if not user:
        raise HTTPException(status_code=401, detail="User not found.")
    return user


# ── Pydantic schemas ───────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str

class LoginRequest(BaseModel):
    email: str
    password: str

class ForgotPasswordRequest(BaseModel):
    email: str

class ChatRequest(BaseModel):
    history: list
    system_prompt: str

class CreatePostRequest(BaseModel):
    overall:     int
    clarity:     int
    pacing:      int
    grammar:     int
    confidence:  int
    topic_title: str
    duration:    str
    persona:     str

class CreateCommentRequest(BaseModel):
    text: str


# ── Auth endpoints ─────────────────────────────────────────────────────────────

@app.post("/auth/register", status_code=201)
def register(req: RegisterRequest):
    if not req.name.strip():
        raise HTTPException(status_code=422, detail="Name is required.")
    if not req.email.strip() or "@" not in req.email:
        raise HTTPException(status_code=422, detail="A valid email is required.")
    if len(req.password) < 6:
        raise HTTPException(status_code=422, detail="Password must be at least 6 characters.")
    if User.get_or_none(User.email == req.email.lower().strip()):
        raise HTTPException(status_code=409, detail="An account with this email already exists.")

    user = User.create(
        name          = req.name.strip(),
        email         = req.email.lower().strip(),
        password_hash = hash_password(req.password),
    )
    return {"message": "Account created successfully.", "user_id": user.id}


@app.post("/auth/login")
def login(req: LoginRequest):
    user = User.get_or_none(User.email == req.email.lower().strip())
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Incorrect email or password.")

    token = create_access_token(data={"sub": str(user.id)})
    return {
        "token":   token,
        "user_id": user.id,
        "name":    user.name,
        "email":   user.email,
    }


@app.post("/auth/forgot-password")
def forgot_password(req: ForgotPasswordRequest):
    user = User.get_or_none(User.email == req.email.lower().strip())

    if not user:
        return {"message": "If that email exists, a reset link has been sent."}

    token = secrets.token_urlsafe(32)
    user.reset_token     = token
    user.reset_token_exp = datetime.datetime.now() + datetime.timedelta(hours=1)
    user.save()

    return {
        "message":     "If that email exists, a reset link has been sent.",
        "debug_token": token    # Remove this in production
    }


@app.post("/auth/reset-password")
def reset_password(token: str, new_password: str):
    if len(new_password) < 6:
        raise HTTPException(status_code=422, detail="Password must be at least 6 characters.")
    user = User.get_or_none(User.reset_token == token)
    if not user or user.reset_token_exp < datetime.datetime.now():
        raise HTTPException(status_code=400, detail="Reset token is invalid or has expired.")
    user.password_hash   = hash_password(new_password)
    user.reset_token     = None
    user.reset_token_exp = None
    user.save()
    return {"message": "Password reset successfully."}


# ── Profile endpoints ──────────────────────────────────────────────────────────

@app.get("/profile")
def get_profile(current_user: User = Depends(get_current_user)):
    return {
        "user_id":    current_user.id,
        "name":       current_user.name,
        "email":      current_user.email,
        "created_at": str(current_user.created_at),
    }


@app.patch("/profile")
def update_profile(name: str = Form(None), current_user: User = Depends(get_current_user)):
    if name:
        current_user.name = name.strip()
        current_user.save()
    return {"message": "Profile updated.", "name": current_user.name}


@app.post("/profile/photo")
async def upload_profile_photo(
    photo: UploadFile = File(...),
    current_user: User = Depends(get_current_user)
):
    if photo.content_type not in {"image/jpeg", "image/png", "image/webp"}:
        raise HTTPException(status_code=422, detail="Only JPEG, PNG, or WebP images are accepted.")
    data = await photo.read()
    if len(data) > 5 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="Photo must be under 5 MB.")
    current_user.profile_photo = data
    current_user.save()
    return {"message": "Profile photo updated."}


# ── General endpoints ──────────────────────────────────────────────────────────

@app.get("/")
def root():
    return {"message": "Eloqua API is running."}

@app.post("/chat")
def chat(req: ChatRequest):
    try:
        reply = chat_with_coach(req.history, req.system_prompt)
        return {"reply": reply}
    except Exception as e:
        return {"error": str(e)}

@app.get("/prompt")
def prompt(category: str = "academic", difficulty: str = "easy"):
    return get_prompt(category, difficulty)

@app.get("/categories")
def categories():
    return {"categories": get_all_categories()}

@app.post("/upload-document")
async def upload_document(file: UploadFile = File(...)):
    # Ensure uploads folder exists
    os.makedirs("uploads", exist_ok=True)
    
    ext = file.filename.split(".")[-1].lower()
    if ext not in ["pdf", "docx", "pptx"]:
        return {"error": "Only PDF, DOCX, and PPTX files are supported."}
    file_path = f"uploads/{file.filename}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    text = extract_text(file_path, ext)
    os.remove(file_path)
    if not text.strip():
        return {"error": "Could not extract text from the document."}
    return generate_talking_points(text)


# ── Analyze endpoint ───────────────────────────────────────────────────────────

BODY_SERVICE_URL = config.BODY_SERVICE_URL


async def _call_body_service(video_path: str, filename: str) -> dict:
    """
    Sends the video to the body language microservice and returns the result.
    This is a native coroutine so it can be awaited concurrently alongside
    other async tasks via asyncio.gather().
    """
    try:
        with open(video_path, "rb") as vf:
            async with httpx.AsyncClient(timeout=120.0) as client:
                response = await client.post(
                    BODY_SERVICE_URL,
                    files={"video": (filename, vf, "video/mp4")}
                )
        result = response.json()
        print("[BENCHMARK] Body service response received:", result)
        return result
    except Exception as e:
        return {"error": f"Body language service unavailable: {str(e)}", "body_language_score": 0}


async def _run_speech_analysis(audio_path: str, topic: str) -> dict:
    """
    Runs full_analysis() (a CPU-bound, blocking function) inside a thread
    pool executor so it does not block the asyncio event loop.
    """
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, full_analysis, audio_path, topic)


async def _run_full_analysis(
    job_id: str,
    video_path: str,
    audio_path: str,
    filename: str,
    topic: str,
    practice_mode: str,
    talking_points: str,
    user_id: str
):
    """
    Runs the full speech and body analysis in the background, updates the AnalysisJob
    table with the results, and cleans up temporary files.
    """
    try:
        # Extract audio using ffmpeg
        exit_code = os.system(f'ffmpeg -i "{video_path}" -ss 00:00:01 -q:a 0 -map a "{audio_path}" -y')
        if exit_code != 0 or not os.path.exists(audio_path):
            raise Exception("Failed to extract audio from video.")

        print(f"[BACKGROUND JOB {job_id}] Dispatching speech + body analysis concurrently...")
        t_concurrent = time.perf_counter()

        speech, body = await asyncio.gather(
            _run_speech_analysis(audio_path, topic),
            _call_body_service(video_path, filename)
        )

        print(f"[BACKGROUND JOB {job_id}] Concurrent speech + body completed in {time.perf_counter() - t_concurrent:.2f}s")

        if "error" in speech:
            raise Exception(speech["error"])

        # Coverage / relevance check
        coverage = None
        coverage_score = 0
        if talking_points.strip():
            try:
                points_list = json.loads(talking_points)
                coverage = check_coverage(points_list, speech["transcript"])
                coverage_score = coverage.get("coverage_score", 0)
            except Exception as e:
                coverage = {"coverage_report": [], "coverage_score": 0,
                            "coverage_feedback": f"Coverage check failed: {str(e)}"}

        relevance_score = 0
        relevance_feedback = ""
        if coverage:
            relevance_score = coverage_score
            relevance_feedback = coverage.get("coverage_feedback", "")
        else:
            try:
                relevance = check_relevance(topic, speech["transcript"])
                relevance_score = relevance.get("relevance_score", 0)
                relevance_feedback = relevance.get("relevance_feedback", "")
            except Exception:
                relevance_score = 0
                relevance_feedback = ""

        # Compute combined score
        body_score = body.get("body_language_score", 0)
        if coverage:
            coverage_weight = 0.15 if practice_mode == "preparation" else 0.10
            grammar_weight  = 0.25 if practice_mode == "preparation" else 0.27
            filler_weight   = 0.20 if practice_mode == "preparation" else 0.23
            pacing_weight   = 0.15 if practice_mode == "preparation" else 0.15
            body_weight     = 0.25

            combined_score = round(
                (speech["grammar_analysis"]["grammar_score"] * grammar_weight) +
                (max(0, 100 - speech["filler_analysis"]["total_fillers"] * 5) * filler_weight) +
                (100 if 110 <= speech["pacing_analysis"]["words_per_minute"] <= 160 else 60) * pacing_weight +
                (body_score * body_weight) +
                (coverage_score * coverage_weight), 1)
        else:
            combined_score = round(
                (speech["grammar_analysis"]["grammar_score"] * 0.25) +
                (max(0, 100 - speech["filler_analysis"]["total_fillers"] * 5) * 0.22) +
                (100 if 110 <= speech["pacing_analysis"]["words_per_minute"] <= 160 else 60) * 0.18 +
                (body_score * 0.25) +
                (relevance_score * 0.10), 1)

        # Create session record
        from database import db
        with db.connection_context():
            Session.create(
                user_id=str(user_id), topic=topic,
                transcript=speech["transcript"],
                filler_count=speech["filler_analysis"]["total_fillers"],
                words_per_minute=speech["pacing_analysis"]["words_per_minute"],
                grammar_score=speech["grammar_analysis"]["grammar_score"],
                overall_score=combined_score, practice_mode=practice_mode,
                eye_contact_score=body.get("eye_contact", {}).get("score", 0),
                posture_score=body.get("posture", {}).get("score", 0),
                gesture_score=body.get("gestures", {}).get("score", 0),
                body_language_score=body_score,
                relevance_score=relevance_score,
            )

        # Build final results dict
        result = {
            "speech_analysis": speech,
            "body_language_analysis": body,
            "combined_score": combined_score,
            "practice_mode": practice_mode,
            "relevance_score": relevance_score,
            "relevance_feedback": relevance_feedback,
        }

        if coverage:
            result["coverage_analysis"] = coverage

        # Update job database status
        with db.connection_context():
            job = AnalysisJob.get_or_none(AnalysisJob.job_id == job_id)
            if job:
                job.status = "completed"
                job.result_json = json.dumps(result)
                job.save()

    except Exception as e:
        print(f"[BACKGROUND JOB {job_id}] Failed: {str(e)}")
        from database import db
        with db.connection_context():
            job = AnalysisJob.get_or_none(AnalysisJob.job_id == job_id)
            if job:
                job.status = "failed"
                job.error = str(e)
                job.save()
    finally:
        # Cleanup temporary files
        if os.path.exists(audio_path):
            try:
                os.remove(audio_path)
            except Exception as ex:
                print(f"[BACKGROUND JOB {job_id}] Cleanup audio error: {ex}")
        if os.path.exists(video_path):
            try:
                os.remove(video_path)
            except Exception as ex:
                print(f"[BACKGROUND JOB {job_id}] Cleanup video error: {ex}")


@app.post("/analyze")
async def analyze(
    background_tasks: BackgroundTasks,
    video: UploadFile = File(...),
    topic: str = Form(default=""),
    practice_mode: str = Form(default="spontaneous"),
    talking_points: str = Form(default=""),
    current_user: User = Depends(get_current_user)
):
    # Ensure uploads folder exists
    os.makedirs("uploads", exist_ok=True)

    job_id = str(_uuid.uuid4())
    ext = video.filename.split(".")[-1].lower() if "." in video.filename else "mp4"
    video_filename = f"{job_id}.{ext}"
    video_path = f"uploads/{video_filename}"

    # Save video file immediately (fast operation)
    with open(video_path, "wb") as f:
        shutil.copyfileobj(video.file, f)

    audio_path = video_path.rsplit(".", 1)[0] + ".wav"

    # Save background job record to DB
    AnalysisJob.create(
        job_id=job_id,
        user_id=str(current_user.id),
        status="pending"
    )

    # Queue the background task
    background_tasks.add_task(
        _run_full_analysis,
        job_id,
        video_path,
        audio_path,
        video.filename,
        topic,
        practice_mode,
        talking_points,
        str(current_user.id)
    )

    return {"job_id": job_id, "status": "pending"}


@app.get("/analyze/status/{job_id}")
def get_analysis_status(job_id: str, current_user: User = Depends(get_current_user)):
    job = AnalysisJob.get_or_none(AnalysisJob.job_id == job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Analysis job not found.")

    if job.user_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to access this job's status.")

    if job.status == "completed":
        if job.result_json:
            return json.loads(job.result_json)
        else:
            raise HTTPException(status_code=500, detail="Job complete but no results found.")
    elif job.status == "failed":
        return {"job_id": job.job_id, "status": "failed", "error": job.error or "Unknown error."}
    else:
        return {"job_id": job.job_id, "status": "pending"}



# ── Sessions & leaderboard ─────────────────────────────────────────────────────

@app.get("/sessions")
def get_sessions(current_user: User = Depends(get_current_user)):
    sessions = Session.select().where(Session.user_id == str(current_user.id))
    return [{
        "timestamp": str(s.timestamp), 
        "topic": s.topic,
        "practice_mode": s.practice_mode, 
        "combined_score": s.overall_score,
        "words_per_minute": s.words_per_minute, 
        "grammar_score": s.grammar_score,
        "filler_count": s.filler_count, 
        "eye_contact_score": s.eye_contact_score,
        "posture_score": s.posture_score, 
        "gesture_score": s.gesture_score,
        "body_language_score": s.body_language_score,
        "relevance_score": s.relevance_score,
        "transcript": s.transcript,  # <-- Added Transcript mapping
    } for s in sessions]


@app.get("/leaderboard")
def get_leaderboard(current_user: User = Depends(get_current_user)):
    users = User.select()
    board = []
    for u in users:
        sessions = Session.select().where(Session.user_id == u.id)
        count = sessions.count()
        if count == 0:
            continue
        avg_score = sum(s.overall_score for s in sessions) / count
        avg_fillers = sum(s.filler_count for s in sessions) / count
        jar_level = max(0, min(100, round(100 - (avg_fillers * 8))))
        board.append({
            "user_id":    str(u.id),
            "name":       u.name,
            "avg_score":  round(avg_score, 1),
            "jar_level":  jar_level,
            "sessions":   count,
            "is_me":      u.id == current_user.id,
        })
    board.sort(key=lambda x: x["avg_score"], reverse=True)
    return board


# ── Feed helper ────────────────────────────────────────────────────────────────

def _serialise_post(post: FeedPostModel, current_user_id: int) -> dict:
    comments = (
        FeedCommentModel
        .select()
        .where(FeedCommentModel.post == post)
        .order_by(FeedCommentModel.posted_at)
    )
    return {
        "id":         str(post.id),
        "userName":   post.user.name,
        "overall":    post.overall,
        "clarity":    post.clarity,
        "pacing":     post.pacing,
        "grammar":    post.grammar,
        "confidence": post.confidence,
        "topicTitle": post.topic_title,
        "duration":   post.duration,
        "persona":    post.persona,
        "postedAt":   post.posted_at.isoformat(),
        "likes":      post.likes,
        "likedByMe":  PostLike.get_or_none(
                          PostLike.post == post,
                          PostLike.user == current_user_id
                      ) is not None,
        "comments": [
            {
                "id":       str(c.id),
                "userName": c.user.name,
                "text":     c.text,
                "postedAt": c.posted_at.isoformat(),
            }
            for c in comments
        ],
    }


# ── Feed endpoints ─────────────────────────────────────────────────────────────

@app.get("/feed")
def get_feed(current_user: User = Depends(get_current_user)):
    """Return all community posts, newest first."""
    posts = (
        FeedPostModel
        .select()
        .order_by(FeedPostModel.posted_at.desc())
    )
    return [_serialise_post(p, current_user.id) for p in posts]


@app.post("/feed", status_code=201)
def create_post(
    req: CreatePostRequest,
    current_user: User = Depends(get_current_user),
):
    """Publish a session result to the shared community feed."""
    post = FeedPostModel.create(
        id=          str(_uuid.uuid4()),
        user=        current_user,
        overall=     req.overall,
        clarity=     req.clarity,
        pacing=      req.pacing,
        grammar=     req.grammar,
        confidence=  req.confidence,
        topic_title= req.topic_title,
        duration=    req.duration,
        persona=     req.persona,
    )
    return _serialise_post(post, current_user.id)


@app.post("/feed/{post_id}/like")
def toggle_like(
    post_id: str,
    current_user: User = Depends(get_current_user),
):
    """Toggle like on a post. Returns updated like count."""
    post = FeedPostModel.get_or_none(FeedPostModel.id == post_id)
    if not post:
        raise HTTPException(status_code=404, detail="Post not found.")

    existing = PostLike.get_or_none(
        PostLike.post == post, PostLike.user == current_user
    )
    if existing:
        existing.delete_instance()
        post.likes = max(0, post.likes - 1)
        liked = False
    else:
        PostLike.create(post=post, user=current_user)
        post.likes += 1
        liked = True

    post.save()
    return {"likes": post.likes, "likedByMe": liked}


@app.post("/feed/{post_id}/comments", status_code=201)
def add_comment(
    post_id: str,
    req: CreateCommentRequest,
    current_user: User = Depends(get_current_user),
):
    """Add a comment to a post."""
    if not req.text.strip():
        raise HTTPException(status_code=422, detail="Comment text is required.")

    post = FeedPostModel.get_or_none(FeedPostModel.id == post_id)
    if not post:
        raise HTTPException(status_code=404, detail="Post not found.")

    comment = FeedCommentModel.create(
        id=   str(_uuid.uuid4()),
        post= post,
        user= current_user,
        text= req.text.strip(),
    )
    return {
        "id":       str(comment.id),
        "userName": current_user.name,
        "text":     comment.text,
        "postedAt": comment.posted_at.isoformat(),
    }


@app.delete("/feed/{post_id}/comments/{comment_id}", status_code=204)
def delete_comment(
    post_id:    str,
    comment_id: str,
    current_user: User = Depends(get_current_user),
):
    """Delete own comment."""
    comment = FeedCommentModel.get_or_none(
        FeedCommentModel.id == comment_id,
        FeedCommentModel.post == post_id,
    )
    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found.")
    if comment.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Cannot delete another user's comment.")
    comment.delete_instance()
    
@app.delete("/feed/{post_id}", status_code=204)
def delete_post(
    post_id: str,
    current_user: User = Depends(get_current_user),
):
    post = FeedPostModel.get_or_none(FeedPostModel.id == post_id)
    if not post:
        raise HTTPException(status_code=404, detail="Post not found.")
    if post.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Cannot delete another user's post.")
    post.delete_instance(recursive=True)  # recursive=True also deletes related comments/likes

@app.get("/notifications")
def get_notifications(current_user: User = Depends(get_current_user)):
    """Get likes and comments on the current user's posts."""
    my_posts = FeedPostModel.select().where(FeedPostModel.user == current_user)
    
    notifications = []
    for post in my_posts:
        # Get comments on my posts by other people
        comments = FeedCommentModel.select().where(
            (FeedCommentModel.post == post) & (FeedCommentModel.user != current_user)
        )
        for c in comments:
            notifications.append({
                "id": f"comment_{c.id}",
                "type": "comment",
                "user_name": c.user.name,
                "post_title": post.topic_title,
                "text": c.text,
                "timestamp": c.posted_at.isoformat()
            })
            
        # Get likes on my posts by other people
        likes = PostLike.select().where(
            (PostLike.post == post) & (PostLike.user != current_user)
        )
        for l in likes:
            # Use a timestamp if your PostLike model has one, otherwise fallback to the post's creation time
            ts = getattr(l, 'created_at', post.posted_at)
            notifications.append({
                "id": f"like_{post.id}_{l.user.id}", # <--- Fixed!
                "type": "like",
                "user_name": l.user.name,
                "post_title": post.topic_title,
                "timestamp": ts.isoformat() if hasattr(ts, 'isoformat') else str(ts)
            })
            
    # Sort newest first
    notifications.sort(key=lambda x: x["timestamp"], reverse=True)
    return notifications