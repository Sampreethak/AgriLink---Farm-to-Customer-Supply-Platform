# 🗄️ AgriLink — Database (Supabase / PostgreSQL)

All schema migrations, seed data, and SQL scripts for the AgriLink Supabase project.

## How to Run (Supabase SQL Editor)

1. Open: https://supabase.com/dashboard/project/nxwhnbejvwxiuekhtmpm/editor
2. Run scripts in this order:

```
01_extensions.sql       → Enable UUID, PostGIS extensions
02_enums.sql            → Role, status enums
03_master_tables.sql    → Core reference tables
04_user_tables.sql      → App users, roles
05_farmer_tables.sql    → Farmer profiles
06_aggregator_tables.sql
07_customer_tables.sql
08_inventory_tables.sql → Crop listings, inventory
09_order_tables.sql     → Orders and order items
10_delivery_tables.sql
11_payment_tables.sql
12_engagement_tables.sql → Reviews, interactions
...
21_seed_data.sql        → Dummy data for all tables
```

Or run everything at once:
```sql
-- Copy contents of 00_run_all.sql into SQL Editor and execute
```

## Tables (18 total)
`role`, `location`, `app_user`, `farmer_profile`, `customer_profile`, `aggregator_profile`, `crop_category`, `crop`, `inventory_item`, `seller_listing`, `customer_order`, `order_item`, `delivery`, `payment`, `user_interaction`, `customer_review`, `notification`, `categories`, `profiles`, `listings`

## Seed Data
- `supabase_master_seed_all_tables.sql` — Main seed file with valid hex UUIDs
- `21_seed_data.sql` — Extended dataset with 100+ records
