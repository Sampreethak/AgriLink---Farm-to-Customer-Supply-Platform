# AgriLink NLP Conversational Retrieval Engine (AgriTalk)

A standalone, modular Natural Language Processing (NLP) and Conversational Information Retrieval engine designed for farmers in the Mandya–Bengaluru agro-corridor.

---

## Architecture & Modules

```
nlp_engine/
├── __init__.py           # Package exports (FarmerDatabaseNLPQueryEngine, IntentClassifier, NER)
├── query_engine.py       # Core conversational database retrieval engine with Farmer RLS scoping
├── intent_classifier.py  # TF-IDF + Cosine Similarity classifier for agricultural intents
├── crop_dictionary.py    # Multilingual NER dictionary (English, Kannada ಕನ್ನಡ, Hindi हिन्दी)
├── data_loader.py        # Autonomous table loader from database/csv/
├── nlp_query_engine.py   # Backward-compatibility alias
├── test_engine.py        # Comprehensive test suite
└── README.md             # Architecture documentation
```

---

## Core Capabilities

1. **Multilingual Entity Recognition (NER):** Recognizes crop names across English, Kannada (`ಕನ್ನಡ`), and Hindi (`हिन्दी`) scripts without third-party external cloud dependencies.
2. **Intent Classification:** Classifies farmer queries into 6 core agricultural domains:
   - `INVENTORY_LOOKUP`: Live stock verification
   - `PRICING_PREDICTION`: APMC mandi benchmarks + 68% direct farmer payouts
   - `BUYER_DEMAND_GAP`: High-margin unmet corridor orders
   - `ORDER_PAYOUT_HISTORY`: Escrow bank payout summaries
   - `LISTING_RATING_QUALITY`: Customer ratings and produce quality score
   - `PEST_DISEASE_ADVISORY`: Organic crop protection and bio-controls
3. **Strict Row-Level Security (RLS):** Scopes database queries strictly to the requesting farmer's authenticated account.
4. **Live Mandi Price Integration:** Dynamically pulls live market rates from the open-source Mandi Price API feed.

---

## Usage

```python
from nlp_engine import FarmerDatabaseNLPQueryEngine

engine = FarmerDatabaseNLPQueryEngine()
response = engine.process_query(
    query="What is my available Tomato stock?",
    farmer_id="6923de22-4eb3-4755-943a-b79bd8080890"
)
print(response["response"])
```
