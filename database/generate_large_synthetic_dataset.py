import os
import uuid
import random
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Deterministic seed for reproducible synthetic generation
random.seed(42)
np.random.seed(42)

print("Starting Generation of North Bengaluru Realistic Basket-Driven Synthetic Dataset...")

csv_dir = os.path.join(os.path.dirname(__file__), "csv")
os.makedirs(csv_dir, exist_ok=True)
excel_path = os.path.join(os.path.dirname(__file__), "AgriLink_Dummy_Database.xlsx")
sql_path = os.path.join(os.path.dirname(__file__), "populate_500_synthetic_records.sql")

# ============================================================
# 1. ROLES
# ============================================================
roles_data = [
    {"role_id": "11111111-1111-1111-1111-111111111111", "role_name": "FARMER", "role_description": "Verified North Bengaluru Local Farmer & Producer"},
    {"role_id": "22222222-2222-2222-2222-222222222222", "role_name": "BUYER", "role_description": "Retail Consumer / Tech Park Buyer / Restaurant"},
    {"role_id": "33333333-3333-3333-3333-333333333333", "role_name": "AGGREGATOR", "role_description": "North Bengaluru Cold Storage Hub Operator"},
    {"role_id": "44444444-4444-4444-4444-444444444444", "role_name": "ADMIN", "role_description": "Platform Admin & Quality Auditor"},
    {"role_id": "55555555-5555-5555-5555-555555555555", "role_name": "DELIVERY_AGENT", "role_description": "North Bengaluru Quick Commerce Delivery Rider"}
]
role_df = pd.DataFrame(roles_data)

# ============================================================
# 2. MANDYA -> BENGALURU AGRO-CORRIDOR ZONES & LOCATIONS
# ============================================================
mandya_bengaluru_zones = [
    # Mandya District Farm Hubs & Tier-1 SHG Homemaker Depots
    {
        "area": "Mandya",
        "pincode": "571401",
        "base_lat": 12.5230,
        "base_lon": 76.8980,
        "landmarks": [
            "Mandya Sugar Town Agro Depot",
            "Kallalli Farm Gate, Mandya",
            "Holalu Organic Vegetable Cluster",
            "Mandya APMC Main Yard Road",
            "Lakshmi SHG Homemaker Depot, Mandya"
        ]
    },
    {
        "area": "Maddur",
        "pincode": "571428",
        "base_lat": 12.5840,
        "base_lon": 77.0450,
        "landmarks": [
            "Maddur Tender Coconut and Veg Hub",
            "Shimsha River Basin Depot, Maddur",
            "Kestur Farmer Producer Collective",
            "Cauvery Mahila Sangha Depot, Maddur"
        ]
    },
    {
        "area": "Srirangapatna",
        "pincode": "571438",
        "base_lat": 12.4180,
        "base_lon": 76.6950,
        "landmarks": [
            "Kaveri River Bank Farm Cluster",
            "Ganjam Agro Center, Srirangapatna",
            "Paschimavahini Organic Garden",
            "Bhavani SHG Collection Point, Srirangapatna"
        ]
    },
    {
        "area": "Pandavapura",
        "pincode": "571434",
        "base_lat": 12.5000,
        "base_lon": 76.6700,
        "landmarks": [
            "Melukote Foothills Farm Gate",
            "Baby Betta Organic Farm Depot, Pandavapura"
        ]
    },
    {
        "area": "Malavalli",
        "pincode": "571430",
        "base_lat": 12.3870,
        "base_lon": 77.0600,
        "landmarks": [
            "Marehalli Green Belt Depot, Malavalli",
            "Malavalli APMC Yard Road"
        ]
    },
    # Corridor Consolidation Points (Tier-2 Transit Hubs)
    {
        "area": "Ramanagara",
        "pincode": "562159",
        "base_lat": 12.7200,
        "base_lon": 77.2800,
        "landmarks": [
            "Ramanagara Expressway Agro Transit Hub",
            "Silk City Corridor Staging Center"
        ]
    },
    {
        "area": "Channapatna",
        "pincode": "562160",
        "base_lat": 12.6500,
        "base_lon": 77.2000,
        "landmarks": [
            "Channapatna Highway Consolidation Center",
            "Toy City Corridor Pooling Depot"
        ]
    },
    {
        "area": "Bidadi",
        "pincode": "562109",
        "base_lat": 12.7950,
        "base_lon": 77.3800,
        "landmarks": [
            "Bidadi Expressway Logistics Center",
            "Corridor Express Transfer Point, Bidadi"
        ]
    },
    # Bengaluru Urban Consumer Delivery Destination Zones (Individual Customers)
    {
        "area": "Bengaluru (Kengeri)",
        "pincode": "560060",
        "base_lat": 12.9100,
        "base_lon": 77.4850,
        "landmarks": [
            "Kengeri Satellite Town Delivery Hub",
            "Mysore Road Express Drop Point"
        ]
    },
    {
        "area": "Bengaluru (RR Nagar)",
        "pincode": "560098",
        "base_lat": 12.9250,
        "base_lon": 77.5180,
        "landmarks": [
            "Rajarajeshwari Nagar Ideal Homes Drop Point",
            "BEML Layout Delivery Center"
        ]
    },
    {
        "area": "Bengaluru (JP Nagar)",
        "pincode": "560078",
        "base_lat": 12.9060,
        "base_lon": 77.5850,
        "landmarks": [
            "JP Nagar 6th Phase Consumer Delivery Hub",
            "Dollars Colony Delivery Drop"
        ]
    },
    {
        "area": "Bengaluru (Indiranagar)",
        "pincode": "560038",
        "base_lat": 12.9780,
        "base_lon": 77.6400,
        "landmarks": [
            "100 Feet Road Delivery Hub, Indiranagar",
            "Defence Colony Drop Point"
        ]
    },
    {
        "area": "Bengaluru (Koramangala)",
        "pincode": "560034",
        "base_lat": 12.9350,
        "base_lon": 77.6200,
        "landmarks": [
            "4th Block Koramangala Delivery Hub",
            "Sony World Signal Express Drop Point"
        ]
    },
    {
        "area": "Bengaluru (Hebbal)",
        "pincode": "560024",
        "base_lat": 13.0358,
        "base_lon": 77.5970,
        "landmarks": [
            "Near Kirloskar Business Park, Hebbal",
            "Kempapura Main Road, Hebbal"
        ]
    },
    {
        "area": "Bengaluru (Yelahanka)",
        "pincode": "560064",
        "base_lat": 13.1005,
        "base_lon": 77.5963,
        "landmarks": [
            "Sector 1, Yelahanka New Town",
            "Kogilu Main Road Organic Depot"
        ]
    }
]

