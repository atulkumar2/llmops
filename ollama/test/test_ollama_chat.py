import requests

resp = requests.post(
    "http://localhost:11434/api/chat",
    json={
        "model": "qwen2.5-coder:14b",
        "messages": [
            {"role": "user", "content": "Write a Python function to parse CSV"}
        ],
        "stream": False,
    },
    timeout=600,
)

print(resp.json()["message"]["content"])
