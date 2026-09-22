# Software Architecture & Requirements Engineering Report: AgriLink
**SRS, Non-Functional Requirements Mapping, ATAM Evaluation & Architecture Decision Records (ADRs)**  
*Vidyashilp University — School of Computational and Data Sciences | Course: Microservices & Software Architecture*

---

# PART A: Software Requirements Specification (SRS)

## 1. Problem Statement
Smallholder farmers in India face systemic market failures within traditional Agricultural Produce Market Committee (APMC) mandi supply chains. Due to 4–6 tiers of unregulated intermediaries (commission agents, brokers, sub-wholesalers), farmers capture only **25%–35%** of the consumer rupee, while facing extreme price opacity, lack of demand forecasting, delayed payments (45–60 days), and post-harvest transit spoilage exceeding **25%–30%**. Urban consumers and bulk buyers (hostel messes, hospitals) simultaneously pay inflated retail markups for unstandardized produce with zero origin traceability.

## 2. Project Objectives
1. **Disintermediate Agricultural Supply**: Directly connect smallholder farmers with village aggregation hubs, electric transport fleets, and retail/institutional buyers.
2. **Enforce Fair-Share Economics**: Implement a transparent, tamper-proof **68-10-14-8 revenue distribution** (68% Farmer, 10% Aggregator Hub, 14% Logistics, 8% Platform).
3. **Multi-Stakeholder ML Intelligence**: Deploy dedicated machine learning models for Farmer Price/Harvest Timing, Aggregator Vehicle Routing (VRP), and Customer Personalized Recommendations.
4. **Cryptographic Price Immutability**: Anchor APMC price benchmarks and payment escrow on a Layer-2 blockchain ledger to eliminate price manipulation.
5. **Ultra-Low Spoilage**: Optimize a 15–30 km rural catchment and 80–100 km corridor to cut transit loss from 28% to `<4%`.

## 3. System Stakeholders
1. **Farmers**: Primary producers listing crops, declaring upcoming harvests, and tracking fair-price realization.
2. **Aggregators (PACS / Village Hubs / Micro-Entrepreneurs)**: Local partners performing digital weighment, optical quality grading (Grade A/B/C), crate consolidation, and dispatch.
3. **Clients / Buyers (Retail Consumers, Hostel Messes, Hospital Canteens)**: End consumers purchasing farm-fresh produce with scheduled or standing orders.
4. **Delivery Partners (Logistics Fleet)**: Electric vehicle drivers executing corridor transit and last-mile deliveries with OTP verification.
5. **Platform Administrators**: Governance team monitoring ecosystem health, ML inference pipelines, dispute arbitration, and ledger integrity.

## 4. System Scope
AgriLink encompasses a cross-platform mobile/web application (Flutter), an asynchronous microservices API gateway (FastAPI), an operational transactional database (Supabase PostgreSQL), a multi-model ML inference pipeline, and an immutable Layer-2 blockchain smart contract escrow mechanism across rural aggregation and urban consumption corridors.

---

# PART B: Functional Requirements (FRs)

The system fulfills **18 detailed Functional Requirements** partitioned across the five core system actors:

### 1. Farmer Module
* **FR1 (Farmer Authentication & KYC)**: The system shall allow farmers to register, authenticate via mobile OTP/voice credentials, and manage farm profiles (land acreage, geo-coordinates, crop specializations).
* **FR2 (Crop Harvest Pre-Declaration & Listing)**: The system shall enable farmers to pre-declare harvest schedules (crop type, expected yield in kg, harvest date, vernacular voice/photo notes) up to 72 hours in advance.
* **FR3 (Dynamic Price Discovery & Realization Guidance)**: The system shall display real-time APMC modal prices, quality grade multipliers, and estimated take-home realization (68% net payout breakdown).
* **FR4 (Order Tracking & Instant Escrow Settlement)**: The system shall provide real-time batch lifecycle status (`Declared` $\rightarrow$ `Aggregated` $\rightarrow$ `In-Transit` $\rightarrow$ `Delivered`) and notify farmers upon instant UPI escrow payout release.