locations_data = []
for i in range(160):
    zone = mandya_bengaluru_zones[i % len(mandya_bengaluru_zones)]
    landmark = random.choice(zone["landmarks"])
    lat = round(zone["base_lat"] + random.uniform(-0.008, 0.008), 6)
    lon = round(zone["base_lon"] + random.uniform(-0.008, 0.008), 6)
    
    city_name = zone['area'] if "Bengaluru" in zone['area'] else f"Karnataka ({zone['area']})"
    
    locations_data.append({
        "location_id": str(uuid.uuid4()),
        "address_line1": f"No. {random.randint(12, 850)}, {landmark}",
        "city": city_name,
        "state": "Karnataka",
        "pincode": zone["pincode"],
        "country": "India",
        "latitude": lat,
        "longitude": lon,
        "area": zone["area"]
    })
location_df = pd.DataFrame(locations_data)

# ============================================================
# 3. CROP CATEGORIES & THE FOCUSED 19 AGRICULTURAL CROPS
# ============================================================
categories_data = [
    {"category_id": "60000000-0000-0000-0000-000000000001", "category_name": "Vegetables", "description": "Fresh daily harvest vegetables from Mandya-Bengaluru agro-corridor farms"},
    {"category_id": "60000000-0000-0000-0000-000000000002", "category_name": "Fresh Herbs & Cooking Essentials", "description": "Aromatic culinary herbs, ginger, garlic, and fresh kitchen essentials"},
    {"category_id": "60000000-0000-0000-0000-000000000003", "category_name": "Fruits", "description": "Orchard fruits, Mandya bananas, papayas, and fresh vineyard grapes"},
    {"category_id": "60000000-0000-0000-0000-000000000004", "category_name": "Staples & Grains", "description": "Organic Ragi and Karnataka Sona Masuri heritage rice"}
]
crop_category_df = pd.DataFrame(categories_data)
cat_map = {row["category_name"]: row["category_id"] for _, row in crop_category_df.iterrows()}

