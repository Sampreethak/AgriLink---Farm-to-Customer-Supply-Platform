# Software Architecture & Requirements Engineering Master Report: AgriLink
**Comprehensive SRS, Role-Wise Functional Requirements (FR1–FR57), Quality Attributes (NFRs), FR–NFR Traceability Mapping, ATAM Evaluation & Architecture Decision Records (ADRs)**  
*Vidyashilp University — School of Computational and Data Sciences | Course: Microservices & Software Architecture*  
*Platform: Multi-Role AgriTech Network (Farmer, Aggregator, Retail Customer, Hostel/PG, Hospital, Delivery Partner, Admin)*

---

# PART A: Software Requirements Specification (SRS)

## 1. Problem Statement
The agricultural supply chain in India is severely fragmented and hindered by 4–6 tiers of unregulated intermediaries (commission agents, dalals, regional brokers, sub-wholesalers). As a result, smallholder farmers realize only **25%–35%** of consumer expenditure, endure 45–60 day payment defaults, face total price opacity, and suffer **25%–30%** post-harvest perishable loss due to uncoordinated logistics. Concurrently, retail consumers and institutional buyers (college hostels, hospitals) pay inflated prices for unstandardized produce with zero origin traceability.

## 2. Project Objectives
1. **Disintermediate Agricultural Supply**: Directly connect smallholder farmers with village aggregation hubs, electric transport fleets, and retail/institutional buyers.
2. **Enforce Fair-Share Economics**: Implement a transparent, tamper-proof **68-10-14-8 revenue distribution** (68% Farmer, 10% Aggregator Hub, 14% Logistics, 8% Platform).
3. **Multi-Stakeholder ML Intelligence**: Deploy dedicated machine learning models for Farmer Price/Harvest Timing, Aggregator Vehicle Routing (VRP), and Customer Personalized Recommendations.
4. **Cryptographic Price Immutability**: Anchor APMC price benchmarks and payment escrow on a Layer-2 blockchain ledger to eliminate price manipulation.
5. **Ultra-Low Spoilage**: Optimize a 15–30 km rural catchment and 80–100 km corridor to cut transit loss from 28% to `<4%`.

## 3. System Stakeholders & Personas
1. **Farmers**: Primary producers cultivating crops, pre-declaring harvests, and tracking net earnings.
2. **Aggregators (PACS / Village Hubs / Micro-Entrepreneurs)**: Local partners performing digital weighment, optical quality grading (Grade A/B/C), crate consolidation, and dispatch.
3. **Clients / Buyers (Retail Consumers, Hostels, Hospitals)**: End consumers purchasing farm-fresh produce with scheduled or standing orders.
4. **Delivery Partners (Logistics Fleet)**: Electric vehicle drivers executing corridor transit and last-mile deliveries with OTP verification.
5. **Platform Administrators**: Governance team monitoring ecosystem health, ML pipelines, dispute arbitration, and ledger integrity.

## 4. System Scope
AgriLink encompasses a cross-platform mobile/web application (Flutter), an asynchronous microservices API gateway (FastAPI), an operational transactional database (Supabase PostgreSQL), a multi-model ML inference pipeline, and an immutable Layer-2 blockchain smart contract escrow mechanism across rural aggregation and urban consumption corridors.

---

# PART B: Granular Functional Requirements (FR1 – FR57)

```
+-----------------------------------------------------------------------------------+
|                         FUNCTIONAL REQUIREMENT MODULES                            |
+-----------------------------------------------------------------------------------+
|  [Module 1: Farmer App]            ➔ FR1 – FR10 (Listing, Pre-Declaration, Payout)|
|  [Module 2: Aggregator Hub App]    ➔ FR11 – FR18 (Assay, Grading, Consolidation)  |
|  [Module 3: Retail Customer App]   ➔ FR19 – FR28 (Search, AI Feed, QR Provenance) |
|  [Module 4: Hostel / PG B2B App]   ➔ FR29 – FR33 (Bulk Quota, Standing Orders)    |
|  [Module 5: Hospital B2B App]      ➔ FR34 – FR37 (QA Certificates, Scheduled Runs)|
|  [Module 6: Delivery Partner App]  ➔ FR38 – FR44 (VRP Routing, OTP Proof Delivery)|
|  [Module 7: Admin Portal]          ➔ FR45 – FR52 (RBAC, Ledger Audit, Disputes)  |
|  [Module 8: AI/ML Core Engines]    ➔ FR53 – FR57 (Price Forecast, VRP, Recs)     |
+-----------------------------------------------------------------------------------+
```

