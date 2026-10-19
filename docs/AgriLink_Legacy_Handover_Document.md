# PROJECT LEGACY & HANDOVER DOCUMENT
*Knowledge Transfer from Graduating Batch to the Next Student Team*

**Project Name:** AgriLink — Intelligent Farm-to-Customer Supply & Advisory Platform  
**Project Domain:** [ ] Robotics  [x] IoT  [x] AI  [x] ML  [ ] Deep Learning  
**Target Pilot Corridor:** Mandya ➔ North Bengaluru Corridor  
**Repository Path:** `c:\Users\Samskrutha\Desktop\agrilink_github`  

---

## 📑 Handover Structure at a Glance

| Page | Major Heading | Included Sections |
| :--- | :--- | :--- |
| **Page 1** | **PROJECT & PROBLEM** | **1. Project Overview** $\rightarrow$ **2. Problem Statement & Objectives** $\rightarrow$ **3. Project Evolution & Contributions** |
| **Page 2** | **SYSTEM & TECHNOLOGY** | **4. Existing Solution** $\rightarrow$ **5. Architecture & Modules** $\rightarrow$ **6. Technology Stack** $\rightarrow$ **7. AI/ML/DL/MML/RL** $\rightarrow$ **8. Full Stack** |
| **Page 3** | **IMPLEMENTATION & ACHIEVEMENTS** | **9. Current Status** $\rightarrow$ **10. Research & Academic Contributions** $\rightarrow$ **11. Repository & Resources** |
| **Page 4** | **HANDOVER & FUTURE WORK** | **12. Challenges & Lessons** $\rightarrow$ **13. Future Scope** $\rightarrow$ **14. Handover Plan** $\rightarrow$ **15. Team Information** |

---

# PAGE 1: PROJECT & PROBLEM

### 1. Project Overview
**AgriLink** is an intelligent digital marketplace and supply chain ecosystem designed to connect smallholder farmers directly with urban buyers, institutional canteens, and tech park communities. By eliminating predatory intermediary brokers and unorganized wholesale channels, AgriLink establishes a transparent, direct supply pipeline for fresh agricultural produce.

The platform provides a 4-in-1 digital solution:
1. **Farmer Digital Storefront & Advisory**: Enables rural growers to pre-list upcoming crop harvests and receive voice-guided farming guidance in their native language (Kannada, Hindi, Telugu, Malayalam).
2. **Rural Aggregation Hub Management**: Organizes local hubs where fresh produce is weighed, quality-graded (Grade A+, A, B), and packed efficiently.
3. **Smart Urban Marketplace**: Offers buyers personalized crop recommendations, transparent prices, and direct farm origin tracking.
4. **Optimized Logistics Dispatch**: Coordinates clean electric vehicles and local delivery riders to transfer produce from farm gate to kitchen within 12 hours.

---

### 2. Problem Statement & Objectives

#### The Challenge in Traditional Agriculture
Smallholder farmers in regions like Mandya face severe economic exploitation due to multi-layered commissions from village brokers, regional agents, and wholesalers. 

* **Income Erosion**: Farmers capture only **25% to 35%** of the end consumer rupee.
* **Post-Harvest Loss**: Transport delays and improper handling cause **22% to 30%** spoilage in fresh fruits and vegetables.
* **Information Barriers**: Farmers lack access to real-time market rates, demand forecasts, and scientific pest control solutions in their local dialects.

#### Core Project Objectives
* **Fair Revenue Sharing (68-10-14-8 Model)**: Ensure **68%** of the retail price goes directly to the farmer, **10%** to the rural aggregation hub, **14%** to clean delivery logistics, and **8%** to platform operations.
* **Price Transparency**: Calculate fair market prices using real-time market benchmarks combined with quality grades, organic status, and transit distance.
* **Direct Buyer-Seller Matching**: Reduce transit time to under 12 hours between harvest and consumer delivery.
* **Voice-First Accessibility**: Provide audio-based AI farming advice for rural users who prefer spoken language over text.

---

### 3. Project Evolution & Contributions

