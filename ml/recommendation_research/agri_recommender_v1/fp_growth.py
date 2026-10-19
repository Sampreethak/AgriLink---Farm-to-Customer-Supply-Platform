import pandas as pd

try:
    from mlxtend.frequent_patterns import fpgrowth, association_rules
except ImportError as e:
    raise ImportError("Install mlxtend: pip install mlxtend") from e


def train_fp_growth(orders: pd.DataFrame, min_support: float = 0.05, min_confidence: float = 0.30):
    """Train FP-Growth on one row per order-item with crop_name."""
    required = {"order_id", "crop_name"}
    missing = required - set(orders.columns)
    if missing:
        raise ValueError(f"Missing columns for FP-Growth: {sorted(missing)}")

    baskets = orders.groupby("order_id")["crop_name"].apply(lambda x: sorted(set(x.dropna()))).tolist()
    baskets = [b for b in baskets if b]
    items = sorted({item for basket in baskets for item in basket})

    matrix = pd.DataFrame(False, index=range(len(baskets)), columns=items, dtype=bool)
    for row, basket in enumerate(baskets):
        matrix.loc[row, basket] = True

    # Some mlxtend/numpy combinations have trouble with string itemsets.
    # Use integer column labels internally and decode after association_rules.
    name_to_id = {name: idx for idx, name in enumerate(items)}
    id_to_name = {idx: name for name, idx in name_to_id.items()}
    numeric_matrix = matrix.rename(columns=name_to_id)

    frequent_numeric = fpgrowth(numeric_matrix, min_support=min_support, use_colnames=True)

    if frequent_numeric.empty:
        rules = pd.DataFrame(columns=["antecedents", "consequents", "support", "confidence", "lift", "score"])
        return frequent_numeric, rules, matrix

    rules = association_rules(frequent_numeric, metric="confidence", min_threshold=min_confidence)

    def decode(values):
        return frozenset(id_to_name[int(v)] for v in values)

    frequent_numeric["itemsets"] = frequent_numeric["itemsets"].apply(decode)

    if rules.empty:
        rules = pd.DataFrame(columns=["antecedents", "consequents", "support", "confidence", "lift", "score"])
    else:
        rules["antecedents"] = rules["antecedents"].apply(decode)
        rules["consequents"] = rules["consequents"].apply(decode)
        rules["score"] = rules["confidence"] * rules["lift"]
        rules = rules.sort_values("score", ascending=False).reset_index(drop=True)

    return frequent_numeric, rules, matrix


def recommend_for_basket(basket, rules: pd.DataFrame, top_n: int = 10) -> pd.DataFrame:
    columns = ["crop_name", "score", "confidence", "lift", "recommendation_type", "reason"]
    if rules.empty:
        return pd.DataFrame(columns=columns)

    basket = set(basket)
    rows = []
    for row in rules.itertuples(index=False):
        antecedents = set(row.antecedents)
        if antecedents.issubset(basket):
            for item in row.consequents:
                if item not in basket:
                    rows.append({
                        "crop_name": item,
                        "score": float(row.score),
                        "confidence": float(row.confidence),
                        "lift": float(row.lift),
                        "recommendation_type": "ASSOCIATION",
                        "reason": f"Frequently associated with {', '.join(sorted(antecedents))}."
                    })
    if not rows:
        return pd.DataFrame(columns=columns)
    return (pd.DataFrame(rows)
            .sort_values("score", ascending=False)
            .drop_duplicates("crop_name")
            .head(top_n)
            .reset_index(drop=True))