# The exact clean crop catalogue requested
crops_master_list = [
    # 🥕 Vegetables (9)
    ("Tomato", "Vegetables", "kg", 38.0, True, "Farm fresh red ripe tomatoes from Mandya-Maddur farming belt"),
    ("Potato", "Vegetables", "kg", 32.0, False, "Clean high-starch table potatoes from Hassan-Mandya corridor"),
    ("Onion", "Vegetables", "kg", 42.0, False, "Dry cured pungent red onions from Karnataka mandis"),
    ("Carrot", "Vegetables", "kg", 55.0, True, "Sweet crunchy orange carrots from Ooty-Mandya farms"),
    ("Cabbage", "Vegetables", "kg", 28.0, True, "Fresh crisp whole green cabbage heads"),
    ("Green Peas", "Vegetables", "kg", 75.0, True, "Sweet tender green peas harvested morning"),
    ("Green Capsicum", "Vegetables", "kg", 65.0, True, "Polyhouse crisp green bell peppers from Srirangapatna"),
    ("Green Chilli", "Vegetables", "kg", 45.0, True, "Spicy pungent fresh G4 green chillies"),
    ("Palak", "Vegetables", "bunch", 25.0, True, "Early morning harvested tender leafy spinach"),
    
    # 🌿 Fresh Herbs & Cooking Essentials (4)
    ("Coriander", "Fresh Herbs & Cooking Essentials", "bunch", 18.0, True, "Fragrant fresh green garnish coriander bunches"),
    ("Mint", "Fresh Herbs & Cooking Essentials", "bunch", 20.0, True, "Aromatic fresh farm pudina leaves"),
    ("Ginger", "Fresh Herbs & Cooking Essentials", "kg", 85.0, True, "Fresh aromatic washed ginger roots"),
    ("Garlic", "Fresh Herbs & Cooking Essentials", "kg", 110.0, False, "Pungent dried local country garlic bulbs"),
    
    # 🍌 Fruits (4)
    ("Banana", "Fruits", "dozen", 48.0, True, "Naturally ripened sweet Elakki bananas from Mandya"),
    ("Papaya", "Fruits", "kg", 40.0, True, "Sweet organic Red Lady breakfast papaya"),
    ("Pomegranate", "Fruits", "kg", 130.0, True, "Ruby red arils Kaveri basin pomegranate"),
    ("Grapes", "Fruits", "kg", 90.0, True, "Sweet and tart fresh Bangalore Blue grapes"),
    
    # 🌾 Optional Staples (2)
    ("Ragi", "Staples & Grains", "kg", 52.0, False, "Nutrient-dense organic whole grain Finger Millet"),
    ("Rice", "Staples & Grains", "kg", 68.0, False, "Premium fine grain Sona Masuri table rice")
]

crops_data = []
crop_lookup = {}
for crop_name, cat_name, unit, base_price, is_perishable, desc in crops_master_list:
    c_id = str(uuid.uuid4())
    crops_data.append({
        "crop_id": c_id,
        "category_id": cat_map[cat_name],
        "crop_name": crop_name,
        "description": desc,
        "unit": unit,
        "base_price": base_price,
        "is_perishable": is_perishable
    })
    crop_lookup[crop_name] = c_id

crop_df = pd.DataFrame(crops_data)

# ============================================================
# 4. APP USERS & PROFILES (150 Farmers, 100 Customers, 30 Aggregators, 20 Admins)
# ============================================================
kannada_first_names = [
    "Ramesh", "Manjunath", "Suresh", "Lakshmi", "Anand", "Venkatesh", "Pavitra", "Girish",
    "Shiva", "Siddarama", "Basavaraj", "Nandini", "Kavya", "Deepak", "Chetan", "Sunitha",
    "Gowramma", "Prajwal", "Darshan", "Rakshith", "Tejas", "Meghana", "Shilpa", "Harish",
    "Kishore", "Sowmya", "Arjun", "Bharath", "Roopa", "Karthik", "Vinay", "Chandrashekar",
    "Priya", "Rahul", "Sneha", "Aditya", "Neha", "Varun", "Pooja", "Gautam"
]
kannada_last_names = [
    "Gowda", "Reddy", "Patil", "Hegde", "Bhat", "Shetty", "Rao", "Kumar", "Murthy",
    "Naik", "Prasad", "Swamy", "Acharya", "Chari", "Kulkarni", "Deshpande", "Pujari", "Verma", "Sharma"
]

