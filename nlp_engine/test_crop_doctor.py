import os
import sys

sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from nlp_engine import AICropDoctorService, FarmerDatabaseNLPQueryEngine

def run_crop_doctor_tests():
    print("=" * 80)
    print("VERIFYING CLUSTER-INTEGRATED AI CROP DOCTOR & ADVISORY SERVICE")
    print("=" * 80)

    doctor = AICropDoctorService()
    assert not doctor.cluster_df.empty, "Knowledge base failed to load!"

    # Test 1: Fruit fly control in cucurbits
    print("\n[TEST 1] Query: 'How to control fruit fly in bottle gourd?'")
    res1 = doctor.diagnose_and_prescribe("How to control fruit fly in bottle gourd?")
    print(f"  Matched Cluster: {res1['cluster_id']} -> {res1['diagnosis']}")
    print(f"  Chemical Remedy: {res1['chemical_remedy']}")
    assert "Malathion" in res1['chemical_remedy'] or "0.0" in res1['cluster_id']
    print("  ✓ Test 1 Passed!")

    # Test 2: Tomato bacterial / fungal wilt
    print("\n[TEST 2] Query: 'My tomato crop is wilting rapidly'")
    res2 = doctor.diagnose_and_prescribe("My tomato crop is wilting rapidly")
    print(f"  Matched Cluster: {res2['cluster_id']} -> {res2['diagnosis']}")
    print(f"  Chemical Remedy: {res2['chemical_remedy']}")
    assert "wilt" in res2['diagnosis'].lower() or "5.1" in res2['cluster_id']
    print("  ✓ Test 2 Passed!")

    # Test 3: Multilingual Kannada query (Vernacular symptom normalization)
    print("\n[TEST 3] Vernacular Query: 'ಟೊಮ್ಯಾಟೊ ಎಲೆ ಮುದುರುತ್ತಿದೆ'")
    res3 = doctor.diagnose_and_prescribe("ಟೊಮ್ಯಾಟೊ ಎಲೆ ಮುದುರುತ್ತಿದೆ", language="kn")
    print(f"  Extracted Crop: {res3['crop']}")
    print(f"  Matched Cluster: {res3['cluster_id']} -> {res3['diagnosis']}")
    print("  Bot Response Snippet:\n", res3['response'][:180])
    assert res3['crop'] == "Tomato"
    print("  ✓ Test 3 (Vernacular Kannada RAG) Passed!")

    # Test 4: Integration with FarmerDatabaseNLPQueryEngine
    print("\n[TEST 4] Full Query Engine Pipeline Test...")
    engine = FarmerDatabaseNLPQueryEngine()
    chat_res = engine.process_query("What spray should I use for potato late blight?")
    print(f"  Intent: {chat_res.get('intent')}")
    print(f"  Response:\n{chat_res.get('response')}")
    assert chat_res['intent'] == "PEST_DISEASE_ADVISORY"
    print("  ✓ Test 4 (NLP Query Engine Integration) Passed!")

    print("\n[ALL AI CROP DOCTOR CLUSTER INTEGRATION TESTS PASSED 100%]")

if __name__ == "__main__":
    run_crop_doctor_tests()
