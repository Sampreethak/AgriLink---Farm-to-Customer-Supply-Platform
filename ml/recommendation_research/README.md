# AgriLink Recommendation Research

This folder consolidates **all recommendation research** for the AgriLink platform into a single canonical location.

## Folder Structure

```
recommendation_research/
├── notebooks_original/        # Original Jupyter notebooks (Customer Recommendation)
│   ├── buy_again_recommender.ipynb
│   ├── collaborative_filtering.ipynb
│   ├── fp_growth.ipynb
│   ├── buy_again_model.pkl
│   ├── buy_again_recommendations.csv
│   ├── collaborative_customer_item_matrix.csv
│   ├── collaborative_similarity_matrix.csv
│   └── fp_growth_association_rules.csv
│
├── notebooks_extended/        # 4 advanced recommendation notebooks (formerly missing)
│   ├── 01_next_basket_recommendation.py   — NBR frequency baseline
│   ├── 02_recency_weighted.py             — Time-decay scoring
│   ├── 03_price_aware.py                  — Price-fit + popularity heuristic
│   └── 04_local_popularity.py             — Region-based popularity ranking
│
├── agri_recommender_v1/       # Prototype v1 modules (AgriLink_Recommendation_Code)
│   ├── buy_again.py, collaborative_filtering.py, fp_growth.py
│   ├── customer_hybrid.py, replacement.py, ranking.py, repeat_explore.py
│   ├── farmer_recommendation.py, aggregator_matching.py
│   └── data_loader.py, config.py, diversification.py
│
├── data/                      # Synthetic CSV dataset (18 tables)
│   ├── customer_order_rows.csv, order_item_rows.csv
│   ├── seller_listing_rows.csv, inventory_item_rows.csv
│   ├── crop_rows.csv, crop_category_rows.csv
│   ├── user_interaction_rows.csv, customer_review_rows.csv
│   ├── customer_profile_rows.csv, farmer_profile_rows.csv
│   └── ... (18 total CSV files)
│
└── scripts_v1/                # Demo run scripts for v1 modules
    ├── 01_buy_again.py, 02_fp_growth.py, 03_collaborative_filtering.py
    ├── 04_replacement.py, 05_hybrid.py, 06_farmer.py
    ├── 07_aggregator.py, 08_repeat_explore.py
    └── run_demo.py
```

## Active Production Engine

The **production recommendation engine** lives in `ml/agri_recommender/` (parent directory) and is wired to:
- `backend_fastapi/main.py` — FastAPI REST API (all `/api/v1/recommendations/*` routes)
- `frontend_web/` — Customer dashboard recommendation UI
- `mobile_app/` — Flutter customer recommendation screens

## 9 Recommendation Approaches

| # | Name | Module | Customer Endpoint |
|---|------|--------|-------------------|
| 1 | Buy Again (Recency+Freq+Qty) | `agri_recommender/buy_again.py` | `/api/v1/recommendations/buy-again/{id}` |
| 2 | FP-Growth Market Basket | `agri_recommender/fp_growth.py` | `/api/v1/recommendations/you-may-also-want/{id}` |
| 3 | User-Based Collaborative Filtering | `agri_recommender/collaborative_filtering.py` | `/api/v1/recommendations/picked-for-you/{id}` |
| 4 | Replacement / Out-of-Stock | `agri_recommender/replacement.py` | `/api/v1/recommendations/replacement/{listing_id}` |
| 5 | Next-Basket (NBR) | `agri_recommender/next_basket.py` | `/api/v1/recommendations/next-basket/{id}` |
| 6 | Recency-Weighted | `agri_recommender/recency_weighted.py` | `/api/v1/recommendations/recency-weighted/{id}` |
| 7 | Price-Aware | `agri_recommender/price_aware.py` | `/api/v1/recommendations/price-aware/{id}` |
| 8 | Local Popularity | `agri_recommender/local_popularity.py` | `/api/v1/recommendations/local-popularity` |
| 9 | Hybrid (1+2+3 combined) | `agri_recommender/customer_hybrid.py` | `/api/v1/recommendations/customer-home/{id}` |

## Notes on Synthetic Data

- **Data is synthetic** and generated for testing purposes only.
- Column naming: some files use `_rows.csv` suffix (AgriLink convention), others use plain names.
- `ml/agri_recommender/data_loader.py` handles both naming conventions automatically.
- For production, connect to the live Supabase PostgreSQL database.
