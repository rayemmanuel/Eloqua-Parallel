import whisper
import language_tool_python
import re
import subprocess
import time
from concurrent.futures import ThreadPoolExecutor

# Load Whisper model once at startup
model = whisper.load_model("base")
tool = language_tool_python.LanguageTool("en-US")

FILLER_WORDS = ["uh", "um", "like", "you know", "basically",
                "literally", "actually", "so", "right"]

def transcribe(audio_path: str) -> dict:
    result = model.transcribe(audio_path, language="en")
    segments = result.get("segments", [])
    duration = segments[-1]["end"] if segments else 1.0
    return {
        "text": result["text"].strip(),
        "duration": duration
    }

def detect_fillers(transcript: str) -> dict:
    """
    Scans the transcript for filler words and returns
    a count per word and a total filler count.
    """
    transcript_lower = transcript.lower()
    counts = {}
    total = 0
    for word in FILLER_WORDS:
        count = len(re.findall(rf"\b{word}\b", transcript_lower))
        if count > 0:
            counts[word] = count
            total += count
    return {"filler_words": counts, "total_fillers": total}

def analyze_pacing(transcript: str, duration_seconds: float) -> dict:
    """
    Calculates words per minute and returns a pacing
    score with a feedback message.
    """
    word_count = len(transcript.split())
    duration_minutes = max(duration_seconds / 60, 0.01)
    wpm = round(word_count / duration_minutes, 1)

    if wpm < 110:
        feedback = "Too slow — try to speak a bit faster to maintain engagement."
    elif wpm > 160:
        feedback = "Too fast — slow down so your audience can follow along."
    else:
        feedback = "Good pacing — your speed is within the ideal range."

    return {"words_per_minute": wpm, "pacing_feedback": feedback}

def check_grammar(transcript: str) -> dict:
    """
    Runs the transcript through LanguageTool and returns
    a grammar score out of 100 with up to 5 suggestions.
    """
    matches = tool.check(transcript)
    error_count = len(matches)
    word_count = max(len(transcript.split()), 1)
    error_rate = error_count / word_count
    score = round(max(0, 100 - (error_rate * 300)), 1)
    suggestions = [
        {"message": m.message, "context": m.context}
        for m in matches[:5]
    ]
    return {
        "grammar_score": score,
        "error_count": error_count,
        "suggestions": suggestions
    }

def full_analysis(audio_path: str, topic: str = "") -> dict:
    """
    Runs all speech analyses on the extracted .wav file and returns a
    combined result with an overall score.

    PDC Optimization — Multithreading:
        After transcription (which must complete first), the three
        independent sub-analyses (filler detection, pacing, grammar)
        are submitted to a ThreadPoolExecutor and run concurrently.
        ThreadPoolExecutor is used (not ProcessPoolExecutor) because
        all three tasks share the single LanguageTool Java process,
        which cannot be safely forked into child processes.
    """
    # ── Step 1: Transcription (serial — everything depends on this) ──
    t_start = time.perf_counter()
    transcription = transcribe(audio_path)
    transcript = transcription["text"].strip()
    duration = transcription["duration"]
    print(f"[BENCHMARK] Transcription: {time.perf_counter() - t_start:.2f}s")

    # ── Silence / short speech checks ────────────────────────────────
    if not transcript:
        return {"error": "No speech detected. Please ensure your microphone is working and speak clearly."}

    word_count = len(transcript.split())
    if word_count < 15:
        return {"error": f"Session too short ({word_count} words). Please speak at least 15 words for an accurate analysis."}

    # ── Step 2: Parallel sub-analyses (multithreading) ───────────────
    # detect_fillers, analyze_pacing, and check_grammar are all
    # independent of each other — they only need the transcript string.
    # We submit all three at once and collect results when they finish.
    t_parallel = time.perf_counter()
    with ThreadPoolExecutor(max_workers=3) as executor:
        future_fillers = executor.submit(detect_fillers, transcript)
        future_pacing  = executor.submit(analyze_pacing, transcript, duration)
        future_grammar = executor.submit(check_grammar, transcript)

        fillers = future_fillers.result()
        pacing  = future_pacing.result()
        grammar = future_grammar.result()
    print(f"[BENCHMARK] Parallel sub-analyses (filler + pacing + grammar): {time.perf_counter() - t_parallel:.2f}s")
    print(f"[BENCHMARK] full_analysis total: {time.perf_counter() - t_start:.2f}s")

    # ── Step 3: Compute overall score ───────────────────────────────
    # 40% grammar, 30% filler words, 30% pacing
    overall = round(
        (grammar["grammar_score"] * 0.4) +
        (max(0, 100 - fillers["total_fillers"] * 5) * 0.3) +
        (100 if 110 <= pacing["words_per_minute"] <= 160 else 60) * 0.3,
        1
    )

    return {
        "topic": topic,
        "transcript": transcript,
        "duration_seconds": duration,
        "filler_analysis": fillers,
        "pacing_analysis": pacing,
        "grammar_analysis": grammar,
        "overall_score": overall
    }