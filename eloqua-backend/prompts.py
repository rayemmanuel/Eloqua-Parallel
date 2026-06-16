import json, random

with open("prompts_data.json", "r") as f:
    PROMPTS = json.load(f)

def get_prompt(category: str = "academic", difficulty: str = "intermediate") -> dict:
    category = category.lower()
    difficulty = difficulty.lower()
    try:
        options = PROMPTS[category][difficulty]
        return {"category": category, "difficulty": difficulty, "prompt": random.choice(options)}
    except KeyError:
        return {"error": f"No prompts found for category='{category}' difficulty='{difficulty}'"}

def get_all_categories() -> list:
    return list(PROMPTS.keys())