#### Key Milestones & Project Journey
1. **Phase 1 — Requirements & Field Survey**: Conducted field research across agricultural hubs in Mandya and consumer clusters in North Bengaluru (Hebbal, Yelahanka, Devanahalli). Formulated functional requirement specs for 5 user roles (`FARMER`, `BUYER`, `AGGREGATOR`, `DELIVERY_AGENT`, `ADMIN`).
2. **Phase 2 — Database Normalization & Schema Design**: Engineered a 3NF/BCNF relational database schema in Supabase PostgreSQL with 18 core tables and over 4,250 verified seed entries.
3. **Phase 3 — Multi-Stack API Gateway**: Developed FastAPI microservices in Python alongside alternative Node.js and Spring Boot Java backends for backend modularity.
4. **Phase 4 — AI & Machine Learning Integration**: Built a hybrid recommendation engine (LightFM collaborative filtering + TF-IDF content similarity) for personalized crop discovery, along with a voice-based advisory chatbot framework.
5. **Phase 5 — Cross-Platform Mobile & Web Client**: Implemented a responsive Flutter app supporting tailored dashboard views for Farmers, Buyers, Aggregators, and Delivery Agents.

---

# PAGE 2: SYSTEM & TECHNOLOGY

### 4. Existing Solution vs. AgriLink

| Feature / Dimension | Traditional APMC Mandi System | AgriLink Smart Marketplace |
| :--- | :--- | :--- |
| **Middlemen Layers** | 4 to 6 intermediary commission agents | 0 (Direct farmer-to-buyer transaction) |
| **Farmer Realization** | 25% – 35% of retail price | **68% guaranteed direct payout** |
| **Price Discovery** | Opaque negotiation by brokers | Algorithmic benchmark pricing + grade markup |
| **Transit Spoilage** | 25% – 30% perishability loss | Sub-12 hour direct dispatch (< 8% loss) |
| **Payment Cycle** | 45 to 60 days delayed credit | Automated digital payout upon delivery |
| **Advisory Access** | Infrequent extension visits | 24/7 Multilingual Voice & Speech AI Assistant |

---

### 5. Architecture & Modules

The platform adopts a multi-tier modular architecture:

```
+-----------------------------------------------------------------------------------+
|                        1. USER INTERACTION TIER (Flutter)                         |
|   [ Farmer App ]    [ Buyer Storefront ]    [ Hub Portal ]    [ Delivery App ]   |
+-----------------------------------------------------------------------------------+
                                          | REST APIs / JSON
+-----------------------------------------------------------------------------------+
|                           2. API GATEWAY TIER (FastAPI)                           |
|   - Authentication & Roles    - Order Processing    - Catalog & Inventory         |
+-----------------------------------------------------------------------------------+
                       /                  |                  \
                      /                   |                   \
+----------------------------+  +-------------------+  +----------------------------+
| 3. AI / ML ENGINE TIER     |  | 4. DATABASE TIER  |  | 5. LOGISTICS TIER          |
| - LightFM Recommender      |  | Supabase Postgres |  | - EV Fleet Route Dispatch  |
| - Multilingual Speech RAG  |  | 18 Live Tables    |  | - OTP Verification System  |
+----------------------------+  +-------------------+  +----------------------------+
```

#### Core Operational Modules
1. **Farmer Experience Module**: Harvest pre-declaration, batch listing, earnings tracking, and voice-assisted farming guidance.
2. **Buyer Experience Module**: Dynamic product catalog, personalized crop recommendations, cart checkout, and farm origin tracking.
3. **Hub & Aggregation Module**: Quality assay logging, sorting, crate management, and warehouse capacity monitoring.
4. **Logistics & Delivery Module**: Automated order assignment, route optimization, and digital proof-of-delivery via OTP.

---

### 6. Technology Stack

