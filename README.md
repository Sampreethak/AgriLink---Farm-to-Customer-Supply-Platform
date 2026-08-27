# 🌾 AgriLink — Farm-to-Buyer Digital Marketplace

AgriLink connects farmers directly with buyers and aggregators, eliminating middlemen in agricultural trade.

## 📁 Repository Structure

| Folder | Description | Tech Stack |
|---|---|---|
| [`mobile_app/`](./mobile_app/) | Flutter mobile & web app (Customer, Farmer, Admin, Aggregator dashboards) | Flutter / Dart |
| [`backend_fastapi/`](./backend_fastapi/) | Primary Python API server with ML recommendation integration | FastAPI / Python |
| [`backend_java/`](./backend_java/) | Spring Boot REST API (alternative backend) | Java / Spring Boot |
| [`backend_nodejs/`](./backend_nodejs/) | Node.js Express API | Node.js / Express |
| [`ml/`](./ml/) | LightFM recommendation engine + benchmark evaluation | Python / LightFM |
| [`database/`](./database/) | Supabase PostgreSQL schema, migrations, seed data | SQL / Supabase |
| [`frontend_web/`](./frontend_web/) | Standalone HTML/JS/CSS web frontend | HTML / JS / CSS |
| [`docs/`](./docs/) | Project reports, handover documents, academic report | PDF / Markdown |

## 🚀 Quick Start

### 1. Database
```bash
# Run schema in Supabase SQL Editor
# https://supabase.com/dashboard/project/nxwhnbejvwxiuekhtmpm/editor
# Execute: database/00_run_all.sql
```

### 2. Backend (FastAPI)
```bash
cd backend_fastapi
pip install -r requirements.txt
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

### 3. Mobile App (Flutter)
```bash
cd mobile_app
flutter pub get
flutter run -d web-server --web-port 8080
```

## 👥 Team Breakdown

| Person | Owns | Focus Area |
|---|---|---|
| Person 1 | `mobile_app/lib/screens/customer/` | Customer buyer experience |
| Person 2 | `mobile_app/lib/screens/farmer/` + `backend_fastapi/` | Farmer seller experience + API |
| Person 3 | `database/` + `ml/` | Database schema + ML recommendations |

## 🔗 Live Backend
- Supabase Project: `https://nxwhnbejvwxiuekhtmpm.supabase.co`
- FastAPI Docs: `http://127.0.0.1:8000/docs`
- Flutter Web: `http://127.0.0.1:8080`