users_data = []
farmer_profiles = []
customer_profiles = []
aggregator_profiles = []

CUSTOMER_ARCHETYPES = [
    "BASIC_HOUSEHOLD",       # Tomato + Onion + Potato + Coriander
    "CURRY_COOKING",         # Tomato + Onion + Green Chilli + Coriander + Ginger + Garlic
    "HEALTHY_GREENS",        # Palak + Carrot + Banana + Papaya
    "SOUTH_INDIAN_KITCHEN",  # Tomato + Onion + Ginger + Garlic + Coriander + Ragi/Rice
    "WEEKEND_GROCERY",       # Potato + Onion + Tomato + Carrot + Green Peas + Cabbage
    "FRUIT_LOVER",           # Banana + Papaya + Pomegranate + Grapes
    "PREMIUM_ORGANIC",       # Organic Tomato + Palak + Carrot + Green Capsicum
    "SPICE_ESSENTIAL"        # Ginger + Garlic + Green Chilli + Coriander + Mint
]

for i in range(300):
    uid = str(uuid.uuid4())
    fname = random.choice(kannada_first_names)
    lname = random.choice(kannada_last_names)
    fullname = f"{fname} {lname}"
    loc = random.choice(locations_data)
    phone = f"+9198{random.randint(10000000, 99999999)}"
    
    if i < 150: # 150 Farmers
        role_id = "11111111-1111-1111-1111-111111111111"
        email = f"farmer.{fname.lower()}.{i}@agrilink.in"
        users_data.append({"user_id": uid, "role_id": role_id, "location_id": loc["location_id"], "email": email, "phone": phone, "full_name": f"{fullname} (Farmer)", "is_active": True})
        farmer_profiles.append({
            "farmer_id": str(uuid.uuid4()),
            "user_id": uid,
            "farm_size_acres": round(random.uniform(1.5, 25.0), 2),
            "primary_crops": ", ".join(random.sample([c["crop_name"] for c in crops_data], 3)),
            "kyc_verified": True,
            "location_area": loc["area"]
        })
    elif i < 250: # 100 Customers (All Individual Residents)
        role_id = "22222222-2222-2222-2222-222222222222"
        email = f"buyer.{fname.lower()}.{i-150}@gmail.com"
        users_data.append({"user_id": uid, "role_id": role_id, "location_id": loc["location_id"], "email": email, "phone": phone, "full_name": f"{fullname}", "is_active": True})
        
        primary_arch = CUSTOMER_ARCHETYPES[(i - 150) % len(CUSTOMER_ARCHETYPES)]
        secondary_arch = random.choice(CUSTOMER_ARCHETYPES)
        
        customer_profiles.append({
            "customer_id": str(uuid.uuid4()),
            "user_id": uid,
            "customer_type": "INDIVIDUAL_RESIDENT",
            "preferred_category_id": cat_map["Vegetables"],
            "primary_archetype": primary_arch,
            "secondary_archetype": secondary_arch,
            "location_area": loc["area"],
            "location_id": loc["location_id"]
        })
    elif i < 280: # 30 Aggregators (20 SHG Homemaker Tier-1 + 10 Corridor Transit Tier-2)
        role_id = "33333333-3333-3333-3333-333333333333"
        email = f"hub.{fname.lower()}.{i-250}@agrilink.in"
        is_tier1 = (i - 250) < 20
        if is_tier1:
            hub_title = f"{fname} SHG Homemaker Depot ({loc['area']})"
            storage_cap = round(random.uniform(0.5, 2.5), 2)
            user_title = f"{fullname} (SHG Homemaker Aggregator)"
        else:
            hub_title = f"Corridor Highway Consolidation Hub - {loc['area']} #{i-269}"
            storage_cap = round(random.uniform(10.0, 50.0), 2)
            user_title = f"{fullname} (Corridor Transit Operator)"
            
        users_data.append({"user_id": uid, "role_id": role_id, "location_id": loc["location_id"], "email": email, "phone": phone, "full_name": user_title, "is_active": True})
        aggregator_profiles.append({
            "aggregator_id": str(uuid.uuid4()),
            "user_id": uid,
            "hub_name": hub_title,
            "storage_capacity_tons": storage_cap,
            "location_area": loc["area"]
        })
    else: # 20 Admin / Corridor Logistics
        role_id = "44444444-4444-4444-4444-444444444444"
        email = f"ops.{fname.lower()}.{i-280}@agrilink.in"
        users_data.append({"user_id": uid, "role_id": role_id, "location_id": loc["location_id"], "email": email, "phone": phone, "full_name": f"{fullname} (Corridor Operations)", "is_active": True})

