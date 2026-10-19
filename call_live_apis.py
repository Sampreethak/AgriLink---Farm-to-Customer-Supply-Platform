import urllib.request
import json
import sys

# Force UTF-8 output encoding for Windows terminal
sys.stdout.reconfigure(encoding='utf-8')

BASE_URL = "http://127.0.0.1:8000"
CUST_ID = "415c5186-549e-44e9-9132-6d158175f5c1"

def fetch(path):
    url = f"{BASE_URL}{path}"
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode())

def post(path, payload):
    url = f"{BASE_URL}{path}"
    data = json.dumps(payload).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode())

print("=" * 80)
print("CALLING LIVE FASTAPI RECOMMENDATION API ENDPOINTS (http://127.0.0.1:8000)")
print("=" * 80)

# 1. Customer Home Dashboard API
print("\n[1] GET /api/v1/recommendations/customer-home/" + CUST_ID)
home_res = fetch(f"/api/v1/recommendations/customer-home/{CUST_ID}?cart_crops=Tomato,Onion")
print(f"Location: {home_res.get('location')}")
for sec_key, sec_val in home_res.get("sections", {}).items():
    print(f"  * Section '{sec_key}' ({sec_val.get('title', '')}): {len(sec_val['items'])} items")
    if sec_val["items"]:
        top = sec_val["items"][0]
        print(f"    -> Top Recommendation: {top['crop_name']} (Rs.{top['price_per_unit']}/{top['unit']}) | Reason: {top.get('reason')}")

# 2. Buy Again API
print("\n[2] GET /api/v1/recommendations/buy-again/" + CUST_ID)
buy_res = fetch(f"/api/v1/recommendations/buy-again/{CUST_ID}?top_k=3")
print(f"Model: {buy_res.get('model')} | Count: {buy_res.get('count')}")
for r in buy_res.get("recommendations", []):
    print(f"  -> {r['crop_name']} (Rs.{r['price_per_unit']}/{r['unit']}) | {r.get('reason')}")

# 3. You May Also Want API
print("\n[3] GET /api/v1/recommendations/you-may-also-want/" + CUST_ID)
want_res = fetch(f"/api/v1/recommendations/you-may-also-want/{CUST_ID}?cart_crops=Tomato,Onion&top_k=3")
print(f"Model: {want_res.get('model')} | Count: {want_res.get('count')}")
for r in want_res.get("recommendations", []):
    print(f"  -> {r['crop_name']} (Rs.{r['price_per_unit']}/{r['unit']}) | {r.get('reason')}")

# 4. Picked For You API
print("\n[4] GET /api/v1/recommendations/picked-for-you/" + CUST_ID)
picked_res = fetch(f"/api/v1/recommendations/picked-for-you/{CUST_ID}?top_k=3")
print(f"Model: {picked_res.get('model')} | Count: {picked_res.get('count')}")
for r in picked_res.get("recommendations", []):
    print(f"  -> {r['crop_name']} (Rs.{r['price_per_unit']}/{r['unit']}) | {r.get('reason')}")

# 5. Replacement Recommendations API
print("\n[5] GET /api/v1/recommendations/replacement/71052cc8-49f3-422f-be43-de34a2259d59")
rep_res = fetch("/api/v1/recommendations/replacement/71052cc8-49f3-422f-be43-de34a2259d59?top_k=3")
print(f"Count: {rep_res.get('count')}")
for r in rep_res.get("recommendations", []):
    print(f"  -> {r['crop_name']} (Rs.{r['price_per_unit']}/{r['unit']}) | {r.get('reason')}")

# 6. Farmer Recommendations API
print("\n[6] GET /api/v1/recommendations/farmer/6923de22-4eb3-4755-943a-b79bd8080890")
farm_res = fetch("/api/v1/recommendations/farmer/6923de22-4eb3-4755-943a-b79bd8080890?top_k=3")
print(f"Count: {farm_res.get('count')}")
for r in farm_res.get("recommendations", []):
    print(f"  -> Crop: {r.get('crop_name')} | Demand Gap: {r.get('supply_gap')} kg | Reason: {r.get('reason')}")

# 7. Aggregator Supplier Matcher API
print("\n[7] GET /api/v1/recommendations/aggregator/match?crop_name=Tomato&required_quantity=500")
agg_res = fetch("/api/v1/recommendations/aggregator/match?crop_name=Tomato&required_quantity=500&top_k=3")
print(f"Count: {agg_res.get('count')}")
for r in agg_res.get("recommendations", []):
    print(f"  -> Supplier: {r.get('farmer_name')} | Price: Rs.{r.get('price_per_unit')}/kg | Grade: {r.get('grade')}")

# 8. Live Interaction Record API
print("\n[8] POST /api/v1/recommendations/interact")
inter_res = post("/api/v1/recommendations/interact", {
    "customer_id": CUST_ID,
    "listing_id": "71052cc8-49f3-422f-be43-de34a2259d59",
    "interaction_type": "CART"
})
print(f"  -> Status: {inter_res}")

print("\n[LIVE API DEMONSTRATION COMPLETE] All endpoints responding 200 OK with live synthetic dataset recommendations!")
