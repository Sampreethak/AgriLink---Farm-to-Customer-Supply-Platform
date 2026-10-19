import pandas as pd

def recommend_supplier_listings(crop_name, required_quantity, catalog, top_n=10):
    """Rank available farmer listings for an aggregator demand requirement."""
    x=catalog[catalog["crop_name"].astype(str).str.lower()==str(crop_name).lower()].copy()
    x=x[x["status"].astype(str).str.upper().eq("AVAILABLE")].copy()
    if x.empty: return x
    x["quantity_fit"]=(pd.to_numeric(x["quantity"],errors="coerce").fillna(0)/max(float(required_quantity),1)).clip(upper=1)
    x["price_score"]=1-(pd.to_numeric(x["price_per_unit"],errors="coerce").fillna(0)-pd.to_numeric(x["price_per_unit"],errors="coerce").min())/(pd.to_numeric(x["price_per_unit"],errors="coerce").max()-pd.to_numeric(x["price_per_unit"],errors="coerce").min()+1e-9)
    grade_score={"A+":1.0,"A":0.9,"B":0.75,"C":0.6}
    x["quality_score"]=x["grade"].map(grade_score).fillna(0.5)
    x["rating_score"]=pd.to_numeric(x["rating_avg"],errors="coerce").fillna(0)/5
    x["match_score"]=0.35*x["quantity_fit"]+0.25*x["quality_score"]+0.20*x["price_score"]+0.20*x["rating_score"]
    x["recommendation_type"]="AGGREGATOR_SUPPLIER"
    x["reason"]="Ranked by quantity fit, quality, price and listing rating."
    return x.sort_values("match_score",ascending=False).head(top_n).reset_index(drop=True)
