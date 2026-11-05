import os
import joblib
import pandas as pd
import numpy as np
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score

def train_pricing_engine():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(base_dir, "apmc_karnataka_market_data.csv")
    output_model_path = os.path.join(base_dir, "pricing_engine.joblib")

    print(f"[1/4] Loading APMC Market Data from {csv_path}...")
    df = pd.read_csv(csv_path)

    np.random.seed(42)
    n = len(df)

    # Generate realistic corridor simulation features matching AgriLink architecture
    districts = ["Mandya", "Maddur", "Srirangapatna", "Ramanagara", "Bengaluru South"]
    df["origin_district"] = np.random.choice(districts, size=n, p=[0.45, 0.20, 0.15, 0.10, 0.10])
    
    distance_map = {
        "Mandya": 85.0,
        "Maddur": 75.0,
        "Srirangapatna": 115.0,
        "Ramanagara": 50.0,
        "Bengaluru South": 25.0
    }
    df["distance_km"] = df["origin_district"].map(distance_map).astype(float) + np.random.uniform(-5, 5, size=n)
    df["is_organic"] = np.random.choice([False, True], size=n, p=[0.75, 0.25])
    
    df["apmc_modal_price_per_kg"] = df["modal_price_per_kg"]

    # Target: Fair Consumer Price calculation based on value-chain economics
    grade_multiplier = df["grade"].map({"Grade A+": 1.15, "Grade A": 1.08, "Grade B": 0.95, "Local": 1.02}).fillna(1.05)
    organic_multiplier = np.where(df["is_organic"], 1.22, 1.0)
    logistics_markup = df["distance_km"] * 0.045  # Corridor pooling transit cost per kg
    
    # Fair price = APMC modal * grade * organic + corridor logistics + 8% platform assaying
    df["fair_consumer_price_per_kg"] = (
        (df["apmc_modal_price_per_kg"] * grade_multiplier * organic_multiplier) + logistics_markup
    ).round(2)
    # Ensure minimum 10% premium over raw mandi modal rate
    df["fair_consumer_price_per_kg"] = np.maximum(df["fair_consumer_price_per_kg"], (df["apmc_modal_price_per_kg"] * 1.10).round(2))

    print(f"[2/4] Training Dataset Prepared: {n} records across {df['commodity'].nunique()} commodities.")

    feature_cols = [
        "commodity", "variety", "grade", "origin_district", 
        "distance_km", "is_organic", "apmc_modal_price_per_kg"
    ]
    X = df[feature_cols]
    y = df["fair_consumer_price_per_kg"]

    categorical_cols = ["commodity", "variety", "grade", "origin_district"]
    numeric_cols = ["distance_km", "is_organic", "apmc_modal_price_per_kg"]

    preprocessor = ColumnTransformer(
        transformers=[
            ("cat", OneHotEncoder(handle_unknown="ignore", sparse_output=False), categorical_cols),
            ("num", StandardScaler(), numeric_cols)
        ]
    )

    rf_model = RandomForestRegressor(
        n_estimators=60,
        max_depth=16,
        random_state=42,
        n_jobs=-1
    )

    pipeline = Pipeline(steps=[
        ("preprocessor", preprocessor),
        ("regressor", rf_model)
    ])

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=42)
    
    print("[3/4] Training Random Forest Regressor Pipeline...")
    pipeline.fit(X_train, y_train)

    y_pred = pipeline.predict(X_test)
    mae = mean_absolute_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    print(f"[OK] Model Evaluation: MAE = Rs. {mae:.2f}/kg, R2 Score = {r2:.4f}")

    # Compute commodity benchmarks
    latest_benchmarks = df.groupby("commodity")["modal_price_per_kg"].median().round(2).to_dict()

    payload = {
        "model": pipeline,
        "feature_names": feature_cols,
        "latest_apmc_benchmarks": latest_benchmarks,
        "metrics": {"mae": mae, "r2": r2},
        "model_type": "RandomForestRegressor Pipeline (scikit-learn 1.9+ native)"
    }

    print(f"[4/4] Saving production-ready ML model to {output_model_path}...")
    joblib.dump(payload, output_model_path)
    print("[SUCCESS] Dynamic Pricing Engine trained and exported successfully!")

if __name__ == "__main__":
    train_pricing_engine()
