import numpy as np
import pandas as pd


def _minmax(s):
    s = pd.to_numeric(s, errors="coerce").fillna(0.0)
    if s.max() == s.min():
        return pd.Series(1.0, index=s.index) if len(s) else s
    return (s - s.min()) / (s.max() - s.min())


def generate_buy_again(purchase_data: pd.DataFrame, customer_id=None, top_n=10):
    """Rank previously purchased listings/crops using recency, frequency and quantity."""
    required = {"customer_id", "listing_id", "crop_id", "crop_name", "quantity", "created_at"}
    missing = required - set(purchase_data.columns)
    if missing:
        raise ValueError(f"Missing columns for Buy Again: {sorted(missing)}")

    df = purchase_data.copy()
    if customer_id is not None:
        df = df[df["customer_id"] == customer_id].copy()
    if df.empty:
        return pd.DataFrame(columns=["customer_id","listing_id","crop_id","crop_name","score","recommendation_type","reason"])

    df["created_at"] = pd.to_datetime(df["created_at"], errors="coerce", utc=True)
    reference = df["created_at"].max()
    grouped = df.groupby(["customer_id", "listing_id", "crop_id", "crop_name"], as_index=False).agg(
        purchase_count=("order_id", "nunique"),
        total_quantity=("quantity", "sum"),
        last_purchase_date=("created_at", "max")
    )
    grouped["days_since_last_purchase"] = (reference - grouped["last_purchase_date"]).dt.total_seconds() / 86400
    grouped["days_since_last_purchase"] = grouped["days_since_last_purchase"].clip(lower=0)
    grouped["recency_score"] = np.exp(-grouped["days_since_last_purchase"] / 30.0)
    grouped["frequency_score"] = _minmax(grouped["purchase_count"])
    grouped["quantity_score"] = _minmax(grouped["total_quantity"])
    grouped["score"] = (0.50 * grouped["recency_score"] + 0.30 * grouped["frequency_score"] + 0.20 * grouped["quantity_score"]).clip(0, 1)
    grouped["recommendation_type"] = "BUY_AGAIN"
    grouped["reason"] = "Previously purchased; ranked by recency, purchase frequency and quantity."
    return grouped.sort_values("score", ascending=False).head(top_n)[["customer_id","listing_id","crop_id","crop_name","score","recommendation_type","reason"]].reset_index(drop=True)
