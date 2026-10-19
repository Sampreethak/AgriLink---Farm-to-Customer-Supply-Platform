import pandas as pd


def recommend_supplier_listings(crop_name, required_quantity, catalog, top_n=10):
    """
    Rank available farmer supplier listings for an aggregator demand requirement.
    """
    c_str = str(crop_name).lower()
    x = catalog[catalog["crop_name"].astype(str).str.lower() == c_str].copy()
    if "status" in x.columns:
        x = x[x["status"].astype(str).str.upper().isin(["AVAILABLE", "ACTIVE"])].copy()

    if x.empty:
        # Match by partial string or return general available catalog items
        x = catalog[catalog["crop_name"].astype(str).str.lower().str.contains(c_str)].copy()

    if x.empty:
        return x

    req_qty = max(float(required_quantity), 1.0)
    x["quantity_fit"] = (pd.to_numeric(x.get("quantity", 0), errors="coerce").fillna(0) / req_qty).clip(upper=1.0)

    prices = pd.to_numeric(x.get("price_per_unit", 0), errors="coerce").fillna(0)
    min_p, max_p = prices.min(), prices.max()
    if max_p > min_p:
        x["price_score"] = 1 - (prices - min_p) / (max_p - min_p)
    else:
        x["price_score"] = 1.0

    grade_score_map = {"A+": 1.0, "A": 0.9, "B": 0.75, "C": 0.6}
    x["quality_score"] = x.get("grade", pd.Series("A", index=x.index)).map(grade_score_map).fillna(0.7)
    x["rating_score"] = pd.to_numeric(x.get("rating_avg", 0), errors="coerce").fillna(0) / 5.0

    x["match_score"] = (
        0.35 * x["quantity_fit"] +
        0.25 * x["quality_score"] +
        0.20 * x["price_score"] +
        0.20 * x["rating_score"]
    )
    x["recommendation_type"] = "AGGREGATOR_SUPPLIER"
    x["reason"] = x.apply(
        lambda r: f"Supplier match score {r['match_score']:.2f} • Available: {r.get('quantity', 0)} kg @ ₹{r.get('price_per_unit', 0)}/kg (Grade {r.get('grade', 'A')}).",
        axis=1
    )
    return x.sort_values("match_score", ascending=False).head(top_n).reset_index(drop=True)
