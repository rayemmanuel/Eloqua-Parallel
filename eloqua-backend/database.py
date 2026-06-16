from peewee import (
    SqliteDatabase, Model,
    CharField, FloatField, DateTimeField,
    TextField, BlobField, IntegerField,
    ForeignKeyField, CompositeKey
)
import datetime

db = SqliteDatabase("eloqua.db")


# ── User ───────────────────────────────────────────────────────────────────────
class User(Model):
    name            = CharField()
    email           = CharField(unique=True)
    password_hash   = CharField()
    profile_photo   = BlobField(null=True)
    reset_token     = CharField(null=True)
    reset_token_exp = DateTimeField(null=True)
    created_at      = DateTimeField(default=datetime.datetime.now)

    class Meta:
        database   = db
        table_name = "users"


# ── Session ────────────────────────────────────────────────────────────────────
class Session(Model):
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
        database   = db
        table_name = "sessions"


# ── FeedPostModel ──────────────────────────────────────────────────────────────
class FeedPostModel(Model):
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
        database   = db
        table_name = "feed_posts"


# ── FeedCommentModel ───────────────────────────────────────────────────────────
class FeedCommentModel(Model):
    id        = CharField(primary_key=True)     # UUID string
    post      = ForeignKeyField(FeedPostModel, backref="comments")
    user      = ForeignKeyField(User, backref="feed_comments")
    text      = TextField()
    posted_at = DateTimeField(default=datetime.datetime.now)

    class Meta:
        database   = db
        table_name = "feed_comments"


# ── PostLike ───────────────────────────────────────────────────────────────────
class PostLike(Model):
    post = ForeignKeyField(FeedPostModel, backref="liked_by")
    user = ForeignKeyField(User, backref="liked_posts")

    class Meta:
        database    = db
        table_name  = "post_likes"
        primary_key = CompositeKey("post", "user")  # one like per user per post


# ── AnalysisJob ────────────────────────────────────────────────────────────────
class AnalysisJob(Model):
    job_id      = CharField(primary_key=True)  # UUID string
    user_id     = CharField()
    status      = CharField(default="pending")  # pending, completed, failed
    result_json = TextField(null=True)
    error       = TextField(null=True)
    created_at  = DateTimeField(default=datetime.datetime.now)

    class Meta:
        database   = db
        table_name = "analysis_jobs"


# ── Init ───────────────────────────────────────────────────────────────────────
def init_db():
    db.connect(reuse_if_open=True)
    db.create_tables(
        [User, Session, FeedPostModel, FeedCommentModel, PostLike, AnalysisJob],
        safe=True   # safe=True means it won't error if tables already exist
    )