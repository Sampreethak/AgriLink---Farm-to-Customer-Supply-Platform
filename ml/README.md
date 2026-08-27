# 🤖 AgriLink — ML Recommendation Engine

LightFM collaborative filtering model that powers the "Recommended For You" section in the AgriLink app.

## Structure

```
ml/
├── model/          → LightFM model training, predictor
├── api/            → FastAPI routes serving recommendations
├── features/       → Feature engineering from user interactions
├── evaluation/     → Model accuracy, precision@k, recall@k metrics
├── scripts/        → Training and data pipeline scripts
├── artifacts/      → Saved model weights
├── visualizations/ → Training plots
├── benchmark/      → Model comparison (LightFM vs baselines)
│   ├── compare_models.py
│   ├── model_benchmark_results.xlsx
│   └── customers_dataset.csv
└── AgriLink_ML_Recommendation_Model.ipynb  → Full Jupyter notebook
```

## Setup

```bash
pip install -r requirements.txt
python scripts/train_model.py
```

## How It Works
1. User interactions (views, purchases, reviews) stored in Supabase `user_interactions` table
2. LightFM trains on interaction matrix (users × listings)
3. For any buyer, top-N listing recommendations returned
4. Recommendations update as new interactions come in
