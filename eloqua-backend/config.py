import os
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

# Gemini configuration
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "replace_me_here")

# Body Service configuration
BODY_SERVICE_URL = os.getenv("BODY_SERVICE_URL", "http://127.0.0.1:8001/analyze-body")

# JWT authentication configuration
JWT_SECRET = os.getenv("JWT_SECRET", "replace_me_here")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRE_HOURS = int(os.getenv("JWT_EXPIRE_HOURS", "72"))
