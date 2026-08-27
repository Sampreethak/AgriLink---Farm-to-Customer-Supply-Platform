import os
import sys
import numpy as np
import pandas as pd
import joblib
from scipy.sparse import csr_matrix
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.decomposition import TruncatedSVD

def train_and_save():
    print("=== AgriLink ML Recommendation Engine Training Pipeline ===")
    
    # 1. Locate dataset
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    excel_path = os.path.join(os.path.dirname(base_dir), "agrilink-database", "AgriLink_Dummy_Database.xlsx")
    
    if not os.path.exists(excel_path):
        print(f"Error: Database file not found at {excel_path}")
        sys.exit(1)
        
    print(f"Reading dataset from: {excel_path}")
    users_df = pd.read_excel(excel_path, sheet_name='Users')
    listings_df = pd.read_excel(excel_path, sheet_name='Crop_Listings')
    interactions_df = pd.read_excel(excel_path, sheet_name='User_Interactions')
    
    print(f"Loaded {len(users_df)} Users, {len(listings_df)} Crop Listings, {len(interactions_df)} Interaction Events.")
    
    # 2. Build User-Item Interaction Matrix
    unique_users = sorted(interactions_df['buyer_id'].unique().tolist())
    unique_listings = sorted(listings_df['listing_id'].unique().tolist())
    
    user2idx = {user_id: idx for idx, user_id in enumerate(unique_users)}
    idx2user = {idx: user_id for user_id, idx in user2idx.items()}
    item2idx = {item_id: idx for idx, item_id in enumerate(unique_listings)}
    idx2item = {idx: item_id for item_id, idx in item2idx.items()}
    
    interaction_matrix = np.zeros((len(unique_users), len(unique_listings)), dtype=np.float32)
    
    for _, row in interactions_df.iterrows():
        u_idx = user2idx[row['buyer_id']]
        i_idx = item2idx[row['listing_id']]
        weight = float(row['interaction_weight'])
        interaction_matrix[u_idx, i_idx] += weight
        
    sparse_interaction = csr_matrix(interaction_matrix)
    print(f"Interaction matrix constructed with shape: {sparse_interaction.shape}")
    
    # 3. TF-IDF Item Content Features
    listings_df['content_text'] = (
        listings_df['crop_name'].astype(str) + ' ' +
        listings_df['category'].astype(str) + ' ' +
        listings_df['location'].astype(str) + ' ' +
        np.where(listings_df['is_organic'], 'Organic', 'Conventional')
    )
    vectorizer = TfidfVectorizer(stop_words='english')
    item_feature_matrix = vectorizer.fit_transform(listings_df['content_text'])
    
    # 4. Matrix Factorization (SVD)
    n_components = min(4, sparse_interaction.shape[1] - 1)
    svd = TruncatedSVD(n_components=n_components, random_state=42)
    user_factors = svd.fit_transform(sparse_interaction)
    item_factors = svd.components_.T
    
    collaborative_scores = np.dot(user_factors, item_factors.T)
    content_scores = cosine_similarity(item_feature_matrix)
    
    print("Hybrid matrix factorization and TF-IDF feature training completed successfully.")
    
    # 5. Save Artifacts
    artifacts_dir = os.path.join(base_dir, "artifacts")
    os.makedirs(artifacts_dir, exist_ok=True)
    
    joblib.dump(svd, os.path.join(artifacts_dir, "lightfm_model.joblib"))
    joblib.dump(vectorizer, os.path.join(artifacts_dir, "item_features.joblib"))
    joblib.dump({
        'user2idx': user2idx,
        'idx2user': idx2user,
        'item2idx': item2idx,
        'idx2item': idx2item,
        'user_factors': user_factors,
        'item_factors': item_factors,
        'collaborative_scores': collaborative_scores,
        'interaction_matrix': interaction_matrix,
        'listings': listings_df.to_dict(orient='records')
    }, os.path.join(artifacts_dir, "id_mappings.joblib"))
    
    print(f"Model artifacts successfully written to: {artifacts_dir}")

if __name__ == "__main__":
    train_and_save()