app_user_df = pd.DataFrame(users_data)
farmer_profile_df = pd.DataFrame(farmer_profiles)
customer_profile_df = pd.DataFrame(customer_profiles)
aggregator_profile_df = pd.DataFrame(aggregator_profiles)

# ============================================================
# 5. INVENTORY ITEMS & SELLER LISTINGS (350 Harvest Batches)
# ============================================================
inventory_data = []
listing_data = []
crop_to_listings = {c["crop_name"]: [] for c in crops_data}

for i in range(350):
    inv_id = str(uuid.uuid4())
    listing_id = str(uuid.uuid4())
    farmer = random.choice(farmer_profiles)
    crop = random.choice(crops_data)
    
    qty = round(random.uniform(80.0, 3000.0), 2)
    # Price variation around base price
    price = round(crop["base_price"] * random.uniform(0.85, 1.15), 2)
    harvest_d = (datetime.now() - timedelta(days=random.randint(1, 20))).strftime("%Y-%m-%d")
    grade = random.choice(["A+", "A", "A+", "B", "A+"])
    
    inventory_data.append({
        "inventory_id": inv_id,
        "farmer_id": farmer["farmer_id"],
        "crop_id": crop["crop_id"],
        "quantity": qty,
        "price_per_unit": price,
        "grade": grade,
        "harvest_date": harvest_d,
        "status": "AVAILABLE"
    })
    
    is_org = True if "Organic" in crop["crop_name"] or random.random() > 0.4 else False
    listing_entry = {
        "listing_id": listing_id,
        "inventory_id": inv_id,
        "crop_name": crop["crop_name"],
        "title": f"Fresh {crop['crop_name']} - {farmer['location_area']} Farm Direct",
        "is_organic": is_org,
        "rating_avg": round(random.uniform(4.4, 5.0), 2),
        "rating_count": random.randint(12, 180),
        "price_per_unit": price,
        "unit": crop["unit"],
        "location_area": farmer["location_area"]
    }
    listing_data.append(listing_entry)
    crop_to_listings[crop["crop_name"]].append(listing_entry)

inventory_item_df = pd.DataFrame(inventory_data)
seller_listing_df = pd.DataFrame(listing_data)

# ============================================================
# 6. REALISTIC BASKET PATTERNS FOR ORDERS & FP-GROWTH
# ============================================================
# Map archetypes to crop itemsets
BASKET_TEMPLATES = {
    "BASIC_HOUSEHOLD": ["Tomato", "Onion", "Potato"],
    "CURRY_COOKING": ["Tomato", "Onion", "Green Chilli", "Coriander"],
    "HEALTHY_GREENS": ["Palak", "Carrot", "Banana"],
    "SOUTH_INDIAN_KITCHEN": ["Tomato", "Onion", "Ginger", "Garlic", "Coriander"],
    "WEEKEND_GROCERY": ["Potato", "Onion", "Tomato", "Carrot", "Green Peas"],
    "FRUIT_LOVER": ["Banana", "Papaya", "Pomegranate"],
    "PREMIUM_ORGANIC": ["Tomato", "Palak", "Carrot"],
    "SPICE_ESSENTIAL": ["Ginger", "Garlic", "Green Chilli", "Coriander"]
}

OPTIONAL_ADDITIONS = ["Mint", "Green Capsicum", "Cabbage", "Grapes", "Ragi", "Rice"]

orders_data = []
order_items_data = []
deliveries_data = []
payments_data = []
interactions_data = []
reviews_data = []

north_blr_delivery_partners = [
    "AgriLink Express (Hebbal-Yelahanka Corridor)",
    "North Bangalore FreshVan Logistics",
    "Manyata Express Cargo Rider",
    "Devanahalli Farm Direct Fleet",
    "Sahakarnagar Local QuickRider"
]

