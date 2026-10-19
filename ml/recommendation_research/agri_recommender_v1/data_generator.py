"""Optional synthetic-data generator kept only for experiments.
The production/demo notebooks use the real CSV files in ../data.
"""
import random
import pandas as pd

CROPS=["Apple","Banana","Beans","Brinjal","Cabbage","Carrot","Coriander","Cucumber","Green Chilli","Onion","Orange","Papaya","Potato","Rice","Tomato"]

def generate_orders(n_orders=1000, seed=42):
    random.seed(seed)
    rows=[]
    for order_id in range(1,n_orders+1):
        basket=random.sample(CROPS,k=random.randint(2,5))
        for crop in basket:
            rows.append({"order_id":order_id,"crop_name":crop})
    return pd.DataFrame(rows)
