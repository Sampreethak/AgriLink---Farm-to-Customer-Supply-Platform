import pandas as pd
import os

print("Generating AgriLink Excel Dummy Database...")

output_path = os.path.join(os.path.dirname(__file__), "AgriLink_Dummy_Database.xlsx")

# 1. Users / Profiles Sheet
users_df = pd.DataFrame([
    {
        "user_id": "11111111-1111-1111-1111-111111111111",
        "full_name": "Ramesh Kumar (Farmer)",
        "email": "ramesh.farmer@agrilink.com",
        "phone": "+919876543210",
        "user_role": "FARMER",
        "location": "Nashik, Maharashtra",
        "latitude": 20.0059,
        "longitude": 73.7898
    },
    {
        "user_id": "22222222-2222-2222-2222-222222222222",
        "full_name": "Suresh Patel (Farmer)",
        "email": "suresh.farmer@agrilink.com",
        "phone": "+919876543211",
        "user_role": "FARMER",
        "location": "Anand, Gujarat",
        "latitude": 22.5645,
        "longitude": 72.9289
    },
    {
        "user_id": "33333333-3333-3333-3333-333333333333",
        "full_name": "Anita Sharma (Organic Farm)",
        "email": "anita.farmer@agrilink.com",
        "phone": "+919876543212",
        "user_role": "FARMER",
        "location": "Shimla, Himachal Pradesh",
        "latitude": 31.1048,
        "longitude": 77.1734
    },
    {
        "user_id": "44444444-4444-4444-4444-444444444444",
        "full_name": "Vikram Singh (Farmer)",
        "email": "vikram.farmer@agrilink.com",
        "phone": "+919876543213",
        "user_role": "FARMER",
        "location": "Ludhiana, Punjab",
        "latitude": 30.9010,
        "longitude": 75.8573
    },
    {
        "user_id": "55555555-5555-5555-5555-555555555555",
        "full_name": "Priya Verma (Buyer)",
        "email": "priya.buyer@agrilink.com",
        "phone": "+919811122233",
        "user_role": "BUYER",
        "location": "Mumbai, Maharashtra",
        "latitude": 19.0760,
        "longitude": 72.8777
    },
    {
        "user_id": "66666666-6666-6666-6666-666666666666",
        "full_name": "Amit Roy (Hotel Chain Buyer)",
        "email": "amit.buyer@agrilink.com",
        "phone": "+919811122234",
        "user_role": "BUYER",
        "location": "Pune, Maharashtra",
        "latitude": 18.5204,
        "longitude": 73.8567
    },
    {
        "user_id": "77777777-7777-7777-7777-777777777777",
        "full_name": "Sneha Kapoor (Retail Buyer)",
        "email": "sneha.buyer@agrilink.com",
        "phone": "+919811122235",
        "user_role": "BUYER",
        "location": "Delhi NCR",
        "latitude": 28.7041,
        "longitude": 77.1025
    },
    {
        "user_id": "88888888-8888-8888-8888-888888888888",
        "full_name": "Rajesh Joshi (Wholesaler)",
        "email": "rajesh.buyer@agrilink.com",
        "phone": "+919811122236",
        "user_role": "BUYER",
        "location": "Ahmedabad, Gujarat",
        "latitude": 23.0225,
        "longitude": 72.5714
    }
])

# 2. Categories Sheet
categories_df = pd.DataFrame([
    {"category_id": 1, "name": "Vegetables", "description": "Fresh organic and farm-direct vegetables"},
    {"category_id": 2, "name": "Fruits", "description": "Fresh seasonal orchard fruits"},
    {"category_id": 3, "name": "Grains & Pulses", "description": "High quality wheat, rice, and pulses"},
    {"category_id": 4, "name": "Spices & Herbs", "description": "Aromatic spices and fresh herbs"},
    {"category_id": 5, "name": "Dairy & Honey", "description": "Pure farm milk, ghee, and natural honey"}
])