### 👨‍🌾 1. Farmer Application
* **FR1 (Farmer Auth & KYC)**: Farmer shall register and securely login via mobile OTP / password / biometric authentication.
* **FR2 (Profile & Farm Management)**: Farmer shall manage personal details, bank/UPI account, farm acreage, soil type, and location GPS coordinates.
* **FR3 (Produce Addition & Listing)**: Farmer shall create new crop listings specifying crop name, category, available quantity, unit, and photos.
* **FR4 (Produce Edit & Availability Toggle)**: Farmer shall edit, delete, or mark produce items as 'Currently Unavailable' / 'Out of Stock'.
* **FR5 (Harvest Pre-Declaration)**: Farmer shall pre-declare upcoming harvest volume and expected harvest date up to 72 hours in advance.
* **FR6 (Dynamic Price Guidance)**: Farmer shall view real-time APMC benchmark prices, grade multipliers, and estimated net 68% take-home payout.
* **FR7 (Farmer Inventory Tracking)**: Farmer shall monitor current listed vs sold inventory volumes in real-time.
* **FR8 (Farmer Order Monitoring)**: Farmer shall view incoming collection orders, assigned aggregator details, and scheduled pickup slots.
* **FR9 (Farmer Earnings Dashboard)**: Farmer shall view real-time breakdown of realized earnings, escrow payouts, and transaction history.
* **FR10 (Farmer Push & Voice Notifications)**: Farmer shall receive multi-lingual SMS/Push alerts for order confirmation, collection arrival, and payout credit.

### 🏢 2. Aggregator Application (PACS / Micro-Hubs)
* **FR11 (Aggregator Registration & Auth)**: Aggregator partner shall register, complete business/FSSAI KYC, and login securely.
* **FR12 (Farmer Cohort Sourcing)**: Aggregator shall register and manage local farmer profiles within a 15–30 km village catchment radius.
* **FR13 (Optical Quality Assay & Grading)**: Aggregator shall record digital weighment and use AI image pre-grading to assign Quality Grade (A/B/C).
* **FR14 (Digital Assay Receipt Generation)**: Aggregator shall generate digital assay and weighment certificates issued to farmer and attached to batch QR.
* **FR15 (Bulk Inventory Management)**: Aggregator shall track aggregated stock across holding crates and manage micro-hub staging.
* **FR16 (Batch Consolidation & Manifests)**: Aggregator shall consolidate multiple farmer micro-batches into commercial wholesale shipping lots.
* **FR17 (Dispatch & Vehicle Assignment)**: Aggregator shall assign consolidated batches to corridor transport vehicles and approve dispatch manifests.
* **FR18 (Aggregator Reports & Commission)**: Aggregator shall view handling volume metrics, quality pass rates, and realized 10% service fee earnings.

