import numpy as np
import pandas as pd

def recommend_replacements(target_listing_id, catalog: pd.DataFrame, top_n=3):
    """Replacement ranking. Historical replacement behavior is not present in the uploaded schema, so this uses available same-crop alternatives plus product-level quality/price/rating signals."""
    required={"listing_id","crop_id","crop_name","status","price_per_unit","rating_avg","grade"}
    missing=required-set(catalog.columns)
    if missing: raise ValueError(f"Missing columns for replacement: {sorted(missing)}")
    target=catalog[catalog["listing_id"]==target_listing_id]
    if target.empty: return pd.DataFrame()
    target=target.iloc[0]
    x=catalog[(catalog["listing_id"]!=target_listing_id) & catalog["status"].astype(str).str.upper().eq("AVAILABLE")].copy()
    if x.empty: return x
    x["same_crop"]=(x["crop_id"]==target["crop_id"]).astype(float)
    x["price_similarity"]=1/(1+abs(pd.to_numeric(x["price_per_unit"],errors="coerce").fillna(0)-float(target["price_per_unit"])))
    x["rating_score"]=pd.to_numeric(x["rating_avg"],errors="coerce").fillna(0)/5.0
    grade_order={"A+":1.0,"A":0.9,"B":0.75,"C":0.6}
    x["grade_score"]=x["grade"].map(grade_order).fillna(0.5)
    x["replacement_score"]=0.55*x["same_crop"]+0.15*x["price_similarity"]+0.15*x["rating_score"]+0.15*x["grade_score"]
    x["recommendation_type"]="REPLACEMENT"
    x["reason"]=x.apply(lambda r: "Same crop alternative listing." if r["same_crop"] else "Alternative listing ranked by price, rating and quality.",axis=1)
    return x.sort_values("replacement_score",ascending=False).head(top_n).reset_index(drop=True)
