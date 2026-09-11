import os
import sys
import numpy as np
import pandas as pd
import joblib
from datetime import datetime
from collections import defaultdict, Counter
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.decomposition import TruncatedSVD

def train_and_save():
    print("=== Training AgriLink Multi-Model Customer Recommendation Engine ===")
    
    # 1. Load data from Excel
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    repo_dir = os.path.dirname(base_dir)
    excel_path = os.path.join(repo_dir, "database", "AgriLink_Dummy_Database.xlsx")
    
    if not os.path.exists(excel_path):
        print(f"Error: Database file not found at {excel_path}")
        sys.exit(1)
        
    print(f"Reading dataset from: {excel_path}")
    xls = pd.ExcelFile(excel_path)
    
    users_df = pd.read_excel(xls, sheet_name='app_user')
    customers_df = pd.read_excel(xls, sheet_name='customer_profile')
    locations_df = pd.read_excel(xls, sheet_name='location')
    crops_df = pd.read_excel(xls, sheet_name='crop')
    inventory_df = pd.read_excel(xls, sheet_name='inventory_item')
    listings_df = pd.read_excel(xls, sheet_name='seller_listing')
    orders_df = pd.read_excel(xls, sheet_name='customer_order')
    order_items_df = pd.read_excel(xls, sheet_name='order_item')
    interactions_df = pd.read_excel(xls, sheet_name='user_interaction')
    
    # Merge listing with inventory & crop details
    full_listings = listings_df.merge(inventory_df, on='inventory_id', how='left')
    full_listings = full_listings.merge(crops_df, on='crop_id', how='left')
    
    print(f"Loaded {len(customers_df)} Customers, {len(crops_df)} Crops, {len(full_listings)} Listings, {len(orders_df)} Orders, {len(order_items_df)} Order Items.")
    
    # Pre-build lookup maps
    listing_lookup = {}
    for _, row in full_listings.iterrows():
        listing_lookup[row['listing_id']] = {
            "listing_id": row['listing_id'],
            "crop_id": row['crop_id'],
            "crop_name": row['crop_name'],
            "title": row['title'],
            "unit": row['unit'],
            "price_per_unit": float(row['price_per_unit']),
            "is_organic": bool(row['is_organic']),
            "rating_avg": float(row['rating_avg']),
            "rating_count": int(row['rating_count']),
            "grade": str(row['grade'])
        }
        
    # Crop to best representative listing
    crop_to_best_listing = {}
    for crop_name in crops_df['crop_name'].unique():
        matching = [l for l in listing_lookup.values() if l['crop_name'] == crop_name]
        if matching:
            best = max(matching, key=lambda x: (x['rating_avg'], -x['price_per_unit']))
            crop_to_best_listing[crop_name] = best

    # ============================================================
    # MODEL 1: BUY AGAIN (Frequency + Recency Scoring)
    # ============================================================
    print("\n--- Training Model 1: Buy Again (Frequency & Recency) ---")
    # Merge orders with items and listings
    merged_orders = order_items_df.merge(orders_df, on='order_id', how='left')
    merged_orders = merged_orders.merge(full_listings[['listing_id', 'crop_name', 'unit', 'price_per_unit', 'is_organic', 'rating_avg']], on='listing_id', how='left')
    
    # Group by customer_id + crop_name
    buy_again_stats = defaultdict(lambda: defaultdict(lambda: {"count": 0, "total_qty": 0.0, "last_order": ""}))
    
    for _, row in merged_orders.iterrows():
        c_id = str(row['customer_id'])
        crop = str(row['crop_name'])
        buy_again_stats[c_id][crop]["count"] += 1
        buy_again_stats[c_id][crop]["total_qty"] += float(row['quantity'])
        
    print(f"Buy Again profile constructed for {len(buy_again_stats)} customers.")

    # ============================================================
    # MODEL 2: YOU MAY ALSO WANT (FP-Growth / Association Rules on Baskets)
    # ============================================================
    print("\n--- Training Model 2: You May Also Want (Co-Purchase Association Rules) ---")
    # Group orders into baskets of crop names
    order_baskets = defaultdict(set)
    for _, row in merged_orders.iterrows():
        o_id = str(row['order_id'])
        c_name = str(row['crop_name'])
        order_baskets[o_id].add(c_name)
        
    basket_list = [list(b) for b in order_baskets.values() if len(b) >= 2]
    print(f"Extracted {len(basket_list)} multi-item baskets for Association Rule Mining.")
    
    # Calculate Co-occurrence / Association Rules
    pair_counts = Counter()
    item_counts = Counter()
    num_baskets = len(basket_list)
    
    for basket in basket_list:
        for item in basket:
            item_counts[item] += 1
        for i in range(len(basket)):
            for j in range(len(basket)):
                if i != j:
                    pair_counts[(basket[i], basket[j])] += 1
                    
    # Generate Association Rules: Antecedent -> Consequent with Confidence & Lift
    association_rules = []
    for (ant, con), pair_c in pair_counts.items():
        support = pair_c / num_baskets
        confidence = pair_c / item_counts[ant]
        con_support = item_counts[con] / num_baskets
        lift = confidence / (con_support + 1e-9)
        
        if support >= 0.05 and confidence >= 0.25:
            association_rules.append({
                "antecedent": ant,
                "consequent": con,
                "support": round(support, 4),
                "confidence": round(confidence, 4),
                "lift": round(lift, 4)
            })
            
    association_rules = sorted(association_rules, key=lambda x: (x["confidence"], x["lift"]), reverse=True)
    print(f"Discovered {len(association_rules)} high-confidence association rules.")
    print("Top 5 Learned Association Rules:")
    for r in association_rules[:5]:
        print(f"  - {r['antecedent']} -> {r['consequent']} | Conf: {r['confidence']*100:.1f}%, Lift: {r['lift']:.2f}")

    # ============================================================
    # MODEL 3: PICKED FOR YOU (User-Based Collaborative Filtering on Customer x Crop Matrix)
    # ============================================================
    print("\n--- Training Model 3: Picked For You (User-Based Collaborative Filtering) ---")
    all_customer_ids = sorted(customers_df['customer_id'].astype(str).unique().tolist())
    all_crops = sorted(crops_df['crop_name'].unique().tolist())
    
    cust2idx = {c_id: idx for idx, c_id in enumerate(all_customer_ids)}
    idx2cust = {idx: c_id for c_id, idx in cust2idx.items()}
    crop2idx = {c_name: idx for idx, c_name in enumerate(all_crops)}
    idx2crop = {idx: c_name for c_name, idx in crop2idx.items()}
    
    # Customer x Crop matrix
    customer_crop_matrix = np.zeros((len(all_customer_ids), len(all_crops)), dtype=np.float32)
    
    for c_id, crops_dict in buy_again_stats.items():
        if c_id in cust2idx:
            u_idx = cust2idx[c_id]
            for crop_name, stats in crops_dict.items():
                if crop_name in crop2idx:
                    c_idx = crop2idx[crop_name]
                    # Weight = purchase count * 2.0
                    customer_crop_matrix[u_idx, c_idx] += stats["count"] * 2.0
                    
    # Also add user interactions (views, cart adds)
    for _, row in interactions_df.iterrows():
        c_id = str(row['customer_id'])
        l_id = str(row['listing_id'])
        if c_id in cust2idx and l_id in listing_lookup:
            u_idx = cust2idx[c_id]
            crop_name = listing_lookup[l_id]['crop_name']
            if crop_name in crop2idx:
                c_idx = crop2idx[crop_name]
                customer_crop_matrix[u_idx, c_idx] += 1.0
                
    # Compute Cosine Similarity between all Customers
    customer_sim_matrix = cosine_similarity(customer_crop_matrix)
    print(f"Customer x Crop Matrix: {customer_crop_matrix.shape}. Cosine Similarity computed.")

    # Matrix Factorization for dense latent representations
    n_comp = min(8, len(all_crops) - 1)
    svd = TruncatedSVD(n_components=n_comp, random_state=42)
    user_factors = svd.fit_transform(customer_crop_matrix)
    item_factors = svd.components_.T
    svd_scores = np.dot(user_factors, item_factors.T)

    # ============================================================
    # 5. SAVE ALL MULTI-MODEL ARTIFACTS
    # ============================================================
    artifacts_dir = os.path.join(base_dir, "artifacts")
    os.makedirs(artifacts_dir, exist_ok=True)
    artifacts_file = os.path.join(artifacts_dir, "recommendation_engine.joblib")
    
    # Convert nested defaultdict to clean serializable dict
    clean_buy_again = {}
    for c_id, c_data in buy_again_stats.items():
        clean_buy_again[c_id] = {crop: dict(stats) for crop, stats in c_data.items()}
        
    # Save Notebook-compatible CSVs & PKLs
    cust_rec_dir = os.path.join(repo_dir, "Customer Recommendation")
    os.makedirs(cust_rec_dir, exist_ok=True)
    
    rules_df = pd.DataFrame(association_rules)
    rules_df.to_csv(os.path.join(cust_rec_dir, "fp_growth_association_rules.csv"), index=False)
    
    # Buy Again DataFrame
    buy_again_records = []
    for c_id, c_map in buy_again_stats.items():
        for crop_name, stat in c_map.items():
            best_list = crop_to_best_listing.get(crop_name, {})
            buy_again_records.append({
                "customer_id": c_id,
                "listing_id": best_list.get("listing_id", ""),
                "crop_id": best_list.get("crop_id", ""),
                "crop_name": crop_name,
                "purchase_count": stat["count"],
                "total_quantity": stat["total_qty"],
                "recommendation_type": "BUY_AGAIN"
            })
    buy_again_df = pd.DataFrame(buy_again_records)
    buy_again_df.to_csv(os.path.join(cust_rec_dir, "buy_again_recommendations.csv"), index=False)
    
    # Collaborative Matrices
    pd.DataFrame(customer_sim_matrix, index=all_customer_ids, columns=all_customer_ids).to_csv(os.path.join(cust_rec_dir, "collaborative_similarity_matrix.csv"))
    pd.DataFrame(customer_crop_matrix, index=all_customer_ids, columns=all_crops).to_csv(os.path.join(cust_rec_dir, "collaborative_customer_item_matrix.csv"))
    
    # Save buy_again_model.pkl
    buy_again_artifact = {
        "recommendations": buy_again_df,
        "feature_table": clean_buy_again,
        "generated_at": datetime.now().isoformat()
    }
    joblib.dump(buy_again_artifact, os.path.join(cust_rec_dir, "buy_again_model.pkl"))
    
    model_payload = {
        "buy_again_stats": clean_buy_again,
        "association_rules": association_rules,
        "customer_crop_matrix": customer_crop_matrix,
        "customer_sim_matrix": customer_sim_matrix,
        "svd_scores": svd_scores,
        "cust2idx": cust2idx,
        "idx2cust": idx2cust,
        "crop2idx": crop2idx,
        "idx2crop": idx2crop,
        "crop_to_best_listing": crop_to_best_listing,
        "listing_lookup": listing_lookup,
        "all_crops": all_crops,
        "customer_profiles": customers_df.to_dict(orient='records'),
        "trained_at": datetime.now().isoformat()
    }
    
    joblib.dump(model_payload, artifacts_file)
    print(f"\n[SUCCESS] Master Recommendation Engine saved to:\n  -> {artifacts_file}")
    print(f"[SUCCESS] Standalone artifacts saved to:\n  -> {cust_rec_dir}")

if __name__ == "__main__":
    train_and_save()
