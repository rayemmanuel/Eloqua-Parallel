import cv2
import mediapipe as mp
import numpy as np
import os
import time
from concurrent.futures import ProcessPoolExecutor

mp_pose = mp.solutions.pose
mp_face_mesh = mp.solutions.face_mesh
mp_hands = mp.solutions.hands


# ── Top-level worker function (must be at module level to be picklable) ──────
def _process_frame_range(args: tuple) -> tuple:
    """
    Worker function executed in a separate process.

    PDC Concept — Data Parallelism:
        Each worker receives a (video_path, start_frame, end_frame) tuple
        and independently opens the video file, seeks to its assigned frame
        range, creates its own MediaPipe model instances (models cannot be
        shared or passed across process boundaries), and processes its chunk.

    Returns: (eye_frames, posture_frames, gesture_frames, total_frames)
    """
    video_path, start_frame, end_frame = args

    cap = cv2.VideoCapture(video_path)
    cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)

    # Each worker creates its own MediaPipe instances — they are not picklable
    # and therefore cannot be passed as arguments across process boundaries.
    pose      = mp.solutions.pose.Pose(static_image_mode=False)
    face_mesh = mp.solutions.face_mesh.FaceMesh(static_image_mode=False)
    hands     = mp.solutions.hands.Hands(static_image_mode=False)

    eye_frames     = 0
    posture_frames = 0
    gesture_frames = 0
    total_frames   = 0

    for _ in range(end_frame - start_frame):
        ret, frame = cap.read()
        if not ret:
            break

        total_frames += 1
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        h, w, _ = frame.shape

        # ── Eye Contact ──────────────────────────────────────────
        # Checks if the nose tip landmark is centered in the frame,
        # meaning the user is facing forward toward the camera.
        face_result = face_mesh.process(rgb)
        if face_result.multi_face_landmarks:
            for face_landmarks in face_result.multi_face_landmarks:
                nose = face_landmarks.landmark[1]
                if (abs(nose.x * w - w / 2) < w * 0.20 and
                        abs(nose.y * h - h / 2) < h * 0.20):
                    eye_frames += 1

        # ── Posture ──────────────────────────────────────────────
        # Checks if shoulders are level and head is upright.
        pose_result = pose.process(rgb)
        if pose_result.pose_landmarks:
            lm = pose_result.pose_landmarks.landmark
            l_sh  = lm[mp.solutions.pose.PoseLandmark.LEFT_SHOULDER]
            r_sh  = lm[mp.solutions.pose.PoseLandmark.RIGHT_SHOULDER]
            nose_lm = lm[mp.solutions.pose.PoseLandmark.NOSE]
            if (abs(l_sh.y - r_sh.y) < 0.05 and
                    nose_lm.y < (l_sh.y + r_sh.y) / 2):
                posture_frames += 1

        # ── Hand Gestures ────────────────────────────────────────
        # Checks if hands are visible in the frame.
        hand_result = hands.process(rgb)
        if hand_result.multi_hand_landmarks:
            gesture_frames += 1

    cap.release()
    pose.close()
    face_mesh.close()
    hands.close()

    return eye_frames, posture_frames, gesture_frames, total_frames


def analyze_video(video_path: str) -> dict:
    """
    Analyzes a video for eye contact, posture, and hand gestures.

    PDC Optimization — Multiprocessing (Data Parallelism):
        The video's total frame count is divided into N equal chunks,
        where N = number of logical CPU cores. Each chunk is processed
        by a separate worker process via ProcessPoolExecutor. Because
        video frames are independent (frame N does not depend on frame
        N-1 for pose detection), this is a perfect case for data
        parallelism. Results from all workers are aggregated at the end.
    """
    t_start = time.perf_counter()

    # ── Step 1: Count total frames (fast, serial) ────────────────
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        return {"error": "Could not open video file."}
    total_frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    cap.release()

    if total_frame_count == 0:
        return {"error": "Video file appears to be empty."}

    # ── Step 2: Split frames into chunks (one per CPU core) ──────
    n_workers = max(1, os.cpu_count() or 1)
    chunk_size = max(1, total_frame_count // n_workers)

    # Build (video_path, start_frame, end_frame) tuples for each worker
    chunks = []
    for i in range(n_workers):
        start = i * chunk_size
        end   = total_frame_count if i == n_workers - 1 else start + chunk_size
        chunks.append((video_path, start, end))

    print(f"[BENCHMARK] Splitting {total_frame_count} frames across {n_workers} workers")

    # ── Step 3: Process all chunks in parallel ───────────────────
    t_parallel = time.perf_counter()
    with ProcessPoolExecutor(max_workers=n_workers) as executor:
        results = list(executor.map(_process_frame_range, chunks))
    print(f"[BENCHMARK] Parallel frame processing: {time.perf_counter() - t_parallel:.2f}s")

    # ── Step 4: Aggregate results from all workers ───────────────
    total_eye      = sum(r[0] for r in results)
    total_posture  = sum(r[1] for r in results)
    total_gesture  = sum(r[2] for r in results)
    total_frames   = sum(r[3] for r in results)
    print(f"[BENCHMARK] analyze_video total: {time.perf_counter() - t_start:.2f}s")

    if total_frames == 0:
        return {"error": "Could not process video."}

    eye_contact_pct = round((total_eye     / total_frames) * 100, 1)
    posture_pct     = round((total_posture / total_frames) * 100, 1)
    gesture_pct     = round((total_gesture / total_frames) * 100, 1)

    # ── Feedback Messages ────────────────────────────────────────
    eye_feedback = (
        "Great eye contact — you maintained a forward gaze consistently."
        if eye_contact_pct >= 70 else
        "Try to look more toward the camera to improve audience engagement."
    )
    posture_feedback = (
        "Good posture throughout the session."
        if posture_pct >= 70 else
        "Work on keeping your shoulders level and your head upright."
    )
    gesture_feedback = (
        "Good use of hand gestures to support your delivery."
        if gesture_pct >= 40 else
        "Try using your hands more naturally to emphasize key points."
    )

    # ── Body Language Overall Score ───────────────────────────────
    body_score = round(
        (eye_contact_pct * 0.4) +
        (posture_pct     * 0.4) +
        (gesture_pct     * 0.2),
        1
    )

    return {
        "eye_contact": {"score": eye_contact_pct, "feedback": eye_feedback},
        "posture":     {"score": posture_pct,     "feedback": posture_feedback},
        "gestures":    {"score": gesture_pct,     "feedback": gesture_feedback},
        "body_language_score": body_score
    }