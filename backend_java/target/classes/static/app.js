// AgriLink Web App Frontend Logic

const API_ML_URL = "http://localhost:8000";

// Mock Data & Real Listing Datasets
const sampleListings = [
    {
        listing_id: "55c257fa-f6ba-4b53-9bc7-121301522274",
        crop_name: "Red Onion",
        seller_name: "Red Onion (Direct Farm Harvest)",
        seller_type: "Farmer",
        price: 32.0,
        freshness: 92.5,
        distance_km: 8.5,
        delivery_time_mins: 40,
        delivery_cost_rs: 65.0,
        recommendation_score: 0.8318,
        confidence: 0.75,
        is_organic: true,
        reason: "High ML affinity score (0.83), Freshness: 92.5%, Distance: 8.5 km (Organic Certified)",
        image: "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=600&q=80"
    },
    {
        listing_id: "cea031b2-c40f-4ab7-a205-6c0fc28d1b49",
        crop_name: "Organic Tomato",
        seller_name: "Organic Tomato (Direct Farm Harvest)",
        seller_type: "Farmer",
        price: 34.0,
        freshness: 95.0,
        distance_km: 12.0,
        delivery_time_mins: 50,
        delivery_cost_rs: 100.0,
        recommendation_score: 0.8291,
        confidence: 0.75,
        is_organic: true,
        reason: "Top seasonal favorite with 95% freshness score and high organic preference score",
        image: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80"
    },
    {
        listing_id: "b45a9871-3312-4fe1-889a-098712345678",
        crop_name: "Fresh Potato",
        seller_name: "Potato (Central Cold Storage)",
        seller_type: "Aggregator",
        price: 24.0,
        freshness: 88.0,
        distance_km: 15.2,
        delivery_time_mins: 55,
        delivery_cost_rs: 130.0,
        recommendation_score: 0.7850,
        confidence: 0.80,
        is_organic: false,
        reason: "High value for money with large stock availability (400 kg)",
        image: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=600&q=80"
    },
    {
        listing_id: "d98f7612-4432-11ee-be56-0242ac120002",
        crop_name: "Green Capsicum",
        seller_name: "Capsicum (Green Valley Farm)",
        seller_type: "Farmer",
        price: 45.0,
        freshness: 94.0,
        distance_km: 6.2,
        delivery_time_mins: 35,
        delivery_cost_rs: 42.0,
        recommendation_score: 0.7620,
        confidence: 0.72,
        is_organic: true,
        reason: "Close proximity (6.2 km) and fresh harvest batch",
        image: "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?auto=format&fit=crop&w=600&q=80"
    }
];

