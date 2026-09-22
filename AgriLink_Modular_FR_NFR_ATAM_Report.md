# AgriLink: Module-by-Module Requirements Engineering & ATAM Report
**Granular Functional Requirements (FR), Module-Specific Non-Functional Requirements (NFR), and Dedicated FR–NFR Traceability Mappings per Module**  
*Vidyashilp University — School of Computational and Data Sciences | Course: Microservices & Software Architecture*

---

```
+-----------------------------------------------------------------------------------+
|                         9 CORE SYSTEM BUSINESS MODULES                            |
+-----------------------------------------------------------------------------------+
|  [Module 1: Farmer App]            ➔ Listing, Pre-Declaration, Dynamic Pricing    |
|  [Module 2: Aggregator Hub App]    ➔ Optical Assay, Grading, Batch Consolidation  |
|  [Module 3: Retail Customer App]   ➔ Search, PRF Expansion, AI Recommendations    |
|  [Module 4: Institutional B2B App] ➔ Bulk Quotas, Standing Orders (Hostel/Hospital)|
|  [Module 5: Logistics & Fleet App] ➔ Capacitated VRP Routing, OTP Proof Delivery  |
|  [Module 6: Dynamic Pricing Engine]➔ APMC Benchmarks, Fair-Share 68-10-14-8 Split |
|  [Module 7: AI/ML Recommendation]  ➔ NLP Voice, FP-Growth, Collaborative Filtering|
|  [Module 8: Payment & Blockchain]  ➔ Polygon L2 Smart Contract Escrow Vault       |
|  [Module 9: Admin & Governance]    ➔ RBAC, Dispute Arbitration, On-Chain Audit   |
+-----------------------------------------------------------------------------------+
```

---

# MODULE 1: Farmer Management & Crop Listing Module

## 1.1 Functional Requirements (FRs)
* **FR1.1 (Farmer Registration & Auth)**: Farmer shall register and login securely via Mobile OTP / biometric authentication.
* **FR1.2 (Profile & Farm Management)**: Farmer shall configure farm acreage, GPS coordinates, bank/UPI account, and soil profiles.
* **FR1.3 (Produce Addition & Listing)**: Farmer shall add crop listings with crop name, category, quantity (kg), price, and photos.
* **FR1.4 (Produce Edit & Status Toggle)**: Farmer shall edit listings, modify quantities, or mark produce as 'Currently Unavailable'.
* **FR1.5 (Harvest Pre-Declaration)**: Farmer shall pre-declare upcoming harvest volumes and dates up to 72 hours in advance.
* **FR1.6 (Dynamic Price Guidance)**: Farmer shall view real-time APMC benchmarks, quality grade multipliers, and 68% take-home realization.
* **FR1.7 (Inventory & Order Tracking)**: Farmer shall track active inventory and scheduled aggregator pickup slots.
* **FR1.8 (Earnings Dashboard)**: Farmer shall view real-time escrow releases, realized income statements, and UPI settlements.

## 1.2 Non-Functional Requirements (NFRs)
* **NFR1.1 (Performance)**: OTP generation and SMS/Voice dispatch shall complete in `< 3 seconds`; listing creation shall persist in `< 800 ms`.
* **NFR1.2 (Scalability)**: System shall support 5,000 concurrent farmer listing submissions during morning harvest hours.
* **NFR1.3 (Availability)**: Mobile app shall support offline local caching; listings sync automatically when rural connectivity resumes (99.9% uptime).
* **NFR1.4 (Security)**: Farmer credentials protected with SHA-256 OTP hashing; JWT RBAC prevents unauthorized access to bank/UPI details.
* **NFR1.5 (Reliability)**: Crop harvest metadata and image uploads must achieve 100% durable persistence with zero record loss.

## 1.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR1.1 – Farmer Auth** | **Security (NFR1.4)** | Enforce SHA-256 OTP hashing, rate-limit to 5 attempts/min, secure JWT token with 24-hr expiry. |
| **FR1.1 – Farmer Auth** | **Performance (NFR1.1)** | OTP generation and SMS delivery gateway callback shall complete in `< 3 seconds`. |
| **FR1.3 – Produce Listing** | **Availability (NFR1.3)** | Offline local SQLite caching allows drafting listings without active internet; auto-syncs on reconnect. |
| **FR1.3 – Produce Listing** | **Reliability (NFR1.5)** | Crop listing metadata and S3 image URLs committed with ACID database transaction guarantees. |
| **FR1.5 – Pre-Declaration** | **Scalability (NFR1.2)** | Pre-declaration ingestion queue handles 5,000 concurrent harvest submissions during harvest peaks. |
| **FR1.6 – Price Guidance** | **Performance (NFR1.1)** | APMC modal price and net 68% farmer realization calculation computes in `< 150 ms`. |
| **FR1.6 – Price Guidance** | **Security (NFR1.4)** | Price calculations cryptographically validated against Agmarknet feeds to prevent client manipulation. |
| **FR1.8 – Earnings Dashboard** | **Reliability (NFR1.5)** | Earnings calculations match exact on-chain smart contract escrow states with zero discrepancy. |

