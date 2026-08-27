import os
import pandas as pd
import openpyxl

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Build login credentials table for testing
users_data = []

# 1. Customer Users
for i in range(1, 71):
    users_data.append({
        "User Role": "Customer",
        "Full Name": f"Customer User {i}",
        "Phone Number": f"+9198{i:08d}",
        "Default Test OTP": f"{100000 + ((+919800000000 + i) % 900000)}",
        "Customer ID / Identifier": f"CUST-{1000 + i}",
        "Customer Type": ["Individual", "Hostel/PG", "Hospital", "Restaurant", "Corporate"][(i % 5)],
        "District / Region": ["Kolar Central", "Chickballapur", "Bangalore Rural", "Bangalore Urban", "Malur Hub"][(i % 5)],
    })

# 2. Farmer Users
for i in range(71, 96):
    farmer_no = i - 70
    users_data.append({
        "User Role": "Farmer",
        "Full Name": f"Farmer {farmer_no}",
        "Phone Number": f"+9198{i:08d}",
        "Default Test OTP": f"{100000 + ((+919800000000 + i) % 900000)}",
        "Customer ID / Identifier": f"FARM-{1000 + i}",
        "Customer Type": "Farmer (Producer)",
        "District / Region": ["Kolar Central", "Chickballapur", "Bangalore Rural"][(i % 3)],
    })

# 3. Aggregator Users
for i in range(96, 106):
    agg_no = i - 95
    users_data.append({
        "User Role": "Aggregator",
        "Full Name": f"Aggregator Hub {agg_no}",
        "Phone Number": f"+9198{i:08d}",
        "Default Test OTP": f"{100000 + ((+919800000000 + i) % 900000)}",
        "Customer ID / Identifier": f"AGG-{1000 + i}",
        "Customer Type": "Aggregator (Warehouse)",
        "District / Region": "Kolar Market Yard Hub",
    })

df_creds = pd.DataFrame(users_data)

excel_path = os.path.join(BASE_DIR, "agrilink_user_credentials.xlsx")

with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
    df_creds.to_excel(writer, sheet_name='User_Credentials', index=False)

print(f"[SUCCESS] Exported User Credentials Excel to: {excel_path}")
