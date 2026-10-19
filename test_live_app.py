import urllib.request, json

BASE = "http://localhost:8000"
CUST = "415c5186-549e-44e9-9132-6d158175f5c1"

tests = [
    ("Health check",       BASE + "/health"),
    ("API root",           BASE + "/"),
    ("Discover dashboard", BASE + "/api/v1/recommendations/discover/" + CUST),
    ("Next basket",        BASE + "/api/v1/recommendations/next-basket/" + CUST),
    ("Recency weighted",   BASE + "/api/v1/recommendations/recency-weighted/" + CUST),
    ("Price aware",        BASE + "/api/v1/recommendations/price-aware/" + CUST),
    ("Local popularity",   BASE + "/api/v1/recommendations/local-popularity?buyer_id=" + CUST),
    ("Buy Again",          BASE + "/api/v1/recommendations/buy-again/" + CUST),
    ("You May Also Want",  BASE + "/api/v1/recommendations/you-may-also-want/" + CUST),
    ("Picked For You",     BASE + "/api/v1/recommendations/picked-for-you/" + CUST),
    ("Farmer recs",        BASE + "/api/v1/recommendations/farmer/farmer-001"),
]

print("=" * 60)
print("AgriLink Live API Smoke Test")
print("=" * 60)
ok = 0
fail = 0
for name, url in tests:
    try:
        with urllib.request.urlopen(url, timeout=10) as r:
            data = json.loads(r.read())
            if "sections" in data:
                counts = {k: len(v.get("items", [])) for k, v in data["sections"].items()}
                print("[{}] {} -> sections: {}".format(r.status, name, counts))
            elif "recommendations" in data:
                n = len(data["recommendations"])
                first = data["recommendations"][0].get("crop_name", "?") if n else "-"
                print("[{}] {} -> {} recs, first={}".format(r.status, name, n, first))
            elif "status" in data:
                print("[{}] {} -> {}".format(r.status, name, data["status"]))
            else:
                print("[{}] {} -> keys={}".format(r.status, name, list(data.keys())[:5]))
            ok += 1
    except Exception as e:
        print("[ERR] {} -> {}".format(name, e))
        fail += 1

print()
print("=" * 60)
print("Results: {} passed, {} failed".format(ok, fail))