## 1.4 Module 1: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR1.1 (Auth & KYC)** | **X** | | | **X** | **X** |
| **FR1.2 (Farm Profile)** | | | **X** | **X** | **X** |
| **FR1.3 (Produce Listing)** | **X** | **X** | **X** | | **X** |
| **FR1.4 (Edit & Toggle)** | **X** | | **X** | | **X** |
| **FR1.5 (Pre-Declaration)** | **X** | **X** | **X** | | **X** |
| **FR1.6 (Price Guidance)** | **X** | **X** | **X** | **X** | |
| **FR1.7 (Order Tracking)** | **X** | | **X** | | **X** |
| **FR1.8 (Earnings Dashboard)** | **X** | | **X** | **X** | **X** |

---

# MODULE 2: Aggregator Hub & Quality Grading Module (PACS / Micro-Hubs)

## 2.1 Functional Requirements (FRs)
* **FR2.1 (Aggregator Auth & KYC)**: Aggregator partner shall register, complete FSSAI / business KYC verification, and login securely.
* **FR2.2 (Farmer Cohort Sourcing)**: Aggregator shall onboard and manage local farmer clusters within a 15–30 km catchment radius.
* **FR2.3 (Weighment & Optical Quality Assay)**: Aggregator shall record digital weighment and use AI image pre-grading to assign Quality Grade (A/B/C).
* **FR2.4 (Digital Assay Receipts)**: Aggregator shall generate digital assay certificates issued to farmers and linked to crate QR codes.
* **FR2.5 (Bulk Inventory Staging)**: Aggregator shall track holding crate stock, storage temperature, and micro-hub holding capacity.
* **FR2.6 (Batch Consolidation)**: Aggregator shall consolidate multi-farmer small batches into commercial wholesale lots.
* **FR2.7 (Dispatch & Vehicle Assignment)**: Aggregator shall assign lots to corridor transport vehicles and approve dispatch manifests.
* **FR2.8 (Reports & Commission Dashboard)**: Aggregator shall track processed volumes, quality pass rates, and realized 10% service commission.

## 2.2 Non-Functional Requirements (NFRs)
* **NFR2.1 (Performance)**: AI optical grading pre-classification shall return results in `< 1.2 seconds`; batch creation in `< 1.5 seconds`.
* **NFR2.2 (Scalability)**: Hub inventory service shall synchronize concurrent stock updates across 500+ rural micro-hubs without deadlocks.
* **NFR2.3 (Availability)**: Continuous 99.9% availability for intake and weighment logging during morning consolidation hours.
* **NFR2.4 (Security)**: Role-based access ensures only certified hub assayers can approve quality grades and manifest dispatches.
* **NFR2.5 (Reliability)**: Digital weighment and grading records must be cryptographically hashed and permanently auditable.

## 2.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR2.1 – Aggregator Auth** | **Security (NFR2.4)** | Enforce multi-factor auth; KYC documents verified against government business registers. |
| **FR2.3 – Quality Assay** | **Performance (NFR2.1)** | Edge/Cloud CNN classifier inference shall return Grade A/B/C and defect confidence in `< 1.2s`. |
| **FR2.4 – Assay Receipts** | **Security (NFR2.4)** | Assay certificate cryptographically signed with assayer ID and attached to immutable batch QR. |
| **FR2.5 – Bulk Inventory** | **Scalability (NFR2.2)** | Supports real-time synchronization across 500+ rural micro-hubs handling 100+ tonnes daily. |
| **FR2.6 – Consolidation** | **Reliability (NFR2.5)** | Batch consolidation transactions maintain ACID atomic guarantees preventing double-allocation of crates. |
| **FR2.7 – Dispatch Manifest** | **Performance (NFR2.1)** | Manifest generation and driver notification dispatch shall complete in `< 2 seconds`. |
| **FR2.8 – Commission** | **Reliability (NFR2.5)** | 10% service commission ledger calculation strictly reconciled with verified delivery OTPs. |

