"""
Notebook 01: Next-Basket Recommendation (NBR)
Frequency-baseline with chronological held-out basket evaluation.
See ml/agri_recommender/next_basket.py for the production module.
This notebook demonstrates the algorithm standalone with synthetic data.
"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..'))

try:
    from recommendation_research.data.load_sample import load_sample_data
except ImportError:
    pass

import pandas as pd
import numpy as np
from collections import Counter

USE_CSV = True
DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'data')

def load_purchase_data():
    if USE_CSV:
        orders_path = os.path.join(DATA_DIR, 'customer_order_rows.csv')
        items_path  = os.path.join(DATA_DIR, 'order_item_rows.csv')
        crop_path   = os.path.join(DATA_DIR, 'crop_rows.csv')
        orders = pd.read_csv(orders_path) if os.path.exists(orders_path) else pd.DataFrame()
        items  = pd.read_csv(items_path)  if os.path.exists(items_path)  else pd.DataFrame()
        crops  = pd.read_csv(crop_path)   if os.path.exists(crop_path)   else pd.DataFrame()
        if not orders.empty and not items.empty:
            merged = items.merge(orders, on='order_id', how='left')
            if not crops.empty and 'crop_id' in merged.columns:
                merged = merged.merge(crops[['id','name']].rename(columns={'id':'crop_id','name':'crop_name'}), on='crop_id', how='left')
            return merged
    # Synthetic fallback
    np.random.seed(42)
    customers = [f'cust-{i:03d}' for i in range(50)]
    crops = ['Tomato','Onion','Potato','Carrot','Rice','Wheat','Spinach','Mango','Banana','Garlic']
    rows = []
    for c in customers:
        for order_num in range(np.random.randint(3, 10)):
            oid = f'ord-{c}-{order_num}'
            basket_size = np.random.randint(1, 5)
            basket = np.random.choice(crops, basket_size, replace=False)
            for crop in basket:
                rows.append({'customer_id': c, 'order_id': oid, 'crop_name': crop,
                             'quantity': np.random.uniform(1, 10),
                             'created_at': pd.Timestamp.now(tz='UTC') - pd.Timedelta(days=np.random.randint(0, 180))})
    return pd.DataFrame(rows)

def build_basket_sequences(df, customer_id):
    cdf = df[df['customer_id'] == customer_id].copy()
    if cdf.empty: return []
    cdf = cdf.sort_values('created_at') if 'created_at' in cdf.columns else cdf
    baskets = []
    for oid, grp in cdf.groupby('order_id'):
        crops = set(grp['crop_name'].dropna())
        if crops: baskets.append(crops)
    return baskets

def evaluate_nbr(df, held_out_ratio=0.2):
    customers = df['customer_id'].unique()
    hits, total = 0, 0
    for c in customers[:20]:
        seqs = build_basket_sequences(df, c)
        if len(seqs) < 3: continue
        split = max(1, int(len(seqs) * (1 - held_out_ratio)))
        train_seqs = seqs[:split]
        test_basket = seqs[split] if split < len(seqs) else set()
        co_occ = Counter()
        for i in range(len(train_seqs) - 1):
            for item in train_seqs[i+1]:
                co_occ[item] += 1
        predicted = {item for item, _ in co_occ.most_common(3)}
        if predicted & test_basket:
            hits += 1
        total += 1
    recall = hits / max(total, 1)
    print(f'NBR Evaluation: {hits}/{total} customers hit | Recall@3 = {recall:.2%}')
    return recall

if __name__ == '__main__':
    print('=== Next-Basket Recommendation (NBR) — Notebook 01 ===')
    df = load_purchase_data()
    print(f'Loaded {len(df)} purchase records, {df["customer_id"].nunique()} customers')
    recall = evaluate_nbr(df)
    sample_cust = df['customer_id'].iloc[0]
    seqs = build_basket_sequences(df, sample_cust)
    print(f'Sample customer {sample_cust}: {len(seqs)} baskets')
    for i, b in enumerate(seqs[-3:]):
        print(f'  Basket {i+1}: {sorted(b)}')