# 3. Crop Listings Sheet
listings_df = pd.DataFrame([
    {
        "listing_id": 101,
        "farmer_name": "Ramesh Kumar",
        "title": "Fresh Red Tomatoes (Nashik Special)",
        "crop_name": "Tomato",
        "category": "Vegetables",
        "price_per_unit": 28.00,
        "unit": "kg",
        "available_quantity": 1500,
        "is_organic": True,
        "grade": "A+",
        "location": "Nashik, Maharashtra",
        "rating_avg": 4.8,
        "rating_count": 42
    },
    {
        "listing_id": 102,
        "farmer_name": "Ramesh Kumar",
        "title": "Organic Red Onions",
        "crop_name": "Onion",
        "category": "Vegetables",
        "price_per_unit": 22.50,
        "unit": "kg",
        "available_quantity": 3000,
        "is_organic": True,
        "grade": "A",
        "location": "Nashik, Maharashtra",
        "rating_avg": 4.6,
        "rating_count": 28
    },
    {
        "listing_id": 103,
        "farmer_name": "Suresh Patel",
        "title": "Premium Sharbati Wheat",
        "crop_name": "Wheat",
        "category": "Grains & Pulses",
        "price_per_unit": 42.00,
        "unit": "kg",
        "available_quantity": 5000,
        "is_organic": False,
        "grade": "A+",
        "location": "Anand, Gujarat",
        "rating_avg": 4.9,
        "rating_count": 56
    },
    {
        "listing_id": 104,
        "farmer_name": "Suresh Patel",
        "title": "Fresh Green Capsicum",
        "crop_name": "Capsicum",
        "category": "Vegetables",
        "price_per_unit": 45.00,
        "unit": "kg",
        "available_quantity": 800,
        "is_organic": False,
        "grade": "A",
        "location": "Anand, Gujarat",
        "rating_avg": 4.4,
        "rating_count": 19
    },
    {
        "listing_id": 105,
        "farmer_name": "Anita Sharma",
        "title": "Shimla Royal Delicious Apples",
        "crop_name": "Apple",
        "category": "Fruits",
        "price_per_unit": 120.00,
        "unit": "kg",
        "available_quantity": 1200,
        "is_organic": True,
        "grade": "A+",
        "location": "Shimla, Himachal Pradesh",
        "rating_avg": 4.95,
        "rating_count": 65
    },
    {
        "listing_id": 106,
        "farmer_name": "Anita Sharma",
        "title": "Organic Himachal Honey",
        "crop_name": "Honey",
        "category": "Dairy & Honey",
        "price_per_unit": 380.00,
        "unit": "kg",
        "available_quantity": 250,
        "is_organic": True,
        "grade": "A+",
        "location": "Shimla, Himachal Pradesh",
        "rating_avg": 5.0,
        "rating_count": 31
    },
    {
        "listing_id": 107,
        "farmer_name": "Vikram Singh",
        "title": "Organic Basmati Rice 1121",
        "crop_name": "Rice",
        "category": "Grains & Pulses",
        "price_per_unit": 95.00,
        "unit": "kg",
        "available_quantity": 4000,
        "is_organic": True,
        "grade": "A+",
        "location": "Ludhiana, Punjab",
        "rating_avg": 4.7,
        "rating_count": 38
    },
    {
        "listing_id": 108,
        "farmer_name": "Vikram Singh",
        "title": "Fresh Yellow Sweet Corn",
        "crop_name": "Corn",
        "category": "Vegetables",
        "price_per_unit": 18.00,
        "unit": "kg",
        "available_quantity": 2000,
        "is_organic": False,
        "grade": "B",
        "location": "Ludhiana, Punjab",
        "rating_avg": 4.3,
        "rating_count": 14
    }
])

# 4. User Interactions Sheet (For ML Training)
interactions_df = pd.DataFrame([
    {"buyer_id": "55555555-5555-5555-5555-555555555555", "buyer_name": "Priya Verma", "listing_id": 101, "crop_name": "Tomato", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 5.0},
    {"buyer_id": "55555555-5555-5555-5555-555555555555", "buyer_name": "Priya Verma", "listing_id": 102, "crop_name": "Onion", "interaction_type": "ADD_TO_CART", "interaction_weight": 3.0, "rating_value": None},
    {"buyer_id": "55555555-5555-5555-5555-555555555555", "buyer_name": "Priya Verma", "listing_id": 105, "crop_name": "Apple", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 4.5},
    {"buyer_id": "55555555-5555-5555-5555-555555555555", "buyer_name": "Priya Verma", "listing_id": 106, "crop_name": "Honey", "interaction_type": "VIEW", "interaction_weight": 1.0, "rating_value": None},
    {"buyer_id": "66666666-6666-6666-6666-666666666666", "buyer_name": "Amit Roy", "listing_id": 101, "crop_name": "Tomato", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 5.0},
    {"buyer_id": "66666666-6666-6666-6666-666666666666", "buyer_name": "Amit Roy", "listing_id": 103, "crop_name": "Wheat", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 4.8},
    {"buyer_id": "66666666-6666-6666-6666-666666666666", "buyer_name": "Amit Roy", "listing_id": 107, "crop_name": "Rice", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 4.7},
    {"buyer_id": "66666666-6666-6666-6666-666666666666", "buyer_name": "Amit Roy", "listing_id": 104, "crop_name": "Capsicum", "interaction_type": "VIEW", "interaction_weight": 1.0, "rating_value": None},
    {"buyer_id": "77777777-7777-7777-7777-777777777777", "buyer_name": "Sneha Kapoor", "listing_id": 105, "crop_name": "Apple", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 5.0},
    {"buyer_id": "77777777-7777-7777-7777-777777777777", "buyer_name": "Sneha Kapoor", "listing_id": 106, "crop_name": "Honey", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 5.0},
    {"buyer_id": "77777777-7777-7777-7777-777777777777", "buyer_name": "Sneha Kapoor", "listing_id": 101, "crop_name": "Tomato", "interaction_type": "ADD_TO_CART", "interaction_weight": 3.0, "rating_value": None},
    {"buyer_id": "88888888-8888-8888-8888-888888888888", "buyer_name": "Rajesh Joshi", "listing_id": 103, "crop_name": "Wheat", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 5.0},
    {"buyer_id": "88888888-8888-8888-8888-888888888888", "buyer_name": "Rajesh Joshi", "listing_id": 107, "crop_name": "Rice", "interaction_type": "PURCHASE", "interaction_weight": 5.0, "rating_value": 4.9},
    {"buyer_id": "88888888-8888-8888-8888-888888888888", "buyer_name": "Rajesh Joshi", "listing_id": 108, "crop_name": "Corn", "interaction_type": "ADD_TO_CART", "interaction_weight": 3.0, "rating_value": None}
])

# Write multi-sheet Excel file
with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
    users_df.to_excel(writer, sheet_name='Users', index=False)
    categories_df.to_excel(writer, sheet_name='Categories', index=False)
    listings_df.to_excel(writer, sheet_name='Crop_Listings', index=False)
    interactions_df.to_excel(writer, sheet_name='User_Interactions', index=False)

print(f"Successfully generated AgriLink Excel Database at: {output_path}")