## 2.4 Module 2: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR2.1 (Auth & KYC)** | **X** | | | **X** | **X** |
| **FR2.2 (Cohort Sourcing)** | | **X** | **X** | **X** | |
| **FR2.3 (Quality Assay)** | **X** | | **X** | **X** | **X** |
| **FR2.4 (Assay Receipt)** | **X** | | **X** | **X** | **X** |
| **FR2.5 (Bulk Inventory)** | **X** | **X** | **X** | | **X** |
| **FR2.6 (Consolidation)** | **X** | **X** | | **X** | **X** |
| **FR2.7 (Dispatch Manifest)**| **X** | **X** | **X** | **X** | **X** |
| **FR2.8 (Commission)** | **X** | | **X** | **X** | **X** |

---

# MODULE 3: Retail Customer & Marketplace Module (B2C Individual Buyers)

## 3.1 Functional Requirements (FRs)
* **FR3.1 (Customer Auth)**: Retail customer shall register and login via Mobile OTP, Password, or OAuth (Google/Firebase).
* **FR3.2 (Catalog Browsing)**: Customer shall browse produce catalog categorized into Vegetables, Fruits, Grains, Spices, Dairy.
* **FR3.3 (Vernacular Search & PRF)**: Customer shall search produce using vernacular text/voice queries with PRF query expansion.
* **FR3.4 (AI Personalized Feed)**: Customer shall view dynamic personalized feeds ('Buy Again', 'Recommended For You', 'Trending').
* **FR3.5 (Cart Management)**: Customer shall add/remove items, adjust quantities, and view real-time 68-10-14-8 price waterfall.
* **FR3.6 (Order Placement & Slotting)**: Customer shall place orders, select delivery addresses, and choose scheduled delivery time slots.
* **FR3.7 (Escrow Payment Integration)**: Customer shall pay securely via UPI, Cards, Net Banking, or Wallet with funds held in escrow.
* **FR3.8 (Live Order Tracking)**: Customer shall track live delivery location, ETA, and cold-chain temperature telemetry.
* **FR3.9 (QR Provenance Verification)**: Customer shall scan packaging QR code to verify farm GPS origin and farmer payout percentage.
* **FR3.10 (Ratings & Reviews)**: Customer shall submit ratings and reviews for crop freshness, packaging, and delivery speed.

## 3.2 Non-Functional Requirements (NFRs)
* **NFR3.1 (Performance)**: Search queries & ML recs return in `< 500 ms`; order submission commits in `< 2.5 seconds`.
* **NFR3.2 (Scalability)**: Architecture shall support 10,000 concurrent active users browsing and shopping during peak morning hours.
* **NFR3.3 (Availability)**: Marketplace catalog browsing and checkout pipeline shall maintain 99.95% operational availability.
* **NFR3.4 (Security)**: PCI-DSS payment compliance; JWT session tokens with strict CSRF/XSS protection.
* **NFR3.5 (Reliability)**: Zero order loss (RPO = 0); payment webhooks must be strictly idempotent with automatic reconciliation.

## 3.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR3.2 – Catalog Browsing** | **Performance (NFR3.1)** | Catalog page load and image rendering shall complete in `< 400 ms` on standard 4G mobile networks. |
| **FR3.3 – Search & PRF** | **Performance (NFR3.1)** | 95% of text/voice queries with PRF query expansion shall return ranked results in `< 800 ms`. |
| **FR3.3 – Search & PRF** | **Scalability (NFR3.2)** | Search microservice scales horizontally to handle **10,000 concurrent client queries**. |
| **FR3.4 – AI Personalized Feed**| **Performance (NFR3.1)**| Multi-model recommendation pipeline (Buy Again, Collab, FP-Growth) streams in `< 300 ms`. |
| **FR3.4 – AI Personalized Feed**| **Reliability (NFR3.5)** | Gracefully falls back to category popular picks for cold-start users with zero purchase history. |
| **FR3.6 – Order Placement** | **Performance (NFR3.1)** | Order validation, stock reservation, and DB commit shall complete within `< 2.5 seconds`. |
| **FR3.6 – Order Placement** | **Security (NFR3.4)** | Only authenticated, active sessions with valid JWT claims can initiate checkout. |
| **FR3.6 – Order Placement** | **Reliability (NFR3.5)** | ACID transaction guarantees that stock is reserved without race conditions across concurrent buyers. |
| **FR3.7 – Escrow Payment** | **Security (NFR3.4)** | Payment tokens processed through PCI-DSS gateway; funds locked in non-custodial smart contract. |
| **FR3.9 – QR Provenance Check** | **Security (NFR3.4)** | QR code lookup cryptographically validates on-chain SHA-256 Merkle hash against Polygon L2. |