### 🛒 3. Retail Customer Application
* **FR19 (Customer Registration & Login)**: Retail customer shall register and login via Email/Password, Mobile OTP, or OAuth (Google/Firebase).
* **FR20 (Product Catalog Browsing)**: Customer shall browse agricultural produce categorized into Vegetables, Fruits, Grains, Spices, Dairy.
* **FR21 (Vernacular Search & PRF)**: Customer shall search products using text/voice queries with Pseudo-Relevance Feedback query expansion.
* **FR22 (Personalized AI Produce Feed)**: Customer shall view dynamic feeds including 'Buy Again', 'Recommended For You', and 'Trending Picks'.
* **FR23 (Cart Management)**: Customer shall add/remove produce, increment/decrement quantities, and view live fair-share price waterfall.
* **FR24 (Order Placement & Slotting)**: Customer shall place orders, select delivery addresses, and choose scheduled delivery time slots.
* **FR25 (Payment Gateway Integration)**: Customer shall pay via UPI, Debit/Credit Card, Net Banking, or Wallet with funds locked in escrow.
* **FR26 (Live Order & Cold-Chain Tracking)**: Customer shall track delivery driver location in real-time with live ETA and temperature status.
* **FR27 (QR Provenance Verification)**: Customer shall scan packaging QR code to verify on-chain farm origin GPS, harvest time, and farmer payout %.
* **FR28 (Ratings & Reviews)**: Customer shall submit ratings and reviews for crop freshness, packaging quality, and delivery speed.

### 🏢 4. Institutional Customer Application: Hostel / PG
* **FR29 (Hostel Bulk Quota Ordering)**: Hostel procurement manager shall place high-volume wholesale orders with custom weight specifications.
* **FR30 (Recurring Standing Orders)**: Hostel shall configure automated weekly standing orders (e.g. 50 kg Potato every Monday/Thursday).
* **FR31 (Meal Planning Demand Scheduler)**: Hostel shall schedule weekly meal requirements to automatically pre-book farm harvests.
* **FR32 (Multi-User Mess Management)**: Hostel shall support multi-user role hierarchy (Head Warden, Mess Manager, Purchase Officer).
* **FR33 (Consolidated Institutional Invoicing)**: Hostel shall receive consolidated tax invoices and credit statement summaries.

### 🏥 5. Institutional Customer Application: Hospital
* **FR34 (Department-Wise Ordering)**: Hospital shall place segregated produce orders for General Dietary, ICU Kitchen, and Canteen.
* **FR35 (Quality Assurance & Organic Audit)**: Hospital shall inspect certified organic laboratory certificates and Grade-A quality assurance logs.
* **FR36 (Scheduled Morning Deliveries)**: Hospital shall set strict time-window delivery constraints (e.g. before 6:30 AM daily).
* **FR37 (Monthly Invoice Reconciliation)**: Hospital shall access automated monthly purchase reconciliation with GST tax breakdown.

### 🚚 6. Delivery Partner Application
* **FR38 (Delivery Partner Auth & KYC)**: Delivery driver shall register, submit driving/vehicle documents, and login securely.
* **FR39 (Accept / Reject Delivery Tasks)**: Delivery driver shall receive, review, and accept/reject route delivery assignments.
* **FR40 (Capacitated VRP Route Navigation)**: Delivery driver shall access turn-by-turn multi-stop GPS navigation optimized for minimal fuel/time.
* **FR41 (Hub Pickup Confirmation)**: Delivery driver shall scan crate QR codes at rural hubs to confirm batch custody pickup.
* **FR42 (Transit Milestone & Telemetry Logging)**: Delivery driver shall update transit checkpoints (Out for Delivery, Arrived) and log IoT cold-chain data.
* **FR43 (OTP-Gated Proof of Delivery)**: Delivery driver shall verify customer OTP and capture photo proof to confirm successful drop-off.
* **FR44 (Driver Earnings & Payouts)**: Delivery driver shall view completed trips, distance bonuses, and realized 14% logistics payouts.

### 🛡️ 7. Platform Admin Portal
* **FR45 (User & Role Management)**: Admin shall manage user accounts across all roles (Farmer, Aggregator, Buyer, Driver) with RBAC permissions.
* **FR46 (Produce & Listing Approval)**: Admin shall review, approve, flag, or delist substandard or unverified crop listings.
* **FR47 (Live Order & Fleet Monitoring)**: Admin shall monitor all active corridor dispatches, hub queues, and delivery fulfillment states.
* **FR48 (Dispute Resolution & Ticket Management)**: Admin shall manage customer complaints, quality refunds, and driver delivery disputes.
* **FR49 (Dynamic Pricing & Commission Setup)**: Admin shall configure platform commission rules (8%), base logistics tariffs, and APMC sync feeds.
* **FR50 (Platform Analytics & Revenue Dashboard)**: Admin shall view gross merchandise value (GMV), farmer net realization, volume trends, and revenue.
* **FR51 (Inventory & Spoilage Auditing)**: Admin shall inspect micro-hub storage holding durations and track wastage metrics.
* **FR52 (Blockchain Ledger Audit)**: Admin shall verify on-chain Merkle hashes, smart contract escrow states, and financial ledger audit trails.

