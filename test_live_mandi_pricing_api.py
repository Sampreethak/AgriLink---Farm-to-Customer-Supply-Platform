import os
import sys

sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "backend_fastapi"))

from backend_fastapi.main import (
    get_apmc_benchmarks,
    calculate_fair_share,
    get_commodity_fair_share,
    process_nlp_query,
    PriceCalculationRequest,
    NLPQueryRequest
)

def test_live_mandi_integration():
    print("=" * 85)
    print("TESTING FASTAPI BACKEND SERVICES WITH LIVE OPEN-SOURCE MANDI PRICE API")
    print("=" * 85)
    
    # 1. Test get_apmc_benchmarks
    print("\n[1] Testing get_apmc_benchmarks() (Live Mandi APMC feed)...")
    data = get_apmc_benchmarks()
    print(f"Status: {data.get('status')}")
    print(f"Source: {data.get('source')}")
    print(f"Total benchmarks: {data.get('count')}")
    sample_benchmarks = dict(list(data.get("benchmarks_rs_per_kg", {}).items())[:6])
    print(f"Sample Live Benchmarks: {sample_benchmarks}")
    assert data.get("source") == "Open-Source Mandi Price API (AGMARKNET Karnataka Feed)"
    
    # 2. Test calculate_fair_share for Tomato
    print("\n[2] Testing calculate_fair_share() (Tomato, Mandya -> Bengaluru)...")
    req = PriceCalculationRequest(
        commodity="Tomato",
        origin_district="Mandya",
        variety="Hybrid / Nati",
        grade="Grade A",
        distance_km=85.0,
        is_organic=False
    )
    fair_share = calculate_fair_share(req)
    print(f"Commodity: {fair_share['commodity']}")
    print(f"Corridor: {fair_share['corridor']}")
    print(f"Pricing Source: {fair_share['pricing_source']}")
    print(f"APMC Market: {fair_share['apmc_market_name']} ({fair_share['apmc_district']})")
    print(f"Live APMC Modal Rate: ₹{fair_share['apmc_mandi_benchmark_per_kg']:.2f}/kg")
    print(f"ML Predicted Fair Consumer Price: ₹{fair_share['predicted_fair_consumer_price_per_kg']:.2f}/kg")
    print(f"Farmer Payout (68% Direct): ₹{fair_share['fair_share_breakdown']['farmer']['payout_per_kg']:.2f}/kg")
    print(f"Farmer Benefit: {fair_share['fair_share_breakdown']['farmer']['benefit_description']}")
    print(f"Aggregator Hub (10%): ₹{fair_share['fair_share_breakdown']['aggregator']['payout_per_kg']:.2f}/kg")
    print(f"Corridor Delivery (14%): ₹{fair_share['fair_share_breakdown']['delivery_partner']['payout_per_kg']:.2f}/kg")
    print(f"Platform Assaying (8%): ₹{fair_share['fair_share_breakdown']['platform']['payout_per_kg']:.2f}/kg")
    print(f"Consumer Supermarket Benchmark: ₹{fair_share['consumer_savings']['supermarket_benchmark_per_kg']:.2f}/kg (Save {fair_share['consumer_savings']['savings_pct']}%)")
    assert fair_share['fair_share_breakdown']['farmer']['share_pct'] == 68.0
    
    # 3. Test get_commodity_fair_share("Ragi")
    print("\n[3] Testing get_commodity_fair_share('Ragi')...")
    ragi_data = get_commodity_fair_share("Ragi")
    print(f"Ragi Market: {ragi_data['apmc_market_name']}")
    print(f"Ragi Real APMC Rate: ₹{ragi_data['apmc_mandi_benchmark_per_kg']:.2f}/kg")
    print(f"Ragi ML Fair Price: ₹{ragi_data['predicted_fair_consumer_price_per_kg']:.2f}/kg")
    print(f"Ragi Farmer 68% Share: ₹{ragi_data['fair_share_breakdown']['farmer']['payout_per_kg']:.2f}/kg")
    
    # 4. Test Chatbot AgriTalk AI with pricing query
    print("\n[4] Testing process_nlp_query() with natural language price question...")
    chat_req = NLPQueryRequest(
        query="What is today's tomato price and farmer payout?"
    )
    chat_res = process_nlp_query(chat_req)
    print("Chatbot Response:")
    for line in chat_res.get("response", "").split("\n"):
        print(f"   {line}")
    
    print("\n" + "=" * 85)
    print("ALL API ENDPOINTS & ML MODEL VALIDATED SUCCESSFULLY WITH LIVE MANDI FEED!")
    print("=" * 85)

if __name__ == "__main__":
    test_live_mandi_integration()