### 2. Aggregator Module
* **FR5 (Farmer Sourcing & Cohort Management)**: The system shall allow aggregators to onboard local farmers within a 15–30 km catchment radius and manage village-level producer cohorts.
* **FR6 (Batch Weighment & Optical Quality Assay)**: The system shall record digital weighment data, capture produce imagery for AI/manual grading (Grade A/B/C), and issue digital assay receipts.
* **FR7 (Inventory & Micro-Hub Staging)**: The system shall track real-time physical holding inventory across village collection points and manage crate allocations.
* **FR8 (Batch Consolidation & Dispatch Approval)**: The system shall aggregate small farmer batches into commercial wholesale lots and approve manifests for corridor vehicle loading.

### 3. Client / Buyer Module
* **FR9 (Client Registration & Role Profile)**: The system shall allow retail consumers and institutional procurement managers (Hostels, Hospitals) to register and configure delivery profiles.
* **FR10 (Multi-Lingual Search & PRF Query Expansion)**: The system shall execute vernacular text/voice search with Pseudo-Relevance Feedback (PRF) for semantic produce discovery.
* **FR11 (AI-Driven Personalized Produce Feed)**: The system shall generate multi-model recommendations including *Buy Again* (Recency/Frequency), *Recommended For You* (Cosine Collaborative), and *Frequently Bought Together* (FP-Growth).
* **FR12 (Cart Management & Multi-Tier Ordering)**: The system shall support regular retail shopping, standing recurring orders for institutions, and emergency bulk procurement.
* **FR13 (Secure Checkout & Non-Custodial Escrow Payment)**: The system shall process payments via UPI/cards/net-banking and lock funds in a smart contract escrow vault until delivery.
* **FR14 (Real-Time Order Tracking & QR Provenance)**: The system shall provide live dispatch tracking and render cryptographic QR provenance details (farm origin GPS, harvest time, farmer payout share).

### 4. Delivery Partner Module
* **FR15 (Dynamic Delivery Assignment & VRP Routing)**: The system shall dispatch optimized route manifests to drivers using Capacitated Vehicle Routing Problem (VRP) algorithms.
* **FR16 (Transit Status & Cold-Chain Telemetry)**: The system shall allow drivers to update transit milestones and log temperature/sensor checkpoints.
* **FR17 (OTP-Gated Proof of Delivery)**: The system shall require customer OTP verification at drop-off to validate delivery and automatically trigger escrow fund disbursement.

### 5. Platform Admin Module
* **FR18 (User Governance & Dispute Arbitration)**: The system shall allow administrators to verify KYC, monitor platform health, resolve quality disputes, and inspect the immutable 68-10-14-8 financial ledger.

---

# PART C: Non-Functional Requirements (NFRs) & Quality Attributes

The system architecture prioritizes **6 core Quality Attributes**:

```
+-----------------------------------------------------------------------------------+
|                        CORE QUALITY ATTRIBUTES (NFRs)                             |
+-----------------------------------------------------------------------------------+
|  [NFR1: Performance]   ➔ Latency, throughput, ML sub-50ms inference, rapid search |
|  [NFR2: Scalability]   ➔ Peak concurrency, independent microservice auto-scaling |
|  [NFR3: Availability]  ➔ 99.9% uptime, zero single-point-of-failure, resilience   |
|  [NFR4: Security]      ➔ JWT Auth, RLS data isolation, Polygon L2 tamper-proofing |
|  [NFR5: Reliability]   ➔ ACID transactions, zero-loss queues, escrow consistency |
|  [NFR6: Maintainability]➔ Modular services, loose coupling, automated CI/CD       |
+-----------------------------------------------------------------------------------+
```

### Precise NFR Quality Metric Definitions:
* **NFR1 (Performance)**:
  - *P1*: 95% of product search and ML recommendation API requests shall return in `< 500 ms` under standard operating load.
  - *P2*: Dynamic pricing simulation calculations shall execute in `< 100 ms`.
  - *P3*: End-to-end checkout and order placement submission shall complete in `< 2.5 seconds`.
* **NFR2 (Scalability)**:
  - *S1*: Product search, catalogue browsing, and telemetry logging shall support up to **10,000 concurrent active users** during harvest peak hours without performance degradation.
  - *S2*: Individual microservices (Recommendation, Order, Payment) shall scale horizontally and independently based on CPU/memory thresholds.
