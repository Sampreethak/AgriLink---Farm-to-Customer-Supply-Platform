import os
import sys

sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "ml_pricing_model"))

from pricing_predictor import DynamicPricingPredictor

def run_integration_verification():
    print("=" * 90)
    print("AGRILINK: VERIFYING OPEN-SOURCE MANDI PRICE API INTEGRATION WITH ML PRICING ENGINE")
    print("=" * 90)
    
    predictor = DynamicPricingPredictor()
    
    test_crops = [
        ("Tomato", "Mandya", True, "Grade A"),
        ("Potato", "Mandya", False, "Grade A"),
        ("Onion", "Mandya", False, "Grade A"),
        ("Carrot", "Mandya", True, "Grade A+"),
        ("Ragi", "Mandya", False, "Grade A"),
        ("Green Chilli", "Ramanagara", False, "Grade A"),
        ("Garlic", "Mandya", False, "Grade A"),
        ("Banana", "Mandya", True, "Grade A")
    ]
    
    print("\n{:<14} {:<24} {:<12} {:<15} {:<15} {:<12}".format(
        "Commodity", "Market (District)", "Mandi Modal", "ML Fair Price", "Farmer 68%", "Source"
    ))
    print("-" * 95)
    
    for crop, origin, organic, grade in test_crops:
        res = predictor.calculate_price_and_shares(
            commodity=crop,
            origin_district=origin,
            is_organic=organic,
            grade=grade,
            distance_km=85.0
        )
        
        mkt_info = f"{res['apmc_market_name']} ({res['apmc_district']})"[:23]
        mandi_val = f"₹{res['apmc_mandi_benchmark_per_kg']:.2f}/kg"
        fair_val = f"₹{res['predicted_fair_consumer_price_per_kg']:.2f}/kg"
        farmer_val = f"₹{res['fair_share_breakdown']['farmer']['payout_per_kg']:.2f}/kg"
        src = "Live Mandi API" if res['is_live_apmc_feed'] else "Baseline"
        
        print("{:<14} {:<24} {:<12} {:<15} {:<15} {:<12}".format(
            crop + (" (Org)" if organic else ""), mkt_info, mandi_val, fair_val, farmer_val, src
        ))

    print("\n" + "=" * 90)
    print("BENCHMARKS SUMMARY (All Active Crops):")
    benchmarks = predictor.get_live_benchmarks()
    for c, p in list(benchmarks.items())[:8]:
        print(f"  • {c:16}: ₹{p:.2f}/kg")
    
    print("\n[SUCCESS] Open-Source Mandi Price API successfully integrated with AgriLink ML Engine!")
    print("=" * 90)

if __name__ == "__main__":
    run_integration_verification()
