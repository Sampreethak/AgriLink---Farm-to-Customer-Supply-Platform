import numpy as np
from typing import Dict, List, Tuple
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

INTENT_TEMPLATES: Dict[str, List[str]] = {
    "INVENTORY_LOOKUP": [
        "what is my available inventory stock",
        "show my crop stock quantity",
        "how much quantity of crop do I have listed",
        "what crops do I have available in inventory",
        "check my inventory stock items",
        "ನನ್ನ ಸ್ಟಾಕ್ ಎಷ್ಟಿದೆ",
        "मेरा इन्वेंट्री स्टॉक कितना है"
    ],
    "PRICING_PREDICTION": [
        "what is the predicted APMC market price for my crop",
        "how much price will I get for tomato onion potato",
        "what is the fair farmer payout per kg rate",
        "check apmc mandi price and fair share rate",
        "predict price for crop",
        "ಮಂಡಿ ದರ ಎಷ್ಟು",
        "मंडी भाव कितना है"
    ],
    "BUYER_DEMAND_GAP": [
        "which crops are in high market demand right now",
        "where is the supply gap for crops",
        "what crop should I plant or list next for highest profit",
        "show buyer demand opportunities and unmet quantity",
        "ಯಾವ ಬೆಳೆಗೆ ಹೆಚ್ಚು ಬೇಡಿಕೆ ಇದೆ",
        "किस फसल की सबसे ज्यादा मांग है"
    ],
    "ORDER_PAYOUT_HISTORY": [
        "how much earnings or payouts did I receive this month",
        "show my recent delivered orders and payment status",
        "what orders are active or pending delivery",
        "check my total payout income from direct buyers",
        "ನನ್ನ ಆದಾಯ ಮತ್ತು ಪಾವತಿ ಎಷ್ಟು",
        "मेरी कुल कमाई कितनी है"
    ],
    "LISTING_RATING_QUALITY": [
        "what is the average customer rating for my listings",
        "show my grade A produce quality score",
        "how many reviews do my crop listings have",
        "ನನ್ನ ರೇಟಿಂಗ್ ಎಷ್ಟು",
        "मेरी फसल की रेटिंग क्या है"
    ]
}

class IntentClassifier:
    """
    TF-IDF Vectorizer + Cosine Similarity Intent Classifier with domain keyword heuristics.
    """
    def __init__(self):
        self.vectorizer = TfidfVectorizer(ngram_range=(1, 2))
        self.intent_labels: List[str] = []
        self.intent_vectors = None
        self._build_classifier()

    def _build_classifier(self):
        corpus = []
        for intent, examples in INTENT_TEMPLATES.items():
            for example in examples:
                corpus.append(example)
                self.intent_labels.append(intent)

        if corpus:
            self.intent_vectors = self.vectorizer.fit_transform(corpus)

    def classify_intent(self, query: str) -> Tuple[str, float]:
        """Classifies the natural language query into domain intents."""
        if self.intent_vectors is None:
            return "GENERAL", 0.0

        q = query.lower().strip()

        # High priority agricultural rule-based keyword overrides
        if any(w in q for w in ["pest", "disease", "curl", "blight", "spray", "insect", "worm", "fungus", "ಕೀಟ", "ರೋಗ"]):
            return "PEST_DISEASE_ADVISORY", 0.95
        elif any(w in q for w in ["rating", "review", "score", "star", "ರೇಟಿಂಗ್"]):
            return "LISTING_RATING_QUALITY", 0.90

        query_vec = self.vectorizer.transform([q])
        sims = cosine_similarity(query_vec, self.intent_vectors)[0]

        max_idx = int(np.argmax(sims))
        max_sim = float(sims[max_idx])

        # Semantic keyword fallbacks if vector similarity is low
        if max_sim < 0.15:
            if any(w in q for w in ["stock", "inventory", "available", "quantity", "kg", "ಸ್ಟಾಕ್"]):
                return "INVENTORY_LOOKUP", 0.8
            elif any(w in q for w in ["price", "rate", "cost", "mandi", "apmc", "ದರ", "ಬೆಲೆ", "ಭಾವ"]):
                return "PRICING_PREDICTION", 0.8
            elif any(w in q for w in ["demand", "gap", "opportunity", "plant", "grow", "ಬೇಡಿಕೆ"]):
                return "BUYER_DEMAND_GAP", 0.8
            elif any(w in q for w in ["order", "earning", "payout", "payment", "income", "ಹಣ", "ಆದಾಯ"]):
                return "ORDER_PAYOUT_HISTORY", 0.8
            return "GENERAL", max_sim

        return self.intent_labels[max_idx], max_sim
