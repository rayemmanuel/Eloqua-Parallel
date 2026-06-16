import fitz
from docx import Document
from pptx import Presentation
from google import genai
from google.genai import types
from config import GEMINI_API_KEY
import json, re

client = genai.Client(api_key=GEMINI_API_KEY)

def extract_text(file_path: str, file_type: str) -> str:
    if file_type == "pdf":
        doc = fitz.open(file_path)
        return "\n".join([page.get_text() for page in doc])
    elif file_type == "docx":
        doc = Document(file_path)
        return "\n".join([p.text for p in doc.paragraphs if p.text.strip()])
    elif file_type == "pptx":
        prs = Presentation(file_path)
        text = []
        for slide in prs.slides:
            for shape in slide.shapes:
                if hasattr(shape, "text") and shape.text.strip():
                    text.append(shape.text)
        return "\n".join(text)
    return ""

def generate_talking_points(text: str) -> dict:
    prompt = f"""
You are an academic speech coach. Based on the following document content,
generate a structured list of 5 to 7 key talking points the student should
be able to explain verbally during a presentation.

Each talking point should be:
- Clear and concise (one sentence)
- Actionable (something the student can actually say out loud)
- Based strictly on the document content

Document content:
{text[:3000]}

Respond in this exact JSON format with no extra text:
{{
  "title": "brief title of the document topic",
  "talking_points": [
    "talking point 1",
    "talking point 2",
    "talking point 3"
  ]
}}
"""
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt
    )
    cleaned = re.sub(r"```json|```", "", response.text).strip()
    return json.loads(cleaned)

def check_relevance(topic: str, transcript: str) -> dict:
    """
    Checks if the student's speech is relevant to the given topic.
    Used for Spontaneous Mode sessions.
    """
    if not topic.strip() or not transcript.strip():
        return {
            "relevance_score": 0,
            "relevance_feedback": "No topic or transcript available to evaluate."
        }

    prompt = f"""
You are an academic speech coach evaluating a student's impromptu speech.

The student was given this topic to speak about:
"{topic}"

This is the transcript of what the student actually said:
"{transcript}"

Evaluate how relevant and on-topic the student's speech was.
Consider:
- Did they actually address the topic?
- Did they stay on topic throughout?
- Did they provide a clear introduction, definition, example, or analysis related to the topic?

Respond in this exact JSON format with no extra text:
{{
  "relevance_score": a number between 0 and 100 representing how on-topic the speech was,
  "relevance_feedback": "two sentences max — first say what they did well topic-wise, then what they missed or went off-topic about"
}}
"""
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt
    )
    cleaned = re.sub(r"```json|```", "", response.text).strip()
    return json.loads(cleaned)

def check_coverage(talking_points: list, transcript: str) -> dict:
    """
    Compares the user's speech transcript against the generated
    talking points and returns a per-point coverage report.
    Only called during Preparation Mode sessions.
    """
    if not talking_points or not transcript.strip():
        return {
            "coverage_report": [],
            "coverage_score": 0,
            "coverage_feedback": "No talking points or transcript available to evaluate."
        }

    prompt = f"""
You are an academic speech coach evaluating a student's presentation.

The student was given these talking points to cover:
{json.dumps(talking_points, indent=2)}

This is the transcript of what the student actually said:
"{transcript}"

For each talking point, determine if the student covered it in their speech.
Be fair — the student does not need to use exact words, just convey the idea clearly.

Respond in this exact JSON format with no extra text:
{{
  "coverage_report": [
    {{
      "talking_point": "the talking point text",
      "covered": true or false,
      "confidence": "high, medium, or low",
      "feedback": "one sentence explaining why it was or was not covered"
    }}
  ],
  "coverage_score": percentage of talking points covered as a number between 0 and 100,
  "coverage_feedback": "one overall sentence summarizing the student's content coverage"
}}
"""
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt
    )
    cleaned = re.sub(r"```json|```", "", response.text).strip()
    return json.loads(cleaned)

def chat_with_coach(history: list, system_prompt: str) -> str:
    contents = []
    for msg in history:
        role = "user" if msg["role"] == "user" else "model"
        contents.append(types.Content(
            role=role,
            parts=[types.Part(text=msg["content"])]
        ))
    
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=contents,
        config=types.GenerateContentConfig(
            system_instruction=system_prompt,
            max_output_tokens=500,
        )
    )
    return response.text.strip()