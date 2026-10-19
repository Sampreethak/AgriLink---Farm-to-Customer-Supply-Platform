import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))

from agri_recommender.config import DATA_DIR
from agri_recommender.data_loader import build_purchase_data
from agri_recommender.fp_growth import train_fp_growth, recommend_for_basket

purchase=build_purchase_data(DATA_DIR)
print("Data loaded:",len(purchase),"order items")
frequent,rules,basket_matrix=train_fp_growth(purchase,min_support=0.05,min_confidence=0.30)
print("\nFrequent itemsets:")
print(frequent[["support","itemsets"]].head(20))
print("\nRules:")
if rules.empty:
    print("No association rules found.")
else:
    print(rules[["antecedents","consequents","support","confidence","lift","score"]].head(20))
print("\nBasket recommendations for [Tomato, Onion]:")
print(recommend_for_basket(["Tomato","Onion"],rules))