## 3.4 Module 3: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR3.1 (Auth)** | **X** | | | **X** | **X** |
| **FR3.2 (Catalog Browsing)** | **X** | **X** | **X** | | |
| **FR3.3 (Search & PRF)** | **X** | **X** | **X** | **X** | |
| **FR3.4 (AI Recs Feed)** | **X** | **X** | **X** | | **X** |
| **FR3.5 (Cart Management)** | **X** | **X** | **X** | **X** | **X** |
| **FR3.6 (Order Placement)** | **X** | **X** | **X** | **X** | **X** |
| **FR3.7 (Escrow Payment)** | **X** | **X** | **X** | **X** | **X** |
| **FR3.8 (Live Tracking)** | **X** | **X** | **X** | | **X** |
| **FR3.9 (QR Provenance)** | **X** | **X** | **X** | **X** | |
| **FR3.10 (Ratings/Reviews)** | **X** | | **X** | **X** | **X** |

---

# MODULE 4: Institutional B2B Procurement Module (Hostels, PGs & Hospitals)

## 4.1 Functional Requirements (FRs)
* **FR4.1 (Hostel Bulk Quota Ordering)**: Hostel procurement officer shall place high-volume wholesale orders (>500 kg) with tiered volume discounts.
* **FR4.2 (Recurring Standing Orders)**: Hostel shall configure automated weekly standing orders (e.g., 100 kg Onion every Mon/Thu).
* **FR4.3 (Meal Planning Demand Scheduler)**: Hostel shall schedule weekly meal requirements to automatically pre-book farm harvests.
* **FR4.4 (Multi-User Role Hierarchy)**: System shall support multi-user role hierarchy (Head Warden, Mess Manager, Purchase Officer).
* **FR4.5 (Hospital Departmental Ordering)**: Hospital shall place segregated produce orders for General Dietary, ICU Kitchen, and Staff Canteen.
* **FR4.6 (Quality Assurance & Organic Audit)**: Hospital shall inspect certified organic laboratory certificates and Grade-A quality assurance logs.
* **FR4.7 (Scheduled Early-Morning Deliveries)**: Hospital shall set strict time-window delivery constraints (e.g. before 6:30 AM daily).
* **FR4.8 (Consolidated Institutional Invoicing)**: Institutions shall receive consolidated monthly tax invoices with GST and credit reconciliation.

## 4.2 Non-Functional Requirements (NFRs)
* **NFR4.1 (Performance)**: Bulk orders (>1,000 kg) and recurring cron jobs process in `< 3 seconds` without impacting retail checkout latency.
* **NFR4.2 (Scalability)**: Institutional subsystem scales to handle 500+ institutional accounts managing recurring multi-tonne orders.
* **NFR4.3 (Availability)**: Scheduled standing order processing must achieve 99.99% availability with zero missed cron executions.
* **NFR4.4 (Security)**: Multi-user approval workflows with distinct RBAC permission tiers (Warden approval for orders > ₹50,000).
* **NFR4.5 (Reliability)**: Zero failure in scheduled supply commitments; automated failover to alternate hubs if primary hub lacks volume.

## 4.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR4.1 – Hostel Bulk Ordering**| **Scalability (NFR4.2)** | Processes multi-tonne institutional bulk requests asynchronously without locking retail inventory. |
| **FR4.2 – Standing Orders** | **Reliability (NFR4.5)** | Cron execution engine guarantees zero missed recurring order generations with idempotent triggers. |
| **FR4.3 – Meal Demand Scheduler**| **Performance (NFR4.1)** | Converts monthly menu plan into forward crop reservation manifests in `< 2 seconds`. |
| **FR4.4 – Multi-User Hierarchy** | **Security (NFR4.4)** | Enforces multi-tiered RBAC approval workflow with audit logging for all procurement sign-offs. |
| **FR4.6 – Hospital QA Audit** | **Security (NFR4.4)** | Lab test certificates and pesticide-free assay logs are tamper-evident with cryptographic verification. |
| **FR4.7 – Scheduled Deliveries** | **Reliability (NFR4.5)** | Route optimization engine locks early morning delivery slots with automated SMS priority dispatch. |

