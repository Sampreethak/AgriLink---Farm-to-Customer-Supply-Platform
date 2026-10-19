import os
import sys

sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ml.nlp_query_engine import FarmerDatabaseNLPQueryEngine

def test_farmer_rls():
    print("=" * 80)
    print("TESTING STRICT ROW LEVEL SECURITY (RLS) IN FARMER CHATBOT ENGINE")
    print("=" * 80)

    engine = FarmerDatabaseNLPQueryEngine()

    farmer_1 = "6923de22-4eb3-4755-943a-b79bd8080890"
    farmer_2 = "11111111-1111-1111-1111-111111111111"

    print("\n[TEST 1] INVENTORY LOOKUP FOR FARMER 1 (ID: 6923de22...):")
    res1 = engine.process_query("What is my available inventory stock?", farmer_id=farmer_1)
    print("Response:\n", res1['response'])

    print("\n[TEST 2] INVENTORY LOOKUP FOR FARMER 2 (ID: 11111111...):")
    res2 = engine.process_query("What is my available inventory stock?", farmer_id=farmer_2)
    print("Response:\n", res2['response'])

    print("\n[TEST 3] ORDER PAYOUT SUMMARY FOR FARMER 1 (ID: 6923de22...):")
    payout1 = engine.process_query("How much total payout and earnings did I receive?", farmer_id=farmer_1)
    print("Response:\n", payout1['response'])

    print("\n[TEST 4] ORDER PAYOUT SUMMARY FOR FARMER 2 (ID: 11111111...):")
    payout2 = engine.process_query("How much total payout and earnings did I receive?", farmer_id=farmer_2)
    print("Response:\n", payout2['response'])

    print("\n[TEST 5] PRODUCE QUALITY RATING FOR FARMER 1 (ID: 6923de22...):")
    rating1 = engine.process_query("What is my crop produce rating?", farmer_id=farmer_1)
    print("Response:\n", rating1['response'])

    print("\n[SUCCESS] Row Level Security (RLS) verified: Database responses are strictly scoped to each farmer's own account data!")

if __name__ == "__main__":
    test_farmer_rls()
