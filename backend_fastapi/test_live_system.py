import urllib.request
import json
import sys

# Ensure UTF-8 output encoding for Windows terminal
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8')

print("==================================================================")
print("       AGRILINK DYNAMIC MULTI-MODEL RECOMMENDATION DEMO          ")
print("==================================================================")

# 1. FastAPI Health Check
print("\n[1] FASTAPI BACKEND & ML ENGINE STATUS:")
try:
    res = urllib.request.urlopen("http://127.0.0.1:8000/api/v1/health")
    health = json.loads(res.read().decode())
    print(f"  Status: {health.get('status')}")
    print(f"  Service: {health.get('service')}")
    print(f"  ML Loaded: {health.get('ml_loaded')}")
    print(f"  ML Engine: {health.get('ml_engine')}")
except Exception as e:
    print("  Error:", e)

# 2. Existing Customer Test (Warm-Start with Order History)
print("\n[2] EXISTING CUSTOMER DASHBOARD (Warm Start):")
existing_cust_id = "d48b9f71-c110-4f5f-83da-7b65dbfbc328"
try:
    url = f"http://127.0.0.1:8000/api/v1/recommendations/customer-home/{existing_cust_id}"
    res = urllib.request.urlopen(url)
    data = json.loads(res.read().decode())
    print(f"  Customer ID: {data.get('customer_id')} | Cold-Start: {data.get('is_cold_start')}")
    print(f"  Location: {data.get('location')}")
    
    for sec_key, sec_data in data.get("sections", {}).items():
        print(f"\n  >> {sec_data.get('title')} ({sec_data.get('model_name')}):")
        for item in sec_data.get("items", []):
            print(f"     • {item.get('crop_name')} (Rs.{item.get('price_per_unit')}/{item.get('unit')})")
            print(f"       Reason: {item.get('reason', '')}")
except Exception as e:
    print("  Error:", e)

# 3. New Customer Test (Cold-Start Mode)
print("\n[3] NEW / GUEST CUSTOMER DASHBOARD (Cold Start Mode):")
new_guest_id = "guest-new-user-cold-start"
try:
    url = f"http://127.0.0.1:8000/api/v1/recommendations/customer-home/{new_guest_id}"
    res = urllib.request.urlopen(url)
    data = json.loads(res.read().decode())
    print(f"  Customer ID: {data.get('customer_id')} | Cold-Start: {data.get('is_cold_start')}")
    print(f"  Location: {data.get('location')}")
    
    for sec_key, sec_data in data.get("sections", {}).items():
        print(f"\n  >> {sec_data.get('title')} ({sec_data.get('model_name')}):")
        for item in sec_data.get("items", []):
            print(f"     • {item.get('crop_name')} (Rs.{item.get('price_per_unit')}/{item.get('unit')})")
            print(f"       Reason: {item.get('reason', '')}")
except Exception as e:
    print("  Error:", e)

# 4. FP-Growth Dynamic Basket Association (When Cart has [Tomato, Onion])
print("\n[4] DYNAMIC BASKET CO-PURCHASE (Cart has [Tomato, Onion]):")
try:
    url = f"http://127.0.0.1:8000/api/v1/recommendations/you-may-also-want/{new_guest_id}?cart_crops=Tomato,Onion"
    res = urllib.request.urlopen(url)
    recs = json.loads(res.read().decode())
    print(f"  Model: {recs.get('model')} (Trigger: [Tomato, Onion])")
    for item in recs.get("recommendations", []):
        print(f"     • {item.get('crop_name')} (Rs.{item.get('price_per_unit')}/{item.get('unit')})")
        print(f"       Pairing: {item.get('reason', '')}")
except Exception as e:
    print("  Error:", e)

# 6. APMC Dynamic Pricing Engine & Fair-Share Breakdown
print("\n[6] APMC DYNAMIC PRICING & 4-WAY FAIR SHARE (Mandya -> Bengaluru):")
try:
    # 6.1 APMC Mandi Benchmarks
    res = urllib.request.urlopen("http://127.0.0.1:8000/api/v1/pricing/benchmarks")
    bench = json.loads(res.read().decode())
    print(f"  APMC Benchmarks Loaded ({bench.get('count')} commodities):")
    sample_commodities = ["Tomato", "Onion", "Palak", "Ginger", "Garlic", "Banana", "Ragi"]
    for c in sample_commodities:
        print(f"     • {c}: Rs.{bench['benchmarks_rs_per_kg'].get(c, 'N/A')}/kg (APMC Mandi Modal)")

    # 6.2 POST calculate-fair-share for Organic Tomato from Mandya
    req = urllib.request.Request(
        "http://127.0.0.1:8000/api/v1/pricing/calculate-fair-share",
        data=json.dumps({
            "commodity": "Tomato",
            "variety": "Organic Nati",
            "grade": "Grade A+",
            "origin_district": "Mandya",
            "distance_km": 85.0,
            "is_organic": True
        }).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )
    res = urllib.request.urlopen(req)
    pricing = json.loads(res.read().decode())
    print(f"\n  >> Dynamic Pricing Evaluation: {pricing.get('commodity')} ({pricing.get('corridor')})")
    print(f"     APMC Benchmark: Rs.{pricing.get('apmc_mandi_benchmark_per_kg')}/kg")
    print(f"     AgriLink Consumer Price: Rs.{pricing.get('predicted_fair_consumer_price_per_kg')}/kg")
    print(f"     City Supermarket Price: Rs.{pricing.get('consumer_savings', {}).get('supermarket_benchmark_per_kg')}/kg (Consumer Saves {pricing.get('consumer_savings', {}).get('savings_pct')}%)")
    print(f"\n  >> Transparent 4-Way Payout Breakdown:")
    for key, share in pricing.get("fair_share_breakdown", {}).items():
        print(f"     • {share.get('role')} ({share.get('share_pct')}%): Rs.{share.get('payout_per_kg')}/kg")
        print(f"       Info: {share.get('benefit_description')}")
except Exception as e:
    print("  Error:", e)

print("\n==================================================================")
print("System running cleanly on http://127.0.0.1:8000")
print("==================================================================")