print("Generating 450 realistic customer order transactions matching shopping archetypes...")

order_counter = 0
for cust in customer_profiles:
    # Each customer places 3 to 6 orders over the last 45 days (giving repeat purchase frequency!)
    num_orders_for_cust = random.randint(3, 6)
    
    for o_idx in range(num_orders_for_cust):
        order_counter += 1
        order_id = str(uuid.uuid4())
        
        # Choose basket from customer's primary or secondary archetype (85% fidelity for high lift!)
        active_arch = cust["primary_archetype"] if random.random() < 0.70 else cust["secondary_archetype"]
        base_basket = list(BASKET_TEMPLATES[active_arch])
        
        # 30% chance of adding 1 complementary item
        if random.random() < 0.35:
            base_basket.append(random.choice(OPTIONAL_ADDITIONS))
        
        # Deduplicate basket
        chosen_crops = list(dict.fromkeys(base_basket))
        
        # Order timestamp distributed over the past 45 days
        days_ago = (num_orders_for_cust - o_idx) * random.randint(4, 8) + random.randint(0, 3)
        order_time = (datetime.now() - timedelta(days=days_ago, hours=random.randint(1, 10))).isoformat()
        
        order_total = 0.0
        
        for crop_name in chosen_crops:
            # Pick a listing for this crop, prioritizing nearby area if available
            available_listings = crop_to_listings[crop_name]
            nearby_listings = [l for l in available_listings if l["location_area"] == cust["location_area"]]
            listing = random.choice(nearby_listings) if nearby_listings and random.random() < 0.65 else random.choice(available_listings)
            
            item_qty = round(random.uniform(1.0, 5.0) if listing["unit"] in ["kg", "dozen"] else random.uniform(1.0, 3.0), 2)
            unit_price = listing["price_per_unit"]
            subtotal = round(item_qty * unit_price, 2)
            order_total += subtotal
            
            # Order Item
            order_items_data.append({
                "order_item_id": str(uuid.uuid4()),
                "order_id": order_id,
                "listing_id": listing["listing_id"],
                "quantity": item_qty,
                "unit_price": unit_price
            })
            
            # User Interaction (Purchase weight: 10.0)
            interactions_data.append({
                "interaction_id": str(uuid.uuid4()),
                "customer_id": cust["customer_id"],
                "listing_id": listing["listing_id"],
                "interaction_type": "PURCHASE",
                "interaction_weight": 10.0,
                "created_at": order_time
            })
            
            # Also add browsing / cart interactions occasionally
            if random.random() < 0.4:
                interactions_data.append({
                    "interaction_id": str(uuid.uuid4()),
                    "customer_id": cust["customer_id"],
                    "listing_id": listing["listing_id"],
                    "interaction_type": "ADD_TO_CART",
                    "interaction_weight": 5.0,
                    "created_at": order_time
                })
        
        # Order Record
        order_status = "DELIVERED" if days_ago >= 2 else random.choice(["IN_TRANSIT", "PAID"])
        pay_method = random.choice(["UPI_GPAY", "UPI_PHONEPE", "RAZORPAY", "NET_BANKING", "CASH_ON_DELIVERY"])
        
        orders_data.append({
            "order_id": order_id,
            "customer_id": cust["customer_id"],
            "total_amount": round(order_total, 2),
            "order_status": order_status,
            "payment_method": pay_method
        })
        
        # Delivery Record
        deliveries_data.append({
            "delivery_id": str(uuid.uuid4()),
            "order_id": order_id,
            "delivery_agent_name": random.choice(north_blr_delivery_partners),
            "delivery_status": order_status,
            "tracking_code": f"BLR-NORTH-{random.randint(10000, 99999)}"
        })
        
        # Payment Record
        payments_data.append({
            "payment_id": str(uuid.uuid4()),
            "order_id": order_id,
            "transaction_ref": f"pay_blr_{random.randint(10000000, 99999999)}",
            "payment_amount": round(order_total, 2),
            "payment_status": "SUCCESS"
        })

