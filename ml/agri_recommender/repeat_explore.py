import pandas as pd

def split_repeat_explore(hybrid_recommendations: pd.DataFrame, repeat_ratio=0.7):
    """Split hybrid recommendations into Repeat (Buy Again) and Explore (CF/FP-Growth/New) items."""
    if hybrid_recommendations.empty:
        return hybrid_recommendations, hybrid_recommendations

    repeat = hybrid_recommendations[hybrid_recommendations["recommendation_type"] == "BUY_AGAIN"].copy()
    explore = hybrid_recommendations[hybrid_recommendations["recommendation_type"] != "BUY_AGAIN"].copy()
    return repeat, explore