* **NFR3 (Availability)**:
  - *A1*: The platform API gateway and customer-facing interfaces shall maintain **99.9% operational availability** (less than 8.76 hours of unplanned downtime per year).
  - *A2*: Edge offline caching shall enable farmers to draft listings even during intermittent rural 2G/3G network drops.
* **NFR4 (Security & Immutability)**:
  - *SEC1*: All API communications shall be encrypted in transit via TLS 1.3 and authenticated using stateless JWT tokens with role-based access control (RBAC).
  - *SEC2*: Database records shall enforce PostgreSQL Row-Level Security (RLS) preventing cross-tenant data leakage.
  - *SEC3*: All agreed crop pricing benchmarks, batch hashes, and escrow splits shall be anchored on-chain with cryptographic SHA-256 non-repudiation.
* **NFR5 (Reliability & Data Integrity)**:
  - *R1*: Accepted orders and financial escrow transactions shall achieve **zero data loss** (RPO = 0) through ACID-compliant database write-ahead logging and distributed message queues.
  - *R2*: Payout disbursement operations shall be strictly idempotent to prevent duplicate fund transfers.
* **NFR6 (Maintainability & Extensibility)**:
  - *M1*: Each domain microservice shall be encapsulated within independent Docker containers, allowing deployment updates without system-wide downtime.
  - *M2*: Core codebase shall maintain `> 85%` unit/integration test coverage with automated CI/CD build pipelines.

---

# PART D: Detailed FR $\rightarrow$ NFR Mapping & Quality Specification

Below are the detailed engineering mappings specifying the exact quality attribute requirements for each functional requirement:

### Detailed Mapping Table

| Functional Requirement (FR) | Quality Attribute | Concrete Measurable NFR Specification |
| :--- | :--- | :--- |
| **FR1 – Farmer Register/Login** | **NFR4: Security** | Authentication shall enforce SHA-256 OTP hashing and rate-limit login attempts to 5 per minute per IP. |
| **FR1 – Farmer Register/Login** | **NFR1: Performance** | OTP generation and SMS/Voice delivery trigger shall complete within `< 3 seconds`. |
| **FR2 – Add/Pre-Declare Product** | **NFR3: Availability** | Farmer app shall support offline local caching; listings sync automatically once rural connectivity is restored. |
| **FR2 – Add/Pre-Declare Product** | **NFR5: Reliability** | Uploaded crop photos and harvest metadata shall be durably persisted across multi-zone object storage. |
| **FR3 – Dynamic Price Discovery** | **NFR1: Performance** | Real-time APMC benchmark and 68% take-home calculation shall compute and render in `< 150 ms`. |
| **FR3 – Dynamic Price Discovery** | **NFR4: Security** | Price calculations shall be cryptographically signed against official Agmarknet mandi feeds to prevent client-side tampering. |
| **FR6 – Optical Assay & Grading** | **NFR1: Performance** | AI image-based pre-grading inference shall return quality grade classification in `< 1.2 seconds`. |
| **FR7 – Aggregator Inventory** | **NFR2: Scalability** | Hub inventory service shall synchronize concurrent stock updates across 500+ rural micro-hubs without lock contention. |
| **FR10 – Multi-Lingual Search** | **NFR1: Performance** | 95% of vernacular text/voice search queries with PRF expansion shall return results within `< 800 ms`. |
| **FR10 – Multi-Lingual Search** | **NFR2: Scalability** | Search subsystem shall scale to handle **10,000 concurrent client search requests** during peak morning hours. |
| **FR10 – Multi-Lingual Search** | **NFR3: Availability** | Search and catalogue browsing services shall remain available **99.9% of the time**. |
| **FR11 – ML Recommendations** | **NFR1: Performance** | Multi-model background recommendations (Buy Again, Collab, FP-Growth) shall execute and stream within `< 300 ms`. |
| **FR11 – ML Recommendations** | **NFR5: Reliability** | In cold-start scenarios with zero purchase history, the engine shall gracefully fallback to category popularity without throwing exceptions. |
| **FR12 – Place Order** | **NFR1: Performance** | Order submission, validation, and database commitment shall complete within `< 2.5 seconds` under standard load. |
| **FR12 – Place Order** | **NFR4: Security** | Only authenticated, verified buyer accounts shall be authorized to initiate order creation. |
| **FR12 – Place Order** | **NFR5: Reliability** | An accepted order shall not be lost during temporary network or downstream service partition (ACID persistence). |
| **FR12 – Place Order** | **NFR3: Availability** | The checkout and order placement pipeline shall maintain **99.95% uptime**. |
| **FR13 – Escrow Payment** | **NFR4: Security** | Payment transactions shall comply with PCI-DSS standards; smart contract escrow locks funds on-chain with non-custodial logic. |
| **FR13 – Escrow Payment** | **NFR5: Reliability** | Payment callbacks shall be idempotent; network drops during payment shall trigger automated reconciliation within 60 seconds. |
| **FR15 – VRP Route Optimization** | **NFR1: Performance** | Capacitated Vehicle Routing Problem (VRP) batch route computation for 50 drop-off nodes shall complete in `< 4 seconds`. |
| **FR17 – OTP Proof of Delivery** | **NFR4: Security** | Delivery OTP verification shall be cryptographically checked; successful match triggers automated on-chain fund release. |
| **FR17 – OTP Proof of Delivery** | **NFR5: Reliability** | Settlement trigger shall guarantee single-execution payout dispatch (zero duplicate fund transfer). |