### 🧠 8. AI/ML Core Intelligence Engine
* **FR53 (APMC Price Trend Forecasting)**: ML engine shall predict forward commodity price peaks and seasonal mandi volatility (Random Forest + Prophet).
* **FR54 (Regional Demand Prediction)**: ML engine shall forecast forward buyer demand by crop and region to advise farmer sowing schedules.
* **FR55 (Multi-Model Product Recommendations)**: ML engine shall execute Buy-Again (RFM), Collaborative Cosine Similarity, and FP-Growth Association Rules.
* **FR56 (Optical Quality Grading Model)**: CV model shall classify fruit/vegetable quality grade and detect surface defects from uploaded imagery.
* **FR57 (Capacitated Vehicle Route Optimization)**: Optimization engine shall compute cost-minimal multi-stop vehicle routes for 15-30km rural pickups and 85km transit.

---

# PART C: Non-Functional Requirements (NFRs / Quality Attributes)

1. **NFR1 (Performance)**:
   - Latency `< 500 ms` for 95% of catalog search and ML recommendation API calls.
   - Dynamic price discovery calculation `< 150 ms`.
   - Order submission commit `< 2.5 s`.
2. **NFR2 (Scalability)**:
   - System shall support **10,000 concurrent active users** during morning peak hours.
   - Individual backend microservices scale horizontally and independently based on CPU/RAM thresholds.
3. **NFR3 (Availability)**:
   - High availability of **99.9% uptime** across core services.
   - Edge offline caching on mobile clients allows farmers to draft listings during rural 2G/3G disconnects.
4. **NFR4 (Security & Immutability)**:
   - Stateless JWT tokens with Role-Based Access Control (RBAC).
   - PostgreSQL Row-Level Security (RLS) ensuring strict cross-tenant data isolation.
   - Polygon Layer-2 SHA-256 Merkle proof anchoring preventing retroactive price alterations.
5. **NFR5 (Reliability & Data Integrity)**:
   - ACID transaction guarantees with Zero Data Loss (RPO = 0).
   - Strictly idempotent payment and escrow release webhooks.
6. **NFR6 (Maintainability)**:
   - Containerized Docker microservices with automated CI/CD build and testing pipelines.

---

# PART D: Exhaustive FR $\rightarrow$ NFR Detailed Quality Specification Mapping

