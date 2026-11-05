import os
import sys

sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from nlp_engine import (
    FarmerDatabaseNLPQueryEngine,
    extract_crop_entity,
    IntentClassifier
)

def run_tests():
    print("=" * 80)
    print("RUNNING UNIT TESTS FOR MODULAR NLP ENGINE")
    print("=" * 80)

    # 1. Test Entity Extraction (English, Kannada, Hindi)
    print("\n[1] Testing Multilingual Named Entity Recognition (NER)...")
    assert extract_crop_entity("Do you have tomato?") == "Tomato"
    assert extract_crop_entity("ನನ್ನ ಬಳಿ ಟೊಮ್ಯಾಟೊ ಇದೆ") == "Tomato"
    assert extract_crop_entity("मुझे टमाटर का भाव बताओ") == "Tomato"
    assert extract_crop_entity("Check onion price") == "Onion"
    assert extract_crop_entity("ಈರುಳ್ಳಿ ಎಷ್ಟು ಬೆಲೆ?") == "Onion"
    assert extract_crop_entity("Where is my ragi harvest?") == "Ragi"
    assert extract_crop_entity("ರಾಗಿ ಬೆಳೆ") == "Ragi"
    print("  ✓ English, Kannada, and Hindi NER passed 100%!")

    # 2. Test Intent Classifier
    print("\n[2] Testing Intent Classification...")
    classifier = IntentClassifier()
    intent, conf = classifier.classify_intent("What is my current inventory stock?")
    assert intent == "INVENTORY_LOOKUP"
    print(f"  ✓ 'inventory stock' -> {intent} (conf: {conf:.2f})")

    intent, conf = classifier.classify_intent("How much money or payout did I earn?")
    assert intent == "ORDER_PAYOUT_HISTORY"
    print(f"  ✓ 'payout earned' -> {intent} (conf: {conf:.2f})")

    intent, conf = classifier.classify_intent("How to spray for leaf curl pest?")
    assert intent == "PEST_DISEASE_ADVISORY"
    print(f"  ✓ 'pest spray' -> {intent} (conf: {conf:.2f})")

    # 3. Test Full Engine
    print("\n[3] Testing FarmerDatabaseNLPQueryEngine...")
    engine = FarmerDatabaseNLPQueryEngine()
    res = engine.process_query("What is my available Tomato stock?", farmer_id="6923de22-4eb3-4755-943a-b79bd8080890")
    assert res["intent"] == "INVENTORY_LOOKUP"
    assert res["extracted_crop"] == "Tomato"
    print("  ✓ Full pipeline end-to-end response verified successfully!")
    print("\n[ALL NLP ENGINE TESTS PASSED SUCCESSFULLY]")

if __name__ == "__main__":
    run_tests()