## 4.4 Module 4: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR4.1 (Bulk Quota Ordering)**| **X** | **X** | **X** | **X** | **X** |
| **FR4.2 (Standing Orders)** | **X** | **X** | **X** | | **X** |
| **FR4.3 (Meal Scheduler)** | **X** | **X** | **X** | | **X** |
| **FR4.4 (Multi-User Hierarchy)**| | | **X** | **X** | **X** |
| **FR4.5 (Dept Ordering)** | **X** | | **X** | **X** | **X** |
| **FR4.6 (QA & Organic Audit)** | | | **X** | **X** | **X** |
| **FR4.7 (Scheduled Deliveries)**| **X** | **X** | **X** | | **X** |
| **FR4.8 (Invoicing)** | **X** | | **X** | **X** | **X** |

---

# MODULE 5: Logistics, Routing & Delivery Fleet Module

## 5.1 Functional Requirements (FRs)
* **FR5.1 (Driver Auth & KYC)**: Delivery driver shall register, submit driving/vehicle documents, and login securely.
* **FR5.2 (Accept / Reject Delivery Tasks)**: Delivery driver shall receive, review, and accept/reject route delivery assignments.
* **FR5.3 (Capacitated VRP Route Navigation)**: Delivery driver shall access turn-by-turn multi-stop GPS navigation optimized for minimal fuel/time.
* **FR5.4 (Hub Pickup Confirmation)**: Delivery driver shall scan crate QR codes at rural hubs to confirm batch custody pickup.
* **FR5.5 (Transit Milestone & IoT Telemetry)**: Delivery driver shall update transit checkpoints (Out for Delivery, Arrived) and log cold-chain telemetry.
* **FR5.6 (OTP-Gated Proof of Delivery)**: Delivery driver shall verify customer OTP and capture photo proof to confirm successful drop-off.
* **FR5.7 (Driver Earnings & Payouts)**: Delivery driver shall view completed trips, distance bonuses, and realized 14% logistics payouts.

## 5.2 Non-Functional Requirements (NFRs)
* **NFR5.1 (Performance)**: Capacitated VRP route calculation for 50 collection/delivery nodes shall complete in `< 4 seconds`.
* **NFR5.2 (Scalability)**: Fleet service shall handle 2,000 concurrent driver GPS location pings per second without lag.
* **NFR5.3 (Availability)**: High availability of 99.9% for driver dispatch and live navigation routing services.
* **NFR5.4 (Security)**: Delivery OTP cryptographically verified; photo proof of delivery hashed and timestamped.
* **NFR5.5 (Reliability)**: OTP verification triggers atomic, non-reversible on-chain escrow release with zero duplicate payouts.

## 5.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR5.1 – Driver Auth & KYC** | **Security (NFR5.4)** | Driver KYC and vehicle registration verified; device binding prevents account sharing. |
| **FR5.3 – VRP Route Navigation** | **Performance (NFR5.1)** | Capacitated VRP batch optimization computes optimal 50-stop routes in `< 4 seconds`. |
| **FR5.4 – Hub Pickup Confirmation**| **Reliability (NFR5.5)** | QR barcode scan confirms physical custody transfer with atomic database state change. |
| **FR5.5 – Transit Telemetry** | **Scalability (NFR5.2)** | Ingests 2,000 driver GPS coordinates and IoT temperature telemetry pings per second. |
| **FR5.6 – OTP Proof of Delivery** | **Security (NFR5.4)** | Delivery OTP verified against SHA-256 hash; prevents false delivery completion claims. |
| **FR5.6 – OTP Proof of Delivery** | **Reliability (NFR5.5)** | Valid OTP match triggers single-execution smart contract escrow payout release (strictly idempotent). |

## 5.4 Module 5: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR5.1 (Driver Auth)** | **X** | | | **X** | **X** |
| **FR5.2 (Accept/Reject)** | **X** | | **X** | **X** | **X** |
| **FR5.3 (VRP Navigation)** | **X** | **X** | **X** | | **X** |
| **FR5.4 (Hub Pickup)** | **X** | **X** | **X** | **X** | **X** |
| **FR5.5 (IoT Telemetry)** | **X** | **X** | | **X** | **X** |
| **FR5.6 (OTP Proof of Delivery)**| **X** | | **X** | **X** | **X** |
| **FR5.7 (Driver Earnings)** | **X** | | **X** | **X** | **X** |

---

# MODULE 6: Dynamic Pricing & APMC Benchmark Engine