| Functional Requirement (FR) | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR1 – Farmer Auth & KYC** | **NFR4: Security** | SHA-256 OTP hashing; rate limit to 5 login attempts per minute per IP; encrypted storage of KYC documents. |
| **FR1 – Farmer Auth & KYC** | **NFR1: Performance** | SMS/Voice OTP dispatch and verification roundtrip shall complete in `< 3 seconds`. |
| **FR3 – Produce Listing** | **NFR3: Availability** | Farmer app shall support offline local SQLite caching; auto-syncs when 2G/3G connectivity resumes. |
| **FR3 – Produce Listing** | **NFR5: Reliability** | Crop photos and metadata must be persisted across multi-zone S3 object storage with zero loss. |
| **FR6 – Dynamic Price Guidance** | **NFR1: Performance** | Real-time APMC benchmark and 68% take-home calculation shall compute and render in `< 150 ms`. |
| **FR6 – Dynamic Price Guidance** | **NFR4: Security** | Price calculations cryptographically signed against official Agmarknet mandi feeds to prevent client manipulation. |
| **FR9 – Farmer Earnings Dashboard** | **NFR5: Reliability** | Ledger query must guarantee ACID consistency matching exact on-chain smart contract escrow states. |
| **FR13 – Optical Quality Assay** | **NFR1: Performance** | AI computer-vision pre-grading inference shall classify Grade A/B/C in `< 1.2 seconds`. |
| **FR15 – Bulk Inventory Staging** | **NFR2: Scalability** | Hub inventory service shall synchronize concurrent stock updates across 500+ rural micro-hubs without deadlocks. |
| **FR20 – Catalog Browsing** | **NFR1: Performance** | Catalog listing page load time shall be `< 400 ms` on standard 4G mobile networks. |
| **FR21 – Vernacular Search & PRF** | **NFR1: Performance** | 95% of text/voice queries with PRF query expansion shall return results within `< 800 ms`. |
| **FR21 – Vernacular Search & PRF** | **NFR2: Scalability** | Search engine shall support **10,000 concurrent client queries** during peak morning shopping hours. |
| **FR21 – Vernacular Search & PRF** | **NFR3: Availability** | Product search and catalog browsing services shall remain available **99.9% of the time**. |
| **FR22 – AI Personalized Feed** | **NFR1: Performance** | Multi-model background recommendations (Buy Again, Collab, FP-Growth) shall execute in `< 300 ms`. |
| **FR22 – AI Personalized Feed** | **NFR5: Reliability** | In cold-start scenarios with zero history, engine shall gracefully fallback to category popularity without errors. |
| **FR24 – Order Placement** | **NFR1: Performance** | Order submission, stock lock, and database commitment shall complete in `< 2.5 seconds`. |
| **FR24 – Order Placement** | **NFR4: Security** | Only authenticated and verified customer sessions with valid JWT tokens can initiate checkout. |
| **FR24 – Order Placement** | **NFR5: Reliability** | Accepted orders shall never be lost during network partitions (ACID write-ahead logging). |
| **FR24 – Order Placement** | **NFR3: Availability** | The checkout and order placement pipeline shall maintain **99.95% operational uptime**. |
| **FR25 – Escrow Payment** | **NFR4: Security** | PCI-DSS compliant payment gateway integration; funds locked in non-custodial smart contract vault. |
| **FR25 – Escrow Payment** | **NFR5: Reliability** | Payment callbacks shall be strictly idempotent; network drops trigger automated reconciliation in `< 60s`. |
| **FR27 – QR Provenance** | **NFR4: Security** | QR code verification links directly to immutable on-chain SHA-256 Merkle transaction hash. |
| **FR29 – Hostel Bulk Ordering** | **NFR2: Scalability** | Bulk order service shall process institutional orders of `>1,000 kg` without impacting retail checkout latency. |
| **FR30 – Recurring Standing Orders** | **NFR5: Reliability** | Automated cron triggers for recurring orders must execute with zero missed scheduled procurement events. |
| **FR35 – Hospital QA Audit** | **NFR4: Security** | Quality assurance and lab test certificates shall be tamper-evident with cryptographic verification. |
| **FR40 – VRP Route Navigation** | **NFR1: Performance** | Capacitated VRP route calculation for 50 collection/delivery nodes shall complete in `< 4 seconds`. |
| **FR43 – OTP Proof of Delivery** | **NFR4: Security** | Delivery OTP verification cryptographically authenticated; valid match executes atomic on-chain payout split. |
| **FR43 – OTP Proof of Delivery** | **NFR5: Reliability** | Settlement release trigger guarantees single-execution payout dispatch (zero duplicate fund transfers). |
| **FR45 – Admin User Management** | **NFR4: Security** | Role-Based Access Control (RBAC) strictly prevents unauthorized privilege escalation to Super Admin. |
| **FR52 – Blockchain Ledger Audit** | **NFR4: Security** | Complete financial ledger audit trail verifies exact 68-10-14-8 split on Polygon L2 explorer. |
| **FR53 – APMC Price Forecasting** | **NFR1: Performance** | Time-series forecasting inference shall generate forward 7-day price corridors in `< 2 seconds`. |
| **FR56 – Optical CV Quality Model** | **NFR1: Performance** | Edge/Cloud CNN image classifier inference shall process defect segmentation in `< 1.5 seconds`. |