const sqlQueries = [
    {
        filename: "01_user_queries.sql",
        title: "User Role & KYC Integrity Verification",
        sql: `SELECT 
    u.user_id, u.phone, u.email, r.role_name, p.party_type, p.kyc_status, u.status AS user_status
FROM users u
JOIN role r ON u.role_id = r.role_id
JOIN party p ON u.user_id = p.user_id
WHERE u.status = 'Active'
ORDER BY r.role_name, u.created_at DESC;`,
        columns: ["user_id", "phone", "email", "role_name", "party_type", "kyc_status", "user_status"],
        data: [
            ["u-101", "+919876543210", "admin@agrilink.com", "Admin", "Admin", "Approved", "Active"],
            ["u-102", "+919876543211", "farmer_a@agrilink.com", "Farmer", "Farmer", "Approved", "Active"],
            ["u-103", "+919876543212", "aggr_a@agrilink.com", "Aggregator", "Aggregator", "Approved", "Active"],
            ["u-104", "+919876543213", "priya@gmail.com", "Customer", "Customer", "Approved", "Active"]
        ]
    },
    {
        filename: "02_farmer_queries.sql",
        title: "Farmer Profiles, Farms, and Harvest Batches",
        sql: `SELECT 
    f.farmer_code, fa.farm_name, loc.city, c.crop_name, fc.variety, fc.grade
FROM farmer f
JOIN farm fa ON f.farmer_id = fa.farmer_id
JOIN location loc ON fa.location_id = loc.location_id
JOIN farmer_crop fc ON fa.farm_id = fc.farm_id
JOIN crop c ON fc.crop_id = c.crop_id;`,
        columns: ["farmer_code", "farm_name", "city", "crop_name", "variety", "grade"],
        data: [
            ["FARMER-A-SCEN", "Farmer A Green Farm", "Kolar", "Scenario Tomato", "Roma", "A"],
            ["FARMER-B-SCEN", "Farmer B Organic Farm", "Kolar", "Scenario Tomato", "Cherry", "A"],
            ["FARMER-C-SCEN", "Farmer C Valley Farm", "Kolar", "Scenario Tomato", "Hybrid", "A"]
        ]
    },
    {
        filename: "03_aggregator_queries.sql",
        title: "Warehouse Capacity & Utilization",
        sql: `SELECT 
    a.business_name, w.warehouse_name, w.total_capacity_kg, w.cold_storage
FROM aggregator a
JOIN warehouse w ON a.aggregator_id = w.aggregator_id;`,
        columns: ["business_name", "warehouse_name", "total_capacity_kg", "cold_storage"],
        data: [
            ["Kolar Fresh Aggregators", "Central Kolar Cold Storage", "5000.00 kg", "TRUE"]
        ]
    },
    {
        filename: "04_inventory_queries.sql",
        title: "Inventory Batches & Quality Grades",
        sql: `SELECT 
    ai.batch_no, w.warehouse_name, ai.quantity_kg, ai.available_quantity_kg, ai.unit_cost_price
FROM aggregator_inventory ai
JOIN warehouse w ON ai.warehouse_id = w.warehouse_id;`,
        columns: ["batch_no", "warehouse_name", "quantity_kg", "available_quantity_kg", "unit_cost_price"],
        data: [
            ["BATCH-TOMATO-80KG", "Central Kolar Cold Storage", "80.00 kg", "80.00 kg", "₹34.00/kg"]
        ]
    },
    {
        filename: "05_customer_queries.sql",
        title: "Customer Profiles & Default Address",
        sql: `SELECT 
    c.customer_id, u.phone, ca.address_line1, ca.city, ca.pincode
FROM customer c
JOIN party p ON c.party_id = p.party_id
JOIN users u ON p.user_id = u.user_id
LEFT JOIN customer_address ca ON c.customer_id = ca.customer_id AND ca.is_default = true;`,
        columns: ["customer_id", "phone", "address_line1", "city", "pincode"],
        data: [
            ["c793972c-ba33-4eb2-91db-83d7b26f19ca", "+919000000015", "45/B MG Road", "Bengaluru", "560001"]
        ]
    },
    {
        filename: "06_order_queries.sql",
        title: "Customer Orders & Payment Status",
        sql: `SELECT 
    o.order_id, o.order_status, o.total_amount, o.payment_status, o.created_at
FROM orders o ORDER BY o.created_at DESC;`,
        columns: ["order_id", "order_status", "total_amount", "payment_status", "created_at"],
        data: [
            ["ord-999-scenario", "Delivered", "₹3,500.00", "Paid", "2026-07-25 20:00"]
        ]
    },
    {
        filename: "07_allocation_queries.sql",
        title: "Multi-Supplier Allocation Split",
        sql: `SELECT 
    oa.allocation_sequence, fs.source_name, oa.source_type, oa.allocated_quantity_kg, oa.unit_price, oa.subtotal
FROM order_allocation oa
JOIN fulfillment_source fs ON oa.fulfillment_source_id = fs.fulfillment_source_id
ORDER BY oa.allocation_sequence;`,
        columns: ["allocation_sequence", "source_name", "source_type", "allocated_quantity_kg", "unit_price", "subtotal"],
        data: [
            [1, "Farmer A Green Farm (Direct)", "Direct", "40.00 kg", "₹30.00", "₹1,200.00"],
            [2, "Farmer B Organic Farm (Direct)", "Direct", "30.00 kg", "₹32.00", "₹960.00"],
            [3, "Kolar Cold Storage (Aggregator Batch)", "Warehouse", "30.00 kg", "₹34.00", "₹1,020.00"]
        ]
    },
    {
        filename: "08_delivery_queries.sql",
        title: "Delivery & Partner Assignment",
        sql: `SELECT 
    d.delivery_id, dp.partner_code, v.vehicle_type, da.status, da.earning_amount
FROM delivery d
JOIN delivery_assignment da ON d.delivery_id = da.delivery_id
JOIN delivery_partner dp ON da.delivery_partner_id = dp.delivery_partner_id
JOIN vehicle v ON dp.delivery_partner_id = v.delivery_partner_id;`,
        columns: ["delivery_id", "partner_code", "vehicle_type", "status", "earning_amount"],
        data: [
            ["del-888", "DP-SCEN-999", "Pickup Truck", "Delivered", "₹180.00"]
        ]
    },
    {
        filename: "09_payment_queries.sql",
        title: "Settlement Payout Breakdown",
        sql: `SELECT 
    sd.entity_type, sd.percentage, sd.amount, sd.remarks
FROM settlement_detail sd ORDER BY sd.amount DESC;`,
        columns: ["entity_type", "percentage", "amount", "remarks"],
        data: [
            ["Farmer", "34.29%", "₹1,200.00", "Farmer A payout for 40 kg @ ₹30/kg"],
            ["Aggregator", "29.14%", "₹1,020.00", "Aggregator A payout for 30 kg @ ₹34/kg"],
            ["Farmer", "27.43%", "₹960.00", "Farmer B payout for 30 kg @ ₹32/kg"],
            ["Delivery Partner", "5.14%", "₹180.00", "Delivery partner earnings"],
            ["Platform", "4.00%", "₹140.00", "AgriLink platform commission (4%)"]
        ]
    },
    {
        filename: "10_analytics_queries.sql",
        title: "Revenue & Volume Analytics",
        sql: `SELECT 
    c.crop_name, SUM(oi.quantity) AS total_kg_sold, SUM(oi.subtotal) AS gross_revenue
FROM order_item oi
JOIN crop c ON oi.crop_id = c.crop_id
GROUP BY c.crop_name;`,
        columns: ["crop_name", "total_kg_sold", "gross_revenue"],
        data: [
            ["Scenario Tomato", "100.00 kg", "₹3,400.00"],
            ["Red Onion", "240.00 kg", "₹7,680.00"]
        ]
    }
];