## 6.1 Functional Requirements (FRs)
* **FR6.1 (APMC Mandi Price Ingestion)**: Engine shall ingest daily APMC modal prices, arrivals, and variety indices from Agmarknet / e-NAM APIs.
* **FR6.2 (Quality & Organic Multipliers)**: Engine shall compute quality grading multipliers (+15% Grade A+, 0% Grade B, -10% Grade C) and organic premiums (+20%).
* **FR6.3 (Logistics Tariff Calculation)**: Engine shall compute distance decay and route energy transport costs over the 85 km corridor.
* **FR6.4 (Fair-Share Waterfall Computation)**: Engine shall calculate the exact 68-10-14-8 cost-plus waterfall and display it transparently to all actors.
* **FR6.5 (Dynamic Pricing Simulator)**: Engine shall provide interactive simulation sliders for testing pricing elasticity across demand shifts.

## 6.2 Non-Functional Requirements (NFRs)
* **NFR6.1 (Performance)**: Dynamic price calculation for any crop basket shall compute in `< 100 ms`.
* **NFR6.2 (Scalability)**: Real-time pricing engine scales to handle 15,000 price lookup requests per second across active shopping carts.
* **NFR6.3 (Availability)**: 99.95% availability with cached fallback to previous day modal benchmark if Agmarknet API is unreachable.
* **NFR6.4 (Security)**: Price calculation rules signed server-side; client cannot tamper with farm-gate or logistics fee splits.
* **NFR6.5 (Reliability)**: Financial calculation logic must maintain 100% mathematical precision with zero rounding leakage.

## 6.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR6.1 – APMC Ingestion** | **Availability (NFR6.3)** | Automated cron syncs daily mandi feeds at 05:00 AM; caches fallback values if upstream portal is slow. |
| **FR6.2 – Quality Multipliers** | **Performance (NFR6.1)** | Computes grade premium adjustments and organic markups in `< 50 ms`. |
| **FR6.4 – Fair-Share Waterfall** | **Reliability (NFR6.5)** | Enforces exact 68% Farmer, 10% Hub, 14% Logistics, 8% Platform allocation with zero decimal drift. |
| **FR6.4 – Fair-Share Waterfall** | **Security (NFR6.4)** | Price breakdown cryptographically hashed into batch quote preventing unauthorized client-side modification. |
| **FR6.5 – Pricing Simulator** | **Performance (NFR6.1)** | Interactive slider recalculates multi-role price splits in `< 80 ms`. |

## 6.4 Module 6: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR6.1 (APMC Ingestion)** | **X** | **X** | **X** | | **X** |
| **FR6.2 (Quality Multipliers)** | **X** | **X** | **X** | **X** | **X** |
| **FR6.3 (Logistics Tariff)** | **X** | **X** | **X** | | **X** |
| **FR6.4 (Fair Split Waterfall)**| **X** | **X** | **X** | **X** | **X** |
| **FR6.5 (Pricing Simulator)** | **X** | | **X** | **X** | |

---

# MODULE 7: AI/ML Recommendation & Demand Intelligence Engine

## 7.1 Functional Requirements (FRs)
* **FR7.1 (Speech-to-Text & NLP Entity Extraction)**: System shall execute multi-lingual speech-to-text and phonetic entity extraction for vernacular queries.
* **FR7.2 (PRF Query Expansion)**: System shall execute Pseudo-Relevance Feedback (PRF) to automatically expand sparse queries.
* **FR7.3 (Clickstream Telemetry Mining)**: System shall mine click-through logs and dwell time to compute implicit customer affinity weights.
* **FR7.4 (Buy Again Recommendation Engine)**: System shall generate personalized 'Buy Again' lists using Recency-Frequency-Monetary (RFM) scoring.
* **FR7.5 (Collaborative Filtering Engine)**: System shall compute collaborative filtering recommendations using Cosine Similarity on user-crop bipartite graphs.
* **FR7.6 (FP-Growth Basket Association)**: System shall compute market-basket co-occurrence cross-sells using FP-Growth association rule mining.
* **FR7.7 (Demand & Price Forecasting)**: System shall forecast regional 7-day crop demand and APMC modal prices (Random Forest + Prophet).

