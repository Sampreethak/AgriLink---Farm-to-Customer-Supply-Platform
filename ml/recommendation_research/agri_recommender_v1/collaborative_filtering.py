import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity


def train_user_based_cf(interactions: pd.DataFrame):
    """User-Based CF using cosine similarity over customer-listing interaction weights."""
    required = {"customer_id", "listing_id", "interaction_weight"}
    missing = required - set(interactions.columns)
    if missing:
        raise ValueError(f"Missing columns for CF: {sorted(missing)}")

    x = interactions.copy()
    x["interaction_weight"] = pd.to_numeric(x["interaction_weight"], errors="coerce").fillna(0)
    matrix = x.pivot_table(index="customer_id", columns="listing_id", values="interaction_weight", aggfunc="sum", fill_value=0.0)
    similarity = cosine_similarity(matrix) if len(matrix) else np.empty((0, 0))
    similarity_df = pd.DataFrame(similarity, index=matrix.index, columns=matrix.index)
    return matrix, similarity_df


def recommend_for_customer(customer_id, interactions: pd.DataFrame, listing_catalog: pd.DataFrame, top_n=10, min_similarity=0.0):
    matrix, similarity = train_user_based_cf(interactions)
    columns = ["customer_id","listing_id","crop_id","crop_name","score","recommendation_type","reason"]
    if customer_id not in matrix.index:
        return pd.DataFrame(columns=columns)

    target = matrix.loc[customer_id]
    already = set(target[target > 0].index)
    sims = similarity.loc[customer_id].drop(index=customer_id, errors="ignore")
    sims = sims[sims > min_similarity].sort_values(ascending=False)
    if sims.empty:
        return pd.DataFrame(columns=columns)

    scores = {}
    reasons = {}
    for other_customer, sim in sims.items():
        other = matrix.loc[other_customer]
        for listing_id, weight in other[other > 0].items():
            if listing_id in already:
                continue
            scores[listing_id] = scores.get(listing_id, 0.0) + float(sim) * float(weight)
            reasons[listing_id] = max(reasons.get(listing_id, 0.0), float(sim))

    if not scores:
        return pd.DataFrame(columns=columns)

    rec = pd.DataFrame([{"listing_id": k, "raw_score": v, "max_similarity": reasons[k]} for k, v in scores.items()])
    rec["score"] = rec["raw_score"] / rec["raw_score"].max() if rec["raw_score"].max() else 0.0
    catalog_cols = [c for c in ["listing_id","crop_id","crop_name"] if c in listing_catalog.columns]
    rec = rec.merge(listing_catalog[catalog_cols].drop_duplicates("listing_id"), on="listing_id", how="left")
    rec["customer_id"] = customer_id
    rec["recommendation_type"] = "COLLABORATIVE"
    rec["reason"] = rec["max_similarity"].map(lambda x: f"Similar customers interacted with this listing (max similarity {x:.2f}).")
    return rec.sort_values("score", ascending=False).head(top_n)[columns].reset_index(drop=True)
