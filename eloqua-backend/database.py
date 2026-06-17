import os
import datetime
from dotenv import load_dotenv
from peewee import (
    Model,
    CharField, FloatField, DateTimeField,
    TextField, BlobField, IntegerField,
    ForeignKeyField, CompositeKey
)

load_dotenv()

# ── Database selection ─────────────────────────────────────────────────────────
# If DATABASE_URL is set (e.g. on Render/Supabase), use PostgreSQL.
# Otherwise fall back to local SQLite for development.

DATABASE_URL = os.getenv("DATABASE_URL", "")

if DATABASE_URL:
    from playhouse.db_url import connect
    # autoconnect=False prevents peewee from eagerly connecting at import time.
    # The connection is established lazily on first query, which avoids crashing
    # the entire app at startup if the database is temporarily unreachable.
    db = connect(DATABASE_URL, autorollback=True, autoconnect=False)
else:
    from peewee import SqliteDatabase
    db = SqliteDatabase("eloqua.db")


# ── Base model ─────────────────────────────────────────────────────────────────
class BaseModel(Model):
    class Meta:
        database = db


# ── User ───────────────────────────────────────────────────────────────────────
class User(BaseModel):
    name            = CharField()
    email           = CharField(unique=True)
    password_hash   = CharField()
    profile_photo   = BlobField(null=True)
    reset_token     = CharField(null=True)
    reset_token_exp = DateTimeField(null=True)
    created_at      = DateTimeField(default=datetime.datetime.now)

    class Meta:
        table_name = "users"


# ── Session ────────────────────────────────────────────────────────────────────
class Session(BaseModel):
    user_id             = CharField(default="anonymous")
    timestamp           = DateTimeField(default=datetime.datetime.now)
    topic               = TextField(default="")
    transcript          = TextField(default="")
    filler_count        = FloatField(default=0)
    words_per_minute    = FloatField(default=0)
    grammar_score       = FloatField(default=0)
    overall_score       = FloatField(default=0)
    practice_mode       = CharField(default="spontaneous")
    eye_contact_score   = FloatField(default=0)
    posture_score       = FloatField(default=0)
    gesture_score       = FloatField(default=0)
    body_language_score = FloatField(default=0)
    relevance_score     = FloatField(default=0)

    class Meta:
        table_name = "sessions"


# ── FeedPostModel ──────────────────────────────────────────────────────────────
class FeedPostModel(BaseModel):
    id          = CharField(primary_key=True)   # UUID string
    user        = ForeignKeyField(User, backref="feed_posts")
    overall     = IntegerField()
    clarity     = IntegerField()
    pacing      = IntegerField()
    grammar     = IntegerField()
    confidence  = IntegerField()
    topic_title = TextField()
    duration    = CharField()
    persona     = CharField()
    likes       = IntegerField(default=0)
    posted_at   = DateTimeField(default=datetime.datetime.now)

    class Meta:
        table_name = "feed_posts"


# ── FeedCommentModel ───────────────────────────────────────────────────────────
class FeedCommentModel(BaseModel):
    id        = CharField(primary_key=True)     # UUID string
    post      = ForeignKeyField(FeedPostModel, backref="comments")
    user      = ForeignKeyField(User, backref="feed_comments")
    text      = TextField()
    posted_at = DateTimeField(default=datetime.datetime.now)

    class Meta:
        table_name = "feed_comments"


# ── PostLike ───────────────────────────────────────────────────────────────────
class PostLike(BaseModel):
    post = ForeignKeyField(FeedPostModel, backref="liked_by")
    user = ForeignKeyField(User, backref="liked_posts")

    class Meta:
        table_name  = "post_likes"
        primary_key = CompositeKey("post", "user")  # one like per user per post


# ── AnalysisJob ────────────────────────────────────────────────────────────────
class AnalysisJob(BaseModel):
    job_id      = CharField(primary_key=True)  # UUID string
    user_id     = CharField()
    status      = CharField(default="pending")  # pending, completed, failed
    result_json = TextField(null=True)
    error       = TextField(null=True)
    created_at  = DateTimeField(default=datetime.datetime.now)

    class Meta:
        table_name = "analysis_jobs"


# ── Init ───────────────────────────────────────────────────────────────────────
def init_db():
    try:
        db.connect(reuse_if_open=True)
        db.create_tables(
            [User, Session, FeedPostModel, FeedCommentModel, PostLike, AnalysisJob],
            safe=True   # safe=True means it won't error if tables already exist
        )
        print("[DB] Connected successfully and tables verified.")
    except Exception as e:
        print(f"[DB] WARNING: Could not connect to database at startup: {e}")
        print("[DB] App will still start — DB operations will fail until the database is reachable.")
    finally:
        # With autoconnect=False we manage connections manually.
        # Close the init connection so the pool is clean before requests come in.
        if not db.is_closed():
            db.close()