---

# PART E: FR–NFR Traceability Matrix

The matrix below provides high-level traceability mapping every core functional module to its governing non-functional quality attributes:

```
+----------------------------------------------------------------------------------------------------+
|                                    FR–NFR TRACEABILITY MATRIX                                      |
+-------------------------------------+--------------+-------------+--------------+----------+-------+
| Functional Requirement Module       | Performance  | Scalability | Availability | Security | Rel.  |
|                                     |    (NFR1)    |   (NFR2)    |    (NFR3)    |  (NFR4)  | (NFR5)|
+-------------------------------------+--------------+-------------+--------------+----------+-------+
| FR1 – Farmer Register / Auth        |      [X]     |             |              |   [X]    |  [X]  |
| FR2 – Crop Harvest Pre-Declaration  |              |             |     [X]      |   [X]    |  [X]  |
| FR3 – Dynamic Price Discovery       |      [X]     |     [X]     |     [X]      |   [X]    |       |
| FR4 – Order Status & Payout Notify  |      [X]     |             |     [X]      |   [X]    |  [X]  |
| FR5 – Aggregator Farmer Management  |              |     [X]     |     [X]      |   [X]    |       |
| FR6 – Quality Assay & Grading       |      [X]     |             |     [X]      |   [X]    |  [X]  |
| FR7 – Micro-Hub Inventory Staging   |      [X]     |     [X]     |     [X]      |          |  [X]  |
| FR8 – Batch Consolidation & Dispatch|      [X]     |     [X]     |              |   [X]    |  [X]  |
| FR9 – Client Profile & Auth         |      [X]     |             |     [X]      |   [X]    |       |
| FR10 – Search & PRF Query Expansion |      [X]     |     [X]     |     [X]      |   [X]    |       |
| FR11 – ML Personalized Recs         |      [X]     |     [X]     |     [X]      |          |  [X]  |
| FR12 – Cart & Order Placement       |      [X]     |     [X]     |     [X]      |   [X]    |  [X]  |
| FR13 – Escrow Payment Processing    |      [X]     |     [X]     |     [X]      |   [X]    |  [X]  |
| FR14 – Live Tracking & QR Provenance|      [X]     |     [X]     |     [X]      |   [X]    |  [X]  |
| FR15 – Logistics VRP Assignment     |      [X]     |     [X]     |     [X]      |          |  [X]  |
| FR16 – Cold-Chain Transit Telemetry |      [X]     |     [X]     |              |   [X]    |  [X]  |
| FR17 – Delivery OTP Confirmation    |      [X]     |             |     [X]      |   [X]    |  [X]  |
| FR18 – Platform Admin & Ledger Audit|      [X]     |             |     [X]      |   [X]    |  [X]  |
+-------------------------------------+--------------+-------------+--------------+----------+-------+
```

---

# PART F: Major Business Modules (5–8 Subsystems)

AgriLink is architected around **7 major loosely-coupled business modules**:

1. **User & Identity Service**: Handles multi-role registration, phone/OTP verification, RBAC authorization, and profile management for Farmers, Aggregators, Buyers, and Logistics.
2. **Product Catalog & Inventory Service**: Manages crop taxonomy, harvest listings, village micro-hub stock staging, and crate allocation.
3. **Dynamic Pricing & APMC Engine**: Integrates daily Agmarknet modal benchmarks, applies quality/organic coefficients, and calculates transparent 68-10-14-8 cost waterfalls.
4. **Machine Learning & Recommendation Service**: Executes NLP query expansion (PRF), clickstream mining, and multi-model personalized feeds (Buy Again, Collaborative Filtering, FP-Growth Basket Analysis).
5. **Order Management & Workflow Service**: Coordinates multi-tier order lifecycles (retail cart, institutional recurring standing orders, bulk hospital orders).
6. **Payment & Blockchain Escrow Service**: Interacts with payment gateways, anchors transaction Merkle hashes on Polygon Layer-2, and manages automated non-custodial escrow release.
7. **Logistics & Fleet Optimization Service**: Runs Capacitated Vehicle Routing Problem (VRP) algorithms for 15–30 km aggregation collection and 85 km corridor dispatch with IoT telemetry.

---

# PART G: Architecture Alternatives & ATAM Trade-Off Evaluation

To determine the optimal software architecture, four major architectural styles were evaluated using the **Architecture Tradeoff Analysis Method (ATAM)**:

1. **Alternative 1: Monolithic Architecture** (Single unified code repository, shared database).
2. **Alternative 2: Microservices Architecture with API Gateway** (Independent domain services, database-per-service pattern).
3. **Alternative 3: Layered Monolithic Microservices (Hybrid)** (Modular services deployed as microservices with unified operational relational data layer & caching).
4. **Alternative 4: Pure Serverless / Event-Driven Architecture** (FaaS cloud functions triggered via messaging topics).

## 1. Simple ATAM Quality Attribute Comparison

```
+----------------------------------------------------------------------------------------------------+
|                                    ATAM ARCHITECTURAL COMPARISON                                   |
+-----------------------+---------------+--------------------+--------------------+------------------+
| Quality Attribute     | Option 1:     | Option 2: Pure     | Option 3: Layered  | Option 4: Pure   |
|                       | Monolithic    | Microservices      | Hybrid Microserv.  | Serverless FaaS  |
+-----------------------+---------------+--------------------+--------------------+------------------+
| Performance (Latency) | High (In-Proc)| Medium (Net. hops) | High (Optimized GW)| Medium (Cold-St.)|
| Scalability           | Low–Medium    | Very High          | High               | Very High        |
| Availability          | Low (SPOF)    | High (Fault-isol.) | High               | High             |
| Security & Auth       | High (Simple) | High (Token/RBAC)  | High (RLS + JWT)   | High (IAM-based) |
| Reliability & ACID    | Very High     | Medium (Dist. Tx)  | High (PostgreSQL)  | Medium (Eventual)|
| Maintainability & CI  | Low (Coupled) | High (Indep. CI/CD)| High (Modular)     | High             |
| Operational Overhead  | Very Low      | High (K8s / Mesh)  | Medium             | Low–Medium       |
+-----------------------+---------------+--------------------+--------------------+------------------+
```

---

## 2. ATAM Detailed Trade-Off Evaluation per Critical Functional Requirement

### ATAM Evaluation: FR10 (Product Search & Multi-Lingual PRF)

| Quality Attribute | Monolithic Architecture | Microservices Architecture | ATAM Architectural Observation |
| :--- | :---: | :---: | :--- |
| **Performance** | High | Medium–High | Monolith has in-process memory calls; Microservices introduce minor network latency across gateway. |
| **Scalability** | Medium | **High** | Search spikes during harvest morning hours can scale the Search/ML service independently without replicating the entire app. |
| **Availability** | Medium | **High** | Failure in payment or logistics services does not take down catalog browsing or search functionality. |
| **Security** | High | High | Both implement JWT authentication at the entry point. |

### ATAM Evaluation: FR12 (Place Order & Workflow Execution)

