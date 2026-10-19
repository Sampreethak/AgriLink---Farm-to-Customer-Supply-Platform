import numpy as np
import pandas as pd


def minmax(s):
    s = pd.to_numeric(s, errors="coerce").fillna(0.0)
    if len(s) == 0 or s.max() == s.min():
        return pd.Series(1.0, index=s.index) if len(s) else s
    return (s - s.min()) / (s.max() - s.min())


def rank_candidates(candidates: pd.DataFrame, catalog: pd.DataFrame) -> pd.DataFrame:
    """Final transparent ranking layer for customer recommendations."""
    if candidates.empty:
        return candidates.copy()
    x = candidates.merge(catalog, on=["listing_id","crop_id","crop_name"], how="left", suffixes=("", "_catalog"))
    x["base_score"] = pd.to_numeric(x["score"], errors="coerce").fillna(0.0)
    x["rating_score"] = minmax(x.get("rating_avg", pd.Series(0, index=x.index)))
    x["availability_score"] = x.get("status", "AVAILABLE").astype(str).str.upper().eq("AVAILABLE").astype(float)
    x["freshness_score"] = 0.5
    if "harvest_date" in x.columns:
        harvest = pd.to_datetime(x["harvest_date"], errors="coerce", utc=True)
        days = (pd.Timestamp.now(tz="UTC") - harvest).dt.total_seconds() / 86400
        x["freshness_score"] = np.exp(-days.clip(lower=0).fillna(30) / 30.0).clip(0, 1)
    x["price_score"] = 1 - minmax(x.get("price_per_unit", pd.Series(0, index=x.index)))
    x["final_score"] = (0.55 * x["base_score"] + 0.15 * x["availability_score"] + 0.10 * x["rating_score"] + 0.10 * x["freshness_score"] + 0.10 * x["price_score"])
    return x.sort_values("final_score", ascending=False).reset_index(drop=True)
