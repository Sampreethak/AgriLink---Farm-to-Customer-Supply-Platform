"""
AgriLink Recommendation Engine — 9-Model Customer, Farmer & Aggregator System

Customer Models:
  1. Buy Again (Recency + Frequency + Quantity)
  2. FP-Growth Market Basket Association
  3. User-Based Collaborative Filtering
  4. Next-Basket (NBR frequency baseline)
  5. Recency-Weighted (time-decay scoring)
  6. Price-Aware (budget-fit + popularity)
  7. Local Popularity (region-based trending)
  8. Replacement (out-of-stock alternatives)
  9. Hybrid (1+2+3 combined)

Farmer Model: Demand-supply gap + APMC price prediction
Aggregator Model: Bulk supplier matching
"""
__version__ = "3.0.0"
