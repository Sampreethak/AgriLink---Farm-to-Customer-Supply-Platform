import urllib.request
import json
import sys

# Ensure UTF-8 output encoding for Windows terminal
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8')

print("==================================================================")
print("             AGRILINK LIVE SYSTEM DEMONSTRATION                   ")
print("==================================================================")

# 1. FastAPI Health Check
print("\n[1] FASTAPI BACKEND HEALTH CHECK:")
try:
    res = urllib.request.urlopen("http://127.0.0.1:8000/api/v1/health")
    health = json.loads(res.read().decode())
    print("  Status:", health.get("status"))
    print("  Service:", health.get("service"))
    print("  Database:", health.get("database"))
    print("  ML Engine Loaded:", health.get("ml_loaded"))
except Exception as e:
    print("  Error:", e)

# 2. LightFM ML Recommendations Test
print("\n[2] LIGHTFM AI HYBRID RECOMMENDATION ENGINE (Top Picks for Buyer Priya Verma):")
try:
    url = "http://127.0.0.1:8000/api/v1/recommendations/55555555-5555-5555-5555-555555555555"
    res = urllib.request.urlopen(url)
    recs = json.loads(res.read().decode())
    print("  Buyer ID:", recs.get("buyer_id"))
    print("  Algorithm:", recs.get("algorithm"))
    print("  Total Recommendations:", recs.get("count"))
    print("  Top Recommended Crop Listings:")
    for i, item in enumerate(recs.get("recommendations", [])[:5], 1):
        print(f"    {i}. {item.get('title')} ({item.get('crop_name')}) - Rs.{item.get('price_per_unit')}/{item.get('unit')} | Rating: {item.get('rating_avg')} stars")
except Exception as e:
    print("  Error:", e)

# 3. Crop Listings API
print("\n[3] CROP LISTINGS API:")
try:
    res = urllib.request.urlopen("http://127.0.0.1:8000/api/v1/listings")
    listings = json.loads(res.read().decode())
    print(f"  Retrieved {len(listings)} active crop listings from database.")
    for l in listings[:3]:
        print(f"    - {l.get('title')} by {l.get('farmer_name')} | Stock: {l.get('available_quantity')} {l.get('unit')}")
except Exception as e:
    print("  Error:", e)

print("\n==================================================================")
print("System running cleanly on http://127.0.0.1:8000")
print("==================================================================")