* **Frontend / User Interface**: Flutter (Dart) for Android/iOS/Web, HTML5/CSS3/JavaScript for static web previews.
* **Backend Frameworks**: Python FastAPI (Primary production server), Node.js Express (Secondary), Java Spring Boot (Enterprise alternative).
* **Database & Cloud Storage**: Supabase PostgreSQL (Relational schema with spatial extensions).
* **Machine Learning & AI Tools**: LightFM (Matrix Factorization), Scikit-Learn (TF-IDF & Cosine Similarity), Python Pandas/NumPy.
* **Voice & Conversational AI**: Speech-to-Text (Whisper ASR), IndicTrans2 (Translation), Sentence-Transformers + FAISS (Vector retrieval).

---

### 7. AI, Machine Learning & Voice Intelligence

#### 1. Hybrid Crop Recommendation Engine
Combines **Collaborative Filtering** (learning from historical purchases, views, and ratings) with **Content-Based Filtering** (matching crop attributes, organic status, and harvest freshness). 
* Provides personalized recommendations to returning buyers.
* Fallback to regional popularity rankings for new first-time users (cold-start mitigation).

#### 2. Multilingual Voice Advisory Chatbot
Designed to break literacy barriers for rural farmers through audio input and output:
* **Audio Input Processing**: Captures voice queries in local languages (Kannada, Hindi, Telugu, etc.) and converts speech to text.
* **Smart Knowledge Retrieval**: Searches verified agricultural knowledge bases (soil management, pest remedies, weather advisories) to retrieve factual answers without hallucination.
* **Voice Response**: Converts the plain-language response back to audio output in the farmer's native dialect.

---

### 8. Full Stack Integration

All system layers communicate seamlessly through lightweight HTTP REST endpoints:

1. **Order Placement**: When a customer places an order in the Flutter storefront, the request is validated by the FastAPI gateway.
2. **Database Updates**: FastAPI updates product stock levels, records transaction entries, and triggers escrow balance creation in Supabase PostgreSQL.
3. **Dispatch Trigger**: The system generates a pickup dispatch notification for the nearest Aggregator Hub and assigns an available electric vehicle delivery rider.
4. **Delivery Settlement**: Upon delivery, the customer provides a one-time passcode (OTP), which finalizes the order and immediately releases funds to the farmer's account.

---

# PAGE 3: IMPLEMENTATION & ACHIEVEMENTS

### 9. Current Project Status

#### Completed Milestones & Operational Assets
* **Live Relational Database**: Deployed on Supabase PostgreSQL with 18 fully normalized tables populated with over 4,250 records across North Bengaluru and Mandya test corridors.
* **Functional Cross-Platform App**: Complete Flutter codebase for desktop web and mobile clients featuring responsive designs for all 4 primary user personas.
* **Operational Microservice APIs**: FastAPI application serving endpoints for authentication, catalog management, order processing, and recommendation generation (`http://127.0.0.1:8000/docs`).
* **Trained ML Models**: Pre-trained LightFM matrix factorization model and TF-IDF index files saved and ready for real-time inference in `ml/`.

---

### 10. Research & Academic Contributions

#### 1. Literature Survey Synthesis
Conducted an in-depth survey of 8 published research papers spanning automated agricultural query systems, speech-driven LLMs, crop suitability prediction models, and cloud agri-marketplaces.

#### 2. Microeconomic Revenue Distribution Formula
Engineered the **68-10-14-8 Fair Distribution Model** to guarantee sustainable economics across all network participants:
$$\text{Farmer Payout} = 68\% \times \text{Consumer Retail Price}$$

#### 3. Algorithmic Price Discovery
Formulated dynamic fair pricing based on mandi market benchmarks, quality tier premiums ($\alpha_{\text{grade}}$), organic status ($\beta_{\text{organic}}$), and transit logistics costs ($C_{\text{transport}}$):
$$P_{\text{consumer}} = \frac{\text{APMC}_{\text{modal}} \times (1 + \alpha_{\text{grade}}) \times (1 + \beta_{\text{organic}}) + C_{\text{transport}}}{1 - 0.32}$$

---

### 11. Repository & Key Resources