## 7.2 Non-Functional Requirements (NFRs)
* **NFR7.1 (Performance)**: Multi-model recommendation pipeline executes and returns in `< 300 ms`; PRF query expansion in `< 400 ms`.
* **NFR7.2 (Scalability)**: Recommendation engine scales to 10,000 concurrent personalized feed requests during morning shopping peaks.
* **NFR7.3 (Availability)**: 99.9% uptime with pre-computed Redis cache fallback for top-selling produce during heavy inference loads.
* **NFR7.4 (Security)**: User clickstream telemetry anonymized; recommendations respect user data privacy.
* **NFR7.5 (Reliability)**: Graceful fallback to category popularity for cold-start users with zero crash exceptions.

## 7.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR7.2 – PRF Query Expansion** | **Performance (NFR7.1)** | Extracts top co-occurring terms from Lucene/Vector index and re-ranks queries in `< 400 ms`. |
| **FR7.4 – Buy Again Engine** | **Performance (NFR7.1)** | Scans user purchase history logs and computes recency/frequency ranks in `< 100 ms`. |
| **FR7.5 – Collaborative Filtering**| **Scalability (NFR7.2)** | Pre-computes cosine similarity matrix offline; online inference executes in `< 150 ms`. |
| **FR7.5 – Collaborative Filtering**| **Reliability (NFR7.5)** | Cold-start fallback logic handles day-one buyers seamlessly without throwing null pointers. |
| **FR7.6 – FP-Growth Association** | **Performance (NFR7.1)** | Extracts association rules with Lift > 1.0 and generates live cross-sells in `< 80 ms` as cart updates. |
| **FR7.7 – Demand/Price Forecast** | **Performance (NFR7.1)** | Generates forward 7-day price and demand curves in `< 2 seconds` for farmer planning. |

## 7.4 Module 7: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR7.1 (NLP Voice Processing)** | **X** | | **X** | **X** | **X** |
| **FR7.2 (PRF Query Expansion)** | **X** | **X** | **X** | | |
| **FR7.3 (Clickstream Mining)** | **X** | **X** | | **X** | **X** |
| **FR7.4 (Buy Again RFM)** | **X** | **X** | **X** | | **X** |
| **FR7.5 (Collab Filtering)** | **X** | **X** | **X** | | **X** |
| **FR7.6 (FP-Growth Association)**| **X** | **X** | **X** | | **X** |
| **FR7.7 (Demand Forecasting)** | **X** | **X** | **X** | | **X** |

---

# MODULE 8: Payment Gateway & Blockchain Escrow Module

## 8.1 Functional Requirements (FRs)
* **FR8.1 (Payment Gateway Integration)**: Service shall process multi-rail customer payments via UPI, Credit/Debit Cards, Net Banking, and Wallets.
* **FR8.2 (On-Chain Price Anchoring)**: Service shall hash agreed batch prices, quality grades, and 68-10-14-8 splits into on-chain Merkle proofs.
* **FR8.3 (Smart Contract Escrow Vault)**: Service shall lock buyer funds in a non-custodial smart contract escrow vault upon order authorization.
* **FR8.4 (Automated Escrow Settlement)**: Service shall automatically execute the 68-10-14-8 payout split to farmer, hub, driver, and platform upon delivery OTP.
* **FR8.5 (Refund & Dispute Settlement)**: Service shall handle automated refunds for damaged or canceled items according to dispute resolution rules.

## 8.2 Non-Functional Requirements (NFRs)
* **NFR8.1 (Performance)**: Payment authorization completes in `< 2.5 seconds`; smart contract escrow execution confirms on Polygon L2 in `< 2 seconds`.
* **NFR8.2 (Scalability)**: Payment service handles 1,000 concurrent checkout transactions per second during flash sales.
* **NFR8.3 (Availability)**: 99.99% availability for payment gateway webhooks with automated secondary fallback.
* **NFR8.4 (Security)**: PCI-DSS compliant; private signing keys stored in secure Hardware Security Modules (HSM); non-tamperable on-chain ledger.
* **NFR8.5 (Reliability)**: ACID financial consistency; strictly idempotent payout webhooks (zero duplicate fund transfers).

## 8.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR8.1 – Payment Integration** | **Security (NFR8.4)** | PCI-DSS compliance with tokenized card data; encrypted UPI intent callbacks. |
| **FR8.2 – On-Chain Anchoring** | **Security (NFR8.4)** | Anchors SHA-256 Merkle root on Polygon L2; mathematically prevents price tampering by intermediaries. |
| **FR8.3 – Smart Contract Escrow**| **Reliability (NFR8.5)** | Non-custodial smart contract locks funds until cryptographic delivery OTP condition is satisfied. |
| **FR8.4 – Automated Settlement** | **Performance (NFR8.1)** | Smart contract transaction finality achieved in 2 seconds on Polygon Layer-2 with sub-cent gas fees ($0.001/tx). |
| **FR8.4 – Automated Settlement** | **Reliability (NFR8.5)** | Payout distribution is strictly idempotent, eliminating duplicate payment risk under network retries. |

