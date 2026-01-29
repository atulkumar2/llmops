"""Test streaming response from Ollama API"""

import json

import requests

print("\n###########################\n")
print("Testing ollama streaming\n")
print("###########################\n")

with requests.post(
    "http://localhost:11434/api/generate",
    json={"model": "llama3", "prompt": "Explain transformers", "stream": True},
    stream=True,
    timeout=30,
) as r:
    for line in r.iter_lines():
        if line:
            data = json.loads(line)
            print(data.get("response", ""), end="", flush=True)

print("\n\n=======================================\n")
