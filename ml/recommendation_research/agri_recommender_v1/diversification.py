import pandas as pd

def diversify_recommendations(recommendations: pd.DataFrame, top_n=10, max_per_category=3):
    if recommendations.empty:
        return recommendations.copy()
    if "category_id" not in recommendations.columns:
        return recommendations.head(top_n).copy()
    selected=[]; counts={}
    for _, row in recommendations.sort_values("final_score" if "final_score" in recommendations.columns else "score", ascending=False).iterrows():
        cat=row.get("category_id")
        if counts.get(cat,0) >= max_per_category:
            continue
        selected.append(row)
        counts[cat]=counts.get(cat,0)+1
        if len(selected)>=top_n: break
    return pd.DataFrame(selected).reset_index(drop=True)
