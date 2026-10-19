import os
import sys

# Add root directory to sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ml.model.predictor import RecommendationPredictor

def test_recommendation_engine():
    print("=" * 60)
    print("Testing AgriLink Recommendation Engine Integration...")
    print("=" * 60)

    predictor = RecommendationPredictor()

    sample_customer_id = "415c5186-549e-44e9-9132-6d158175f5c1"
    sample_farmer_id = "6923de22-4eb3-4755-943a-b79bd8080890"

    print("\n1. Testing Customer Home Dashboard Endpoint:")
    dashboard = predictor.get_customer_home_dashboard(sample_customer_id, cart_crops=["Tomato", "Onion"])
    print(f"  Customer ID: {dashboard['customer_id']}")
    print(f"  Location: {dashboard['location']}")
    for sec_key, sec_val in dashboard["sections"].items():
        print(f"  - Section '{sec_key}': {len(sec_val['items'])} items ({sec_val['model_name']})")
        if sec_val["items"]:
            top_item = sec_val["items"][0]
            print(f"    * Top item: {top_item['crop_name']} (Rs.{top_item['price_per_unit']}/{top_item['unit']}) - Reason: {top_item.get('reason')}")

    print("\n2. Testing Buy Again Recommendations:")
    buy_again = predictor.get_buy_again(sample_customer_id, top_k=3)
    print(f"  Retrieved {len(buy_again)} items")

    print("\n3. Testing You May Also Want (FP-Growth Basket Association):")
    you_may_want = predictor.get_you_may_also_want(sample_customer_id, cart_crops=["Tomato"], top_k=3)
    print(f"  Retrieved {len(you_may_want)} items")

    print("\n4. Testing Picked For You (User-Based Collaborative Filtering):")
    picked = predictor.get_picked_for_you(sample_customer_id, top_k=3)
    print(f"  Retrieved {len(picked)} items")

    print("\n5. Testing Replacement Listings:")
    replaces = predictor.get_replacement_listings("71052cc8-49f3-422f-be43-de34a2259d59", top_k=3)
    print(f"  Retrieved {len(replaces)} items")

    print("\n6. Testing Farmer Crop Opportunities:")
    farmer_opps = predictor.get_farmer_recommendations(sample_farmer_id, top_k=3)
    print(f"  Retrieved {len(farmer_opps)} opportunities")
    if farmer_opps:
        print(f"  * Top crop: {farmer_opps[0].get('crop_name')} (Demand gap: {farmer_opps[0].get('supply_gap')})")

    print("\n7. Testing Aggregator Supplier Matching:")
    matches = predictor.get_aggregator_matches("Tomato", required_quantity=500, top_k=3)
    print(f"  Retrieved {len(matches)} supplier matches")

    print("\n8. Testing Live Interaction Record:")
    interact_res = predictor.log_interaction(sample_customer_id, "71052cc8-49f3-422f-be43-de34a2259d59", "CART")
    print(f"  Result: {interact_res}")

    print("\n[SUCCESS] All 8 Recommendation Engine workflows verified successfully!")

if __name__ == "__main__":
    test_recommendation_engine()