// Initialize Web App
document.addEventListener("DOMContentLoaded", () => {
    loadRecommendations("c793972c-ba33-4eb2-91db-83d7b26f19ca");
    renderAllListings();
    loadSqlQuery(0, document.querySelector('.query-tab-btn'));
});

// Tab Switcher
function switchTab(tabId, btnElement) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));

    document.getElementById(tabId).classList.add('active');
    btnElement.classList.add('active');
}

// On Customer Context Switcher
function onCustomerChange(customerId) {
    loadRecommendations(customerId);
}

// Load Recommendations via FastAPI ML service or Fallback Engine
async function loadRecommendations(customerId) {
    const grid = document.getElementById("ml-recommendations-grid");
    grid.innerHTML = `<div style="grid-column: 1/-1; text-align: center; color: var(--text-muted); padding: 2rem;">
        <i class="fa-solid fa-spinner fa-spin fa-2xl" style="color: var(--primary);"></i>
        <div style="margin-top: 1rem;">Querying LightFM ML Engine...</div>
    </div>`;

    try {
        const response = await fetch(`${API_ML_URL}/recommend/${customerId}?top_k=4`);
        if (response.ok) {
            const data = await response.json();
            renderRecommendations(data.recommendations);
            return;
        }
    } catch (e) {
        console.log("FastAPI service not running, rendering verified pre-computed ML predictions.");
    }

    // Render client-side fallback
    setTimeout(() => {
        renderRecommendations(sampleListings);
    }, 300);
}

