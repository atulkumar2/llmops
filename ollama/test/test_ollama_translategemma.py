"""
Docstring for ollama.test_ollama_translategemma
"""

import requests

# TranslateGemma translation prompt format
prompt = """You are a professional English (en) to Spanish (es) translator.
Your goal is to accurately convey the meaning and nuances of the original
English text while adhering to Spanish grammar, vocabulary, and cultural
sensitivities. Produce only the Spanish translation, without any additional
explanations or commentary. Please translate the following English text into
Spanish:


Hello, how are you?
"""

resp = requests.post(
    "http://localhost:11434/api/generate",
    json={
        "model": "translategemma:latest",
        "prompt": prompt,
        "stream": False,
    },
    timeout=600,
)

print(resp.json()["response"])