# Add verified reviews
for i in range(180):
    sample_order = random.choice(orders_data)
    cust_id = sample_order["customer_id"]
    cust_area = next(c["location_area"] for c in customer_profiles if c["customer_id"] == cust_id)
    reviews_data.append({
        "review_id": str(uuid.uuid4()),
        "listing_id": random.choice(listing_data)["listing_id"],
        "customer_id": cust_id,
        "rating": round(random.choice([4.5, 5.0, 4.8, 5.0, 4.7]), 1),
        "comment": random.choice([
            f"Delivered to {cust_area} within 35 mins from North BLR farm hub! Super fresh.",
            "Genuine organic produce straight from local farmers. Great natural aroma and crispness.",
            "Manyata Tech Park delivery was perfectly packaged. Tomato and coriander were crisp.",
            f"Direct farmgate connection saves money compared to supermarket prices in {cust_area}.",
            "Greens and vegetables were freshly harvested this morning. Unbeatable quality!"
        ])
    })

customer_order_df = pd.DataFrame(orders_data)
order_item_df = pd.DataFrame(order_items_data)
delivery_df = pd.DataFrame(deliveries_data)
payment_df = pd.DataFrame(payments_data)
user_interaction_df = pd.DataFrame(interactions_data)
customer_review_df = pd.DataFrame(reviews_data)

# ============================================================
# 7. ML PRICING LOGS & NOTIFICATIONS (250 Records)
# ============================================================
ml_logs = []
for crop in crops_data:
    for _ in range(12):
        base_p = crop["base_price"]
        ml_logs.append({
            "log_id": str(uuid.uuid4()),
            "crop_id": crop["crop_id"],
            "predicted_price": round(base_p * random.uniform(0.94, 1.06), 2),
            "confidence_score": round(random.uniform(0.92, 0.99), 3)
        })
ml_pricing_log_df = pd.DataFrame(ml_logs)

notifications_data = []
for i in range(250):
    user = random.choice(users_data)
    notifications_data.append({
        "notification_id": str(uuid.uuid4()),
        "user_id": user["user_id"],
        "title": random.choice([
            "North BLR Morning Harvest In Stock",
            "Yelahanka Hub Order Dispatched",
            "Farmer Direct Payout Credited",
            "Manyata Tech Park Express Slot Available",
            "Mandi Price Update for North Bengaluru"
        ]),
        "message": f"AgriLink North Bengaluru update for account {user['email']}.",
        "is_read": random.choice([True, False, True])
    })
notification_df = pd.DataFrame(notifications_data)

# Clean extra memory-only fields from DataFrames before DB writing
clean_location_df = location_df.drop(columns=["area"], errors="ignore")
clean_crop_df = crop_df.drop(columns=["base_price"], errors="ignore")
clean_farmer_df = farmer_profile_df.drop(columns=["location_area"], errors="ignore")
clean_customer_df = customer_profile_df.drop(columns=["primary_archetype", "secondary_archetype", "location_area", "location_id"], errors="ignore")
clean_aggregator_df = aggregator_profile_df.drop(columns=["location_area"], errors="ignore")
clean_listing_df = seller_listing_df.drop(columns=["crop_name", "price_per_unit", "unit", "location_area"], errors="ignore")

# ============================================================
# 8. EXPORT TO CSV, EXCEL, AND MASTER SQL SCRIPT
# ============================================================
tables_dfs = {
    "role": role_df,
    "location": clean_location_df,
    "crop_category": crop_category_df,
    "crop": clean_crop_df,
    "app_user": app_user_df,
    "farmer_profile": clean_farmer_df,
    "customer_profile": clean_customer_df,
    "aggregator_profile": clean_aggregator_df,
    "inventory_item": inventory_item_df,
    "seller_listing": clean_listing_df,
    "customer_order": customer_order_df,
    "order_item": order_item_df,
    "delivery": delivery_df,
    "payment": payment_df,
    "user_interaction": user_interaction_df,
    "customer_review": customer_review_df,
    "ml_pricing_log": ml_pricing_log_df,
    "notification": notification_df
}

print("\nSaving Clean North Bengaluru CSV files:")
for tname, df in tables_dfs.items():
    csv_file = os.path.join(csv_dir, f"{tname}.csv")
    df.to_csv(csv_file, index=False)
    print(f"  [OK] {tname}.csv ({len(df)} records)")

print(f"\nWriting to Excel at {excel_path}...")
with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
    for tname, df in tables_dfs.items():
        df.to_excel(writer, sheet_name=tname, index=False)