## 8.4 Module 8: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR8.1 (Payment Gateways)** | **X** | **X** | **X** | **X** | **X** |
| **FR8.2 (On-Chain Hash Anchor)** | **X** | **X** | **X** | **X** | **X** |
| **FR8.3 (Escrow Vault)** | **X** | **X** | **X** | **X** | **X** |
| **FR8.4 (Automated Settlement)** | **X** | **X** | **X** | **X** | **X** |
| **FR8.5 (Refund Processing)** | **X** | | **X** | **X** | **X** |

---

# MODULE 9: Platform Administration, Governance & Analytics Module

## 9.1 Functional Requirements (FRs)
* **FR9.1 (User Management & RBAC)**: Admin shall manage user accounts, verify KYC documentation, and configure RBAC roles.
* **FR9.2 (Produce & Listing Approval)**: Admin shall review, approve, flag, or delist unverified or substandard crop listings.
* **FR9.3 (Live Order & Fleet Monitoring)**: Admin shall monitor active corridor dispatches, hub queues, and delivery fulfillment states in real-time.
* **FR9.4 (Dispute Resolution)**: Admin shall investigate customer complaints, quality disputes, and issue refund authorizations.
* **FR9.5 (System Configuration)**: Admin shall configure platform commission tariffs (8%), APMC sync intervals, and base logistics rates.
* **FR9.6 (Analytics & OLAP Dashboard)**: Admin shall view GMV analytics, farmer net realization index, corridor spoilage rates, and revenue reports.
* **FR9.7 (Blockchain Ledger Audit)**: Admin shall verify on-chain Merkle hashes, smart contract escrow states, and financial ledger audit trails.

## 9.2 Non-Functional Requirements (NFRs)
* **NFR9.1 (Performance)**: Analytics and OLAP reporting queries shall load executive dashboards in `< 2 seconds`.
* **NFR9.2 (Scalability)**: Analytics database (ClickHouse) scales to aggregate millions of transaction and telemetry records without slowdown.
* **NFR9.3 (Availability)**: Admin portal maintains 99.9% uptime with role-based session timeouts.
* **NFR9.4 (Security)**: Strict multi-factor authentication (MFA) required for Super Admin actions; immutable audit logs for all administrative actions.
* **NFR9.5 (Reliability)**: Financial ledger audits must reconcile 100% with bank settlement accounts and on-chain smart contract transactions.

## 9.3 Detailed FR $\rightarrow$ NFR Mapping Table
| Functional Requirement | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR9.1 – User Mgmt & RBAC** | **Security (NFR9.4)** | Strict RBAC controls prevent unauthorized privilege escalation; all admin actions recorded in tamper-proof audit log. |
| **FR9.3 – Live Fleet Monitoring**| **Performance (NFR9.1)**| WebSocket stream pushes live vehicle locations and hub queue states with `< 500 ms` latency. |
| **FR9.4 – Dispute Resolution** | **Reliability (NFR9.5)** | Dispute arbitration workflows maintain transactional integrity across inventory, refund, and payout ledgers. |
| **FR9.6 – Analytics Dashboard** | **Performance (NFR9.1)** | ClickHouse columnar queries aggregate multi-month GMV and farmer realization metrics in `< 1.5 seconds`. |
| **FR9.7 – Blockchain Audit** | **Security (NFR9.4)** | Directly queries Polygon L2 block explorer to cryptographically verify smart contract payout transactions. |

## 9.4 Module 9: FR–NFR Traceability Matrix
| Functional Requirement | Performance | Scalability | Availability | Security | Reliability |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR9.1 (User Mgmt/RBAC)** | | | **X** | **X** | **X** |
| **FR9.2 (Listing Approval)** | **X** | | **X** | **X** | **X** |
| **FR9.3 (Fleet Monitoring)** | **X** | **X** | **X** | **X** | **X** |
| **FR9.4 (Dispute Resolution)** | **X** | | **X** | **X** | **X** |
| **FR9.5 (System Config)** | | | **X** | **X** | **X** |
| **FR9.6 (Analytics Dashboard)** | **X** | **X** | **X** | **X** | **X** |
| **FR9.7 (Blockchain Audit)** | **X** | | **X** | **X** | **X** |
