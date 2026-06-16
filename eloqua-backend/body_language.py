import cv2
import mediapipe as mp
import numpy as np

mp_pose = mp.solutions.pose
mp_face_mesh = mp.solutions.face_mesh
mp_hands = mp.solutions.hands

def analyze_video(video_path: str) -> dict:
    cap = cv2.VideoCapture(video_path)
    total_frames = 0
    eye_contact_frames = 0
    good_posture_frames = 0
    gesture_frames = 0

    pose = mp_pose.Pose()
    face_mesh = mp_face_mesh.FaceMesh()
    hands = mp_hands.Hands()

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        total_frames += 1
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # ── Eye Contact ──────────────────────────────────────────
        # Checks if the nose tip landmark is centered in the frame
        # meaning the user is facing forward toward the camera
        face_result = face_mesh.process(rgb)
        if face_result.multi_face_landmarks:
            for face_landmarks in face_result.multi_face_landmarks:
                nose = face_landmarks.landmark[1]
                h, w, _ = frame.shape
                nose_x = nose.x * w
                nose_y = nose.y * h
                center_x = w / 2
                center_y = h / 2
                # If nose is within 20% of center, user is looking forward
                if abs(nose_x - center_x) < w * 0.20 and abs(nose_y - center_y) < h * 0.20:
                    eye_contact_frames += 1

        # ── Posture ──────────────────────────────────────────────
        # Checks if shoulders are level and head is upright
        pose_result = pose.process(rgb)
        if pose_result.pose_landmarks:
            landmarks = pose_result.pose_landmarks.landmark
            left_shoulder = landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER]
            right_shoulder = landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER]
            nose = landmarks[mp_pose.PoseLandmark.NOSE]

            shoulder_diff = abs(left_shoulder.y - right_shoulder.y)
            shoulder_mid_y = (left_shoulder.y + right_shoulder.y) / 2

            # Good posture: shoulders level and head above shoulders
            if shoulder_diff < 0.05 and nose.y < shoulder_mid_y:
                good_posture_frames += 1

        # ── Hand Gestures ────────────────────────────────────────
        # Checks if hands are visible and actively moving in frame
        hand_result = hands.process(rgb)
        if hand_result.multi_hand_landmarks:
            gesture_frames += 1

    cap.release()
    pose.close()
    face_mesh.close()
    hands.close()

    if total_frames == 0:
        return {"error": "Could not process video."}

    eye_contact_pct = round((eye_contact_frames / total_frames) * 100, 1)
    posture_pct = round((good_posture_frames / total_frames) * 100, 1)
    gesture_pct = round((gesture_frames / total_frames) * 100, 1)

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
        (posture_pct * 0.4) +
        (gesture_pct * 0.2),
        1
    )

    return {
        "eye_contact": {
            "score": eye_contact_pct,
            "feedback": eye_feedback
        },
        "posture": {
            "score": posture_pct,
            "feedback": posture_feedback
        },
        "gestures": {
            "score": gesture_pct,
            "feedback": gesture_feedback
        },
        "body_language_score": body_score
    }