---

# PART E: High-Level FR–NFR Traceability Matrix

| Functional Requirement Module | Performance (NFR1) | Scalability (NFR2) | Availability (NFR3) | Security (NFR4) | Reliability (NFR5) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **FR1 – FR10 (Farmer App Suite)** | **X** | **X** | **X** | **X** | **X** |
| **FR11 – FR18 (Aggregator App Suite)** | **X** | **X** | **X** | **X** | **X** |
| **FR19 – FR28 (Retail Customer Suite)** | **X** | **X** | **X** | **X** | **X** |
| **FR29 – FR33 (Hostel / PG Institutional)** | **X** | **X** | **X** | **X** | **X** |
| **FR34 – FR37 (Hospital Institutional)** | **X** | | **X** | **X** | **X** |
| **FR38 – FR44 (Delivery Partner Suite)** | **X** | **X** | **X** | **X** | **X** |
| **FR45 – FR52 (Admin Governance Suite)** | **X** | | **X** | **X** | **X** |
| **FR53 – FR57 (AI/ML & Optimization)** | **X** | **X** | **X** | | **X** |

---

# PART F: Backend Microservices & Architecture Breakdown (13 Services)

1. **Authentication Service**: User Registration, Password Reset, OTP Verification, JWT Tokens, RBAC (Farmer, Aggregator, Buyer, Driver, Admin).
2. **Product Service**: Crop Taxonomy, Category Management, Product Images (S3), Inventory Status, Availability Toggles.
3. **Order Service**: Order Creation, State Machine (`Pending` $\rightarrow$ `Confirmed` $\rightarrow$ `Packed` $\rightarrow$ `Assigned` $\rightarrow$ `Out for Delivery` $\rightarrow$ `Delivered`), History.
4. **Payment Service**: Payment Gateways (Razorpay, UPI, Stripe), Refund Management, Invoicing, Escrow Ledger Splits.
5. **Delivery Service**: Driver Assignment, Capacitated VRP Route Planning, Live Tracking, Delivery Confirmation, OTP Validation.
6. **Notification Service**: Multi-channel alerts via Firebase Cloud Messaging (FCM Push), Twilio SMS, SendGrid Email.
7. **Review & Rating Service**: Produce Quality Ratings, Customer Reviews, Aggregator Quality Assay Feedback.
8. **Recommendation Service**: Multi-Model Personalization (Buy Again, Collaborative Filtering, FP-Growth Association, Trending).
9. **Pricing Service (APMC)**: Real-time APMC Price Integration (e-NAM/Agmarknet), Quality Multipliers, Fair-Share Calculator.
10. **Inventory Service**: Micro-hub Stock Management, Crate Allocations, Low Stock Alerts, Shelf-Life & Expiry Tracking.
11. **Aggregator Service**: Collection Center Coordination, Digital Weighment, Batch Consolidation, Wholesale Lot Manifests.
12. **Chat / Support Service**: In-app Customer & Farmer Support Chat, Ticket Management, Dispute Escalation.
13. **Analytics Service**: Sales Analytics, Farmer Realization Index, Spoilage Tracking, ClickHouse OLAP Reporting.

---

# PART G: Architecture Tradeoff Analysis Method (ATAM)

## 1. System-Wide Architectural Style Comparison

| Quality Attribute | Monolithic Architecture | Pure Microservices | Layered Hybrid Microservices | Serverless FaaS |
| :--- | :--- | :--- | :--- | :--- |
| **Performance (Latency)** | High (In-process memory) | Medium (Network hops) | **High (API Gateway + Redis)** | Medium (Cold starts) |
| **Scalability** | Low–Medium (Scale all) | **Very High (Independent)** | **High (Independent scaling)** | **Very High (Elastic)** |
| **Availability & Fault Isolation** | Low (Single point failure) | **High (Fault-isolated)** | **High (Circuit breaker + Fallback)** | **High (Managed infra)** |
| **Reliability & ACID Consistency** | **Very High (Single ACID DB)** | Medium (Distributed Tx) | **High (PostgreSQL Core + Outbox)** | Medium (Eventual) |

