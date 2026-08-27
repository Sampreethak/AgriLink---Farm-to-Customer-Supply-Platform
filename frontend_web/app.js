// AgriLink Clean Consumer Web App Logic

const API_ML_URL = "http://localhost:8000";

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
        reason: "Direct farm harvest • High freshness (92.5%) • Organic Certified",
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
        reason: "Picked for you • Peak seasonal harvest (95% Freshness)",
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
        reason: "Best value for bulk cooking • Quality Grade A",
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
        reason: "Nearby farm (6.2 km) • Fresh harvest batch",
        image: "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?auto=format&fit=crop&w=600&q=80"
    }
];

document.addEventListener("DOMContentLoaded", () => {
    loadRecommendations("c793972c-ba33-4eb2-91db-83d7b26f19ca");
    renderAllListings();
});

function switchTab(tabId, btnElement) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));

    document.getElementById(tabId).classList.add('active');
    btnElement.classList.add('active');
}

function onCustomerChange(customerId) {
    loadRecommendations(customerId);
}

async function loadRecommendations(customerId) {
    const grid = document.getElementById("ml-recommendations-grid");
    grid.innerHTML = `<div style="grid-column: 1/-1; text-align: center; color: var(--text-muted); padding: 2rem;">
        <i class="fa-solid fa-spinner fa-spin fa-2xl" style="color: var(--primary);"></i>
        <div style="margin-top: 1rem;">Finding best farm fresh listings for you...</div>
    </div>`;

    try {
        const response = await fetch(`${API_ML_URL}/recommend/${customerId}?top_k=4`);
        if (response.ok) {
            const data = await response.json();
            renderRecommendations(data.recommendations);
            return;
        }
    } catch (e) {
        console.log("Using live cached seller listings.");
    }

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
                    <span class="ml-rank-badge">★ Top Pick #${index + 1}</span>
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
                            <i class="fa-solid fa-sparkles"></i> <b>Why You'll Love This:</b> ${item.reason}
                        </div>
                    </div>

                    <div class="card-actions">
                        <button class="btn-action btn-primary" onclick="alert('Item ${item.crop_name} added to cart!')">Add to Cart</button>
                        <button class="btn-action btn-secondary" onclick="alert('Seller Info: ${item.seller_name}')">Details</button>
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