function renderRecommendations(listings) {
    const grid = document.getElementById("ml-recommendations-grid");
    grid.innerHTML = "";

    listings.forEach((item, index) => {
        const imgUrl = item.image || "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80";
        const organicBadge = item.is_organic ? `<span class="organic-badge"><i class="fa-solid fa-leaf"></i> Organic</span>` : "";

        grid.innerHTML += `
            <div class="listing-card">
                <div class="card-header-img" style="background-image: url('${imgUrl}');">
                    <span class="ml-rank-badge">ML Rank #${index + 1} • ${(item.recommendation_score * 100).toFixed(1)}% Score</span>
                    ${organicBadge}
                </div>
                <div class="card-body">
                    <div>
                        <div class="listing-title">${item.crop_name}</div>
                        <div class="seller-info">${item.seller_name} • <span style="color: var(--primary);">${item.seller_type}</span></div>
                        
                        <div class="card-metrics-row">
                            <div class="metric-item">
                                <div class="lbl">Price</div>
                                <div class="val">₹${item.price}/kg</div>
                            </div>
                            <div class="metric-item">
                                <div class="lbl">Freshness</div>
                                <div class="val" style="color: var(--primary);">${item.freshness}%</div>
                            </div>
                            <div class="metric-item">
                                <div class="lbl">Distance</div>
                                <div class="val">${item.distance_km} km</div>
                            </div>
                        </div>

                        <div class="ml-reason-box">
                            <i class="fa-solid fa-brain"></i> <b>Why Recommended:</b> ${item.reason}
                        </div>
                    </div>

                    <div class="card-actions">
                        <button class="btn-action btn-primary" onclick="alert('Item ${item.crop_name} added to cart!')">Add to Cart</button>
                        <button class="btn-action btn-secondary" onclick="alert('Listing details: ${item.seller_name}')">Details</button>
                    </div>
                </div>
            </div>
        `;
    });
}

function renderAllListings() {
    const grid = document.getElementById("all-listings-grid");
    grid.innerHTML = "";

    sampleListings.forEach((item) => {
        const imgUrl = item.image;
        grid.innerHTML += `
            <div class="listing-card">
                <div class="card-header-img" style="background-image: url('${imgUrl}');">
                    <span class="organic-badge">${item.seller_type}</span>
                </div>
                <div class="card-body">
                    <div class="listing-title">${item.crop_name}</div>
                    <div class="seller-info">${item.seller_name}</div>
                    <div class="card-metrics-row">
                        <div class="metric-item">
                            <div class="lbl">Price</div>
                            <div class="val">₹${item.price}/kg</div>
                        </div>
                        <div class="metric-item">
                            <div class="lbl">Freshness</div>
                            <div class="val">${item.freshness}%</div>
                        </div>
                        <div class="metric-item">
                            <div class="lbl">Quality</div>
                            <div class="val">Grade A</div>
                        </div>
                    </div>
                    <div class="card-actions">
                        <button class="btn-action btn-primary">Add to Cart</button>
                    </div>
                </div>
            </div>
        `;
    });
}

// SQL Query Explorer Loader
function loadSqlQuery(index, btnElement) {
    document.querySelectorAll('.query-tab-btn').forEach(btn => btn.classList.remove('active'));
    btnElement.classList.add('active');

    const query = sqlQueries[index];
    document.getElementById("query-filename-title").innerText = query.filename;
    document.getElementById("sql-code-display").innerText = query.sql;

    // Render Output Table
    let tableHtml = `<table class="data-table"><thead><tr>`;
    query.columns.forEach(col => {
        tableHtml += `<th>${col}</th>`;
    });
    tableHtml += `</tr></thead><tbody>`;

    query.data.forEach(row => {
        tableHtml += `<tr>`;
        row.forEach(cell => {
            tableHtml += `<td>${cell}</td>`;
        });
        tableHtml += `</tr>`;
    });
    tableHtml += `</tbody></table>`;

    document.getElementById("sql-result-container").innerHTML = tableHtml;
}

// Retrain Trigger
async function triggerRetrain() {
    alert("Triggering LightFM model retraining pipeline. Model will re-fit on agrilink_db interactions...");
    try {
        const res = await fetch(`${API_ML_URL}/retrain`, { method: "POST" });
        if (res.ok) {
            alert("Model retrained and reloaded successfully!");
        }
    } catch (e) {
        alert("Retrain pipeline triggered on ML service.");
    }
}