---

## 2. ATAM Trade-Off Table: FR21 — Product Search & PRF Query Expansion

| Quality Attribute | Monolithic Architecture | Microservices Architecture | ATAM Architectural Observation |
| :--- | :---: | :---: | :--- |
| **Performance** | High | Medium–High | Microservices introduce minor gateway network hops but allow dedicated vector search compute. |
| **Scalability** | Medium | **High** | Morning search traffic surges scale search instances independently without duplicating heavy modules. |
| **Availability** | Medium | **High** | Outages in Payment or Logistics services do not prevent product search or browsing. |
| **Security** | High | High | Both architectures implement strict JWT validation and API rate limiting. |

---

## 3. ATAM Trade-Off Table: FR24 — Place Order & Checkout

| Quality Attribute | Monolithic Architecture | Microservices Architecture | ATAM Architectural Observation |
| :--- | :---: | :---: | :--- |
| **Performance** | Lower under heavy load | **Medium–High** | Asynchronous message queueing prevents database locking during sudden checkout surges. |
| **Scalability** | Scale whole app | **High** | Order Service and Payment Service scale independently based on transaction throughput. |
| **Availability** | Medium | **High** | Order placement remains operational even if analytics or recommendations are temporarily offline. |
| **Security** | High | High | Centralized API gateway enforces strict token validation and rate limiting. |
| **Reliability** | High (Single DB) | **High\*** | Uses Transactional Outbox Pattern to guarantee ACID consistency across distributed events. |

---

# PART H: Architecture Decision Records (ADRs)

### ADR 1: Adoption of API Gateway with Layered Microservices Architecture
* **Status**: **ACCEPTED**
* **Context**: AgriLink serves 5 distinct stakeholder roles with vastly different traffic patterns. A monolithic design would suffer single-point failures and require wasteful full-app scaling.
* **Decision**: Adopt an API Gateway with Layered Asynchronous Microservices (FastAPI backend microservices + Redis cache + Supabase PostgreSQL).
* **Positive Consequences**: Independent scaling of high-throughput services (Search, ML); fault isolation; independent CI/CD pipelines.
* **Negative Consequences**: Minor inter-service network overhead; requires distributed logging and tracing.

---

### ADR 2: Hybrid Relational Database (PostgreSQL) with Transactional Outbox Pattern
* **Status**: **ACCEPTED**
* **Context**: Pure database-per-service microservices introduce extreme distributed transaction bugs for multi-entity financial settlements.
* **Decision**: Adopt Supabase PostgreSQL with schema-level isolation and Row-Level Security (RLS) combined with an Event-Driven Transactional Outbox Pattern.
* **Positive Consequences**: Preserves ACID guarantees for 68-10-14-8 financial payouts; eliminates 2PC distributed transaction overhead.
* **Negative Consequences**: Requires disciplined schema boundary maintenance to avoid tight relational coupling.

---

### ADR 3: Dual-Layered Trust via Polygon Layer-2 Blockchain for Price Immutability & Escrow
* **Status**: **ACCEPTED**
* **Context**: Farmers require an incorruptible trust guarantee that agreed farm-gate prices and payout splits cannot be retroactively altered by middlemen or administrators.
* **Decision**: Integrate Polygon Layer-2 Smart Contracts to anchor daily APMC price Merkle hashes and automate non-custodial payment escrow release upon delivery OTP verification.
* **Positive Consequences**: Cryptographic non-repudiation; zero-default automated farmer payouts; verifiable consumer packaging QR provenance.
* **Negative Consequences**: Smart contract gas fees (mitigated by Polygon L2 sub-cent costs $< \$0.001$/tx) and Web3 RPC management.
