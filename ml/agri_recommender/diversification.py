import pandas as pd

def diversify_recommendations(ranked_candidates: pd.DataFrame, max_per_category=2):
    """Ensure category diversity in top recommendation results."""
    if ranked_candidates.empty or "category_id" not in ranked_candidates.columns:
        return ranked_candidates

    diversified = []
    category_counts = {}
    for _, row in ranked_candidates.iterrows():
        cat = row.get("category_id", "default")
        if category_counts.get(cat, 0) < max_per_category:
            diversified.append(row)
            category_counts[cat] = category_counts.get(cat, 0) + 1

    return pd.DataFrame(diversified).reset_index(drop=True)