print(f"  [OK] Excel Database updated successfully with {len(order_item_df)} basket order items.")

print(f"\nWriting Clean SQL Migration Script at {sql_path}...")
with open(sql_path, "w", encoding="utf-8") as f:
    f.write("-- ============================================================\n")
    f.write("-- AGRILINK NORTH BENGALURU REALISTIC BASKET DATASET (18 TABLES)\n")
    f.write("-- Focus: Hebbal, Yelahanka, Devanahalli, Thanisandra, Sahakarnagar, Jakkur, Hennur, Vidyaranyapura\n")
    f.write("-- Optimized for: Buy Again, FP-Growth You May Also Want, and Picked For You\n")
    f.write("-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/nxwhnbejvwxiuekhtmpm/sql\n")
    f.write("-- ============================================================\n\n")
    
    # 1. Clean previous data
    f.write("-- Truncate all tables to maintain referential integrity\n")
    f.write("TRUNCATE TABLE \n")
    f.write("    notification, customer_review, user_interaction, ml_pricing_log,\n")
    f.write("    payment, delivery, order_item, customer_order,\n")
    f.write("    seller_listing, inventory_item,\n")
    f.write("    farmer_profile, customer_profile, aggregator_profile,\n")
    f.write("    app_user, crop, crop_category, location, role \n")
    f.write("CASCADE;\n\n")
    
    # Helper for SQL values
    def format_val(val):
        if pd.isna(val) or val is None:
            return "NULL"
        if isinstance(val, bool):
            return "TRUE" if val else "FALSE"
        if isinstance(val, (int, np.integer)):
            return str(val)
        if isinstance(val, (float, np.floating)):
            return str(round(val, 4))
        # String escaping
        escaped = str(val).replace("'", "''")
        return f"'{escaped}'"

    for tname, df in tables_dfs.items():
        cols = list(df.columns)
        cols_str = ", ".join(cols)
        f.write(f"-- Table: {tname} ({len(df)} records)\n")
        f.write(f"INSERT INTO {tname} ({cols_str}) VALUES\n")
        
        row_strs = []
        for _, row in df.iterrows():
            vals = [format_val(row[col]) for col in cols]
            row_strs.append(f"({', '.join(vals)})")
            
        f.write(",\n".join(row_strs))
        f.write("\nON CONFLICT DO NOTHING;\n\n")

print(f"  [OK] Master SQL Script generated with {sum(len(df) for df in tables_dfs.values())} total records.")

# ============================================================
# 9. AUTO-SPLIT MASTER SQL INTO 4 SUPABASE-COMPATIBLE CHUNKS
# ============================================================
split_dir = os.path.join(os.path.dirname(__file__), "split_migrations")
os.makedirs(split_dir, exist_ok=True)

with open(sql_path, "r", encoding="utf-8") as f:
    sql_lines = f.readlines()

indices = {}
for i, line in enumerate(sql_lines):
    if line.startswith("-- Table: customer_order"):
        indices["part2"] = i
    elif line.startswith("-- Table: user_interaction"):
        indices["part3"] = i
    elif line.startswith("-- Table: customer_review"):
        indices["part4"] = i

p2 = indices.get("part2", 1524)
p3 = indices.get("part3", 4893)
p4 = indices.get("part4", 7592)

with open(os.path.join(split_dir, "01_core_and_listings.sql"), "w", encoding="utf-8") as f:
    f.writelines(sql_lines[:p2])

with open(os.path.join(split_dir, "02_orders_and_deliveries.sql"), "w", encoding="utf-8") as f:
    f.writelines(sql_lines[p2:p3])

with open(os.path.join(split_dir, "03_user_interactions.sql"), "w", encoding="utf-8") as f:
    f.writelines(sql_lines[p3:p4])

with open(os.path.join(split_dir, "04_reviews_and_notifications.sql"), "w", encoding="utf-8") as f:
    f.writelines(sql_lines[p4:])

print("\nSplit SQL Migrations for Supabase Web Editor:")
for fname in sorted(os.listdir(split_dir)):
    fpath = os.path.join(split_dir, fname)
    with open(fpath, "r", encoding="utf-8") as f:
        count = len(f.readlines())
    print(f"  [OK] {fname}: {round(os.path.getsize(fpath)/1024, 2)} KB ({count} lines)")

print("\n=== Dataset Generation Complete! ===")