#### Repository Layout Overview
* [`mobile_app/`](file:///c:/Users/Samskrutha/Desktop/agrilink_github/mobile_app/) — Main Flutter application codebase (Farmer, Buyer, Aggregator, Admin screens).
* [`backend_fastapi/`](file:///c:/Users/Samskrutha/Desktop/agrilink_github/backend_fastapi/) — Primary Python API gateway with ML recommendation integrations.
* [`ml/`](file:///c:/Users/Samskrutha/Desktop/agrilink_github/ml/) — Machine learning models, recommendation pipelines, and evaluation benchmarks.
* [`database/`](file:///c:/Users/Samskrutha/Desktop/agrilink_github/database/) — Supabase PostgreSQL SQL schemas, table definitions, and seed data.
* [`docs/`](file:///c:/Users/Samskrutha/Desktop/agrilink_github/docs/) — Complete academic papers, SRS documents, handover guides, and architecture blueprints.

#### Important Access Details
* **Supabase Database Project**: `https://nxwhnbejvwxiuekhtmpm.supabase.co`
* **Local Backend Entry Point**: `backend_fastapi/main.py`
* **Flutter Entry Point**: `mobile_app/lib/main.dart`

---

# PAGE 4: HANDOVER & FUTURE WORK

### 12. Challenges & Lessons Learned

1. **Rural Network Latency**: Variable internet connectivity in farm areas requires offline local caching for the mobile app, syncing updates when connection is restored.
2. **Perishable Inventory Timing**: Agricultural produce spoils quickly; real-time harvest time tracking is critical to prevent recommending older batches.
3. **Addressing Cold-Start for New Users**: New buyers with no purchase history receive curated regional top-sellers until interaction data is accumulated.
4. **Voice Recognition in Regional Accents**: Accurately capturing spoken agricultural terms requires audio pre-processing and localized vocabulary models.

---

### 13. Future Scope & Enhancement Roadmap

* **IoT Cold-Chain Telemetry**: Deploy low-cost temperature and humidity sensors in delivery crates and hub storage units to monitor produce freshness in real time.
* **Computer Vision Quality Grading**: Integrate mobile camera image recognition so aggregators can scan produce for automated grade scoring (Grade A+, A, B).
* **Blockchain Escrow Contracts**: Deploy smart contracts on low-cost networks (e.g., Polygon) for transparent automated payment release upon delivery confirmation.
* **Corridor Expansion**: Expand operations beyond the Mandya-Bengaluru corridor to major agricultural belts across South India.

---

### 14. Step-by-Step Handover Plan for Next Student Team

```
STEP 1: Clone Repository & Setup Python Environment
  ├── git clone <repo-url>
  ├── cd backend_fastapi
  └── pip install -r requirements.txt

STEP 2: Verify Supabase Database Connection
  ├── Open database/00_run_all.sql
  └── Verify live tables on Supabase Dashboard

STEP 3: Start the FastAPI API Server
  └── python -m uvicorn main:app --reload --port 8000

STEP 4: Run the Flutter Mobile App
  ├── cd mobile_app
  ├── flutter pub get
  └── flutter run -d chrome (or web-server)

STEP 5: Retrain & Test Recommendation Models
  ├── cd ml/
  └── python train_recommendation_model.py
```

---

### 15. Team Breakdown & Contributions

| Member Name | Key Module Ownership | Core Technical Focus |
| :--- | :--- | :--- |
| **Team Lead / Person 1** | `mobile_app/lib/screens/customer/` | Buyer experience, Flutter UI screens, web interface, customer checkout workflows. |
| **Backend Developer / Person 2** | `mobile_app/lib/screens/farmer/` & `backend_fastapi/` | Farmer user interface, FastAPI microservices, REST endpoints, auth security. |
| **AI & Database Architect / Person 3** | `database/` & `ml/` | Supabase 3NF schema, LightFM recommendation engine, voice advisory algorithms. |

---

> [!NOTE]
> *This Project Legacy & Handover Document summarizes the complete AgriLink system. For deep technical specifications, refer to [AgriLink_Technical_Report.md](file:///c:/Users/Samskrutha/Desktop/agrilink_github/AgriLink_Technical_Report.md) and [AgriLink_Comprehensive_Project_Report.md](file:///c:/Users/Samskrutha/Desktop/agrilink_github/docs/AgriLink_Comprehensive_Project_Report.md).*
