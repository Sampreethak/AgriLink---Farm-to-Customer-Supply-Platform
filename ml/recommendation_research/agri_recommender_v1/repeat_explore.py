import pandas as pd

def split_repeat_explore(recommendations: pd.DataFrame, purchased_crop_ids, top_n=10):
    x = recommendations.copy()
    purchased = set(purchased_crop_ids)
    x["recommendation_mode"] = x["crop_id"].apply(lambda c: "REPEAT" if c in purchased else "EXPLORE")
    repeat = x[x["recommendation_mode"] == "REPEAT"].head(top_n).copy()
    explore = x[x["recommendation_mode"] == "EXPLORE"].head(top_n).copy()
    return repeat, explore
