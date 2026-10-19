import urllib.request
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

url = "http://127.0.0.1:8000/api/v1/chatbot/query"
payload = {
    "query": "What is my available Tomato inventory stock?",
    "language": "en",
    "role": "FARMER",
    "user_id": "6923de22-4eb3-4755-943a-b79bd8080890"
}

data = json.dumps(payload).encode('utf-8')
req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})

try:
    with urllib.request.urlopen(req) as response:
        res = json.loads(response.read().decode())
        print("Live Chatbot API Response:")
        print("Intent:", res.get("intent"))
        print("Extracted Crop:", res.get("extracted_crop"))
        print("Response:\n", res.get("response"))
except Exception as e:
        print("HTTP Error:", e)