| Quality Attribute | Monolithic Architecture | Microservices Architecture | ATAM Architectural Observation |
| :--- | :---: | :---: | :--- |
| **Performance** | Lower under heavy load | **Medium–High** | Microservice async queueing prevents DB lock contention during checkout surges. |
| **Scalability** | Scale whole application | **High** | Order Service and Inventory Service scale independently based on transaction throughput. |
| **Availability** | Medium (SPOF) | **High** | Independent service replication guarantees order intake even if analytics/ML services are undergoing maintenance. |
| **Security** | High | High | Centralized API gateway enforces strict token validation and rate limiting. |
| **Reliability** | High (Single ACID DB) | **High\*** | Utilizes transactional outbox pattern to preserve ACID compliance across distributed events. |

### ATAM Evaluation: FR13 (Blockchain Escrow & Dynamic Pricing Settlement)

| Quality Attribute | Monolithic Architecture | Microservices Architecture | ATAM Architectural Observation |
| :--- | :---: | :---: | :--- |
| **Performance** | Medium | **High** | Web3 RPC node calls run asynchronously via dedicated microservice workers without blocking user checkout threads. |
| **Security / Immutability** | Medium | **Very High** | Dedicated Payment/Blockchain service isolates private cryptographic signing keys in hardware security modules. |
| **Maintainability** | Low | **High** | Upgrades to smart contract interfaces or APMC pricing algorithms do not require redeploying customer or farmer apps. |

---

# PART H: Architecture Decision Records (ADRs)

Below are the **3 formal Architecture Decision Records (ADRs)** capturing the key structural choices of AgriLink:

---

## ADR 1: Adoption of API Gateway with Layered Microservices Architecture
* **Status**: **ACCEPTED**
* **Context**: AgriLink must support multiple distinct user roles (Farmer, Aggregator, Buyer, Logistics) with vastly different traffic patterns. The Farmer app has periodic listing spikes, while the Buyer module experiences high-concurrency read/search loads. A monolithic architecture would require scaling the entire application together, causing resource inefficiency and high risk of single-point-of-failure outages.
* **Decision**: We adopt an **API Gateway with Modular Layered Microservices Architecture** (FastAPI backend microservices communicating through a reverse-proxy gateway with Supabase PostgreSQL and Redis caching).
* **Consequences**:
  * *Positive*: Enables independent scaling of high-throughput services (Search, ML Recommendations); provides fault isolation; allows independent CI/CD pipelines.
  * *Negative*: Introduces minor network overhead between gateway and microservices; requires distributed tracing and observability tooling.

---

## ADR 2: Hybrid Relational Database (Supabase PostgreSQL) with Event-Driven Outbox Pattern
* **Status**: **ACCEPTED**
* **Context**: Pure microservices often mandate a strict database-per-service approach, which creates extreme complexity for cross-entity ACID transactions (e.g., reserving inventory, calculating fair 68-10-14-8 splits, and placing an order simultaneously).
* **Decision**: We adopt a **Unified Relational PostgreSQL Core with Row-Level Security (RLS)** paired with an **Event-Driven Transactional Outbox Pattern**. Each microservice owns its domain schema partition while benefiting from PostgreSQL ACID guarantees for multi-table financial settlements.
* **Consequences**:
  * *Positive*: Eliminates two-phase commit (2PC) distributed transaction bugs; guarantees RPO = 0 for financial ledgers; native WebSocket subscriptions provide instant UI updates.
  * *Negative*: Requires disciplined schema isolation policies to prevent tight coupling across database tables.

---

## ADR 3: Dual-Layered Trust: Layer-2 Blockchain (Polygon) for Tamper-Proof Pricing & Smart Escrow
* **Status**: **ACCEPTED**
* **Context**: In traditional mandis, commission agents routinely alter agreed farm-gate prices post-auction or delay payments by 45–60 days. Farmers require an incorruptible trust mechanism that guarantees the 68% payout cannot be retroactively modified by middlemen or platform administrators.
* **Decision**: We integrate a **Polygon Layer-2 Blockchain Smart Contract Layer** to anchor APMC modal price benchmarks, batch quality hashes, and execute automated non-custodial payment escrow upon customer OTP delivery verification.
* **Consequences**:
  * *Positive*: Delivers cryptographic immutability and non-repudiation; enables consumers to verify complete farm origin via QR code; guarantees automated, zero-default farmer payouts.
  * *Negative*: Introduces smart contract gas costs (mitigated by Polygon L2 sub-cent fees $< \$0.001$/tx) and requires managing Web3 RPC connectivity.
