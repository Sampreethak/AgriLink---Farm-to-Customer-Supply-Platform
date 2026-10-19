import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from agri_recommender.config import DATA_DIR
from agri_recommender.data_loader import build_purchase_data
from agri_recommender.buy_again import generate_buy_again

purchase=build_purchase_data(DATA_DIR)
customer_id=purchase["customer_id"].iloc[0]
print("Customer:",customer_id)
print(generate_buy_again(purchase,customer_id=customer_id,top_n=10))
