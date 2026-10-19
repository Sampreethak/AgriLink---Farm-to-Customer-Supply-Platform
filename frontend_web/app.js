// AgriLink Multi-Model Customer Recommendation Web Dashboard Logic

const API_ML_URL = "http://127.0.0.1:8000";
let currentCustomerId = "d48b9f71-c110-4f5f-83da-7b65dbfbc328";
let currentCart = [];

const CROP_IMAGES = {
    "Tomato": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80",
    "Potato": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80",
    "Onion": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80",
    "Carrot": "https://images.unsplash.com/photo-1598170845058-12f6a67a9657?w=600&auto=format&fit=crop&q=80",
    "Cabbage": "https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=600&auto=format&fit=crop&q=80",
    "Green Peas": "https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=600&auto=format&fit=crop&q=80",
    "Green Capsicum": "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80",
    "Green Chilli": "https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80",
    "Palak": "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80",
    "Coriander": "https://images.unsplash.com/photo-1608797178974-15b35a6018b3?w=600&auto=format&fit=crop&q=80",
    "Mint": "https://images.unsplash.com/photo-1628556270448-4d4e4148e1b1?w=600&auto=format&fit=crop&q=80",
    "Ginger": "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80",
    "Garlic": "https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=600&auto=format&fit=crop&q=80",
    "Banana": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80",
    "Papaya": "https://images.unsplash.com/photo-1526318897912-3283331804f1?w=600&auto=format&fit=crop&q=80",
    "Pomegranate": "https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600&auto=format&fit=crop&q=80",
    "Grapes": "https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&auto=format&fit=crop&q=80",
    "Ragi": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80",
    "Rice": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80",
    "Apple": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80",
    "Honey": "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&auto=format&fit=crop&q=80",
    "Wheat": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80"
};

document.addEventListener("DOMContentLoaded", () => {
    loadAllRecommendations(currentCustomerId);
    renderAllListings();
    calculateFairPrice();
    loadApmcBenchmarks();
});

function switchTab(tabId, btnElement) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-btn').forEach(el => el.classList.remove('active'));

    document.getElementById(tabId).classList.add('active');
    btnElement.classList.add('active');
}

function onCustomerChange(customerId) {
    currentCustomerId = customerId;
    loadAllRecommendations(customerId);
}

function updateCartBanner() {
    const display = document.getElementById("cart-items-display");
    if (currentCart.length === 0) {
        display.innerHTML = "Cart is empty (Click 'Add to Cart' to trigger live FP-Growth recommendations)";
        display.style.color = "#155724";
    } else {
        const pills = currentCart.map(c => `<span style="background: #28a745; color: white; padding: 2px 8px; border-radius: 12px; font-size: 0.8rem; margin-right: 4px;">${c}</span>`).join(" ");
        display.innerHTML = `Active Basket (${currentCart.length} items): ${pills} <span style="font-size: 0.8rem; color: #666;">• Live FP-Growth rules triggered!</span>`;
    }
}

function clearCart() {
    currentCart = [];
    updateCartBanner();
    loadAllRecommendations(currentCustomerId);
}

async function addToCart(cropName, listingId) {
    if (!currentCart.includes(cropName)) {
        currentCart.push(cropName);
    }
    updateCartBanner();
    
    // Log live interaction to FastAPI backend
    try {
        await fetch(`${API_ML_URL}/api/v1/recommendations/interact`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                customer_id: currentCustomerId,
                listing_id: listingId || "lst-default",
                interaction_type: "CART"
            })
        });
    } catch (e) {
        console.log("Interaction logged locally.");
    }
    
    // Dynamically re-query 'You May Also Want' with live cart
    reloadYouMayAlsoWant(currentCustomerId);
}

async function loadAllRecommendations(customerId) {
    setLoadingState("buy-again-grid", "Fetching repeat purchase history...");
    setLoadingState("picked-for-you-grid", "Computing collaborative filtering affinities...");
    setLoadingState("you-may-also-want-grid", "Mining frequent basket itemsets...");

    try {
        const cartParam = currentCart.join(",");
        const response = await fetch(`${API_ML_URL}/api/v1/recommendations/customer-home/${customerId}?cart_crops=${encodeURIComponent(cartParam)}`);
        if (response.ok) {
            const data = await response.json();
            
            // Render all 3 sections
            renderGrid("buy-again-grid", data.sections.buy_again.items, "🔄 Buy Again");
            renderGrid("picked-for-you-grid", data.sections.picked_for_you.items, "❤️ Picked For You");
            renderGrid("you-may-also-want-grid", data.sections.you_may_also_want.items, "🛒 Basket Pairing");
            return;
        }
    } catch (e) {
        console.log("Backend offline, rendering dynamic preview.");
    }

    // Fallback Mock Data
    renderGrid("buy-again-grid", [], "🔄 Buy Again");
    renderGrid("picked-for-you-grid", [], "❤️ Picked For You");
    renderGrid("you-may-also-want-grid", [], "🛒 Basket Pairing");
}

async function reloadYouMayAlsoWant(customerId) {
    setLoadingState("you-may-also-want-grid", "Re-evaluating FP-Growth association rules for cart...");
    try {
        const cartParam = currentCart.join(",");
        const response = await fetch(`${API_ML_URL}/api/v1/recommendations/you-may-also-want/${customerId}?cart_crops=${encodeURIComponent(cartParam)}&top_k=4`);
        if (response.ok) {
            const data = await response.json();
            renderGrid("you-may-also-want-grid", data.recommendations, "🛒 Basket Pairing");
        }
    } catch (e) {
        console.log("Failed to reload association rules.");
    }
}

function setLoadingState(elementId, text) {
    const el = document.getElementById(elementId);
    if (el) {
        el.innerHTML = `
            <div style="grid-column: 1/-1; text-align: center; color: var(--text-muted); padding: 1.5rem;">
                <i class="fa-solid fa-spinner fa-spin fa-xl" style="color: var(--primary);"></i>
                <div style="margin-top: 0.5rem; font-size: 0.9rem;">${text}</div>
            </div>
        `;
    }
}

function renderGrid(elementId, items, modelBadge) {
    const grid = document.getElementById(elementId);
    if (!grid) return;
    grid.innerHTML = "";

    if (!items || items.length === 0) {
        grid.innerHTML = `<div style="grid-column: 1/-1; color: var(--text-muted); text-align: center; padding: 1rem;">No recommendations generated.</div>`;
        return;
    }

    items.forEach((item, index) => {
        const crop = item.crop_name || "Fresh Harvest";
        const imgUrl = CROP_IMAGES[crop] || item.image_url || "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600";
        const price = item.price_per_unit || 35.0;
        const unit = item.unit || "kg";
        const organicBadge = item.is_organic ? `<span class="organic-badge"><i class="fa-solid fa-leaf"></i> Organic</span>` : "";
        const badge = item.badge || `★ Recommendation #${index + 1}`;
        const reason = item.reason || "Farm-fresh daily harvest straight from North Bengaluru peri-urban fields.";

        grid.innerHTML += `
            <div class="listing-card">
                <div class="card-header-img" style="background-image: url('${imgUrl}');">
                    <span class="ml-rank-badge">${badge}</span>
                    ${organicBadge}
                </div>
                <div class="card-body">
                    <div>
                        <div class="listing-title">${crop}</div>
                        <div class="seller-info">${item.title || `${crop} - North Bengaluru Farm Direct`}</div>
                        
                        <div class="card-metrics-row">
                            <div class="metric-item">
                                <div class="lbl">Price</div>
                                <div class="val">₹${price.toFixed(2)}/${unit}</div>
                            </div>
                            <div class="metric-item">
                                <div class="lbl">Rating</div>
                                <div class="val" style="color: #f57c00;">★ ${item.rating_avg || 4.8}</div>
                            </div>
                            <div class="metric-item">
                                <div class="lbl">Quality</div>
                                <div class="val">${item.grade || "Grade A"}</div>
                            </div>
                        </div>

                        <div class="ml-reason-box" style="font-size: 0.82rem; margin: 0.75rem 0; background: #f8f9fa; padding: 0.6rem; border-radius: 8px; border-left: 3px solid var(--primary);">
                            <i class="fa-solid fa-wand-magic-sparkles" style="color: var(--primary);"></i> <b>ML Reason:</b> ${reason}
                        </div>
                    </div>

                    <div class="card-actions">
                        <button class="btn-action btn-primary" onclick="addToCart('${crop}', '${item.listing_id || ''}')">
                            <i class="fa-solid fa-cart-plus"></i> Add to Cart
                        </button>
                    </div>
                </div>
            </div>
        `;
    });
}

function renderAllListings() {
    const grid = document.getElementById("all-listings-grid");
    if (!grid) return;
    grid.innerHTML = "";

    const catalogue = [
        { crop: "Tomato", price: 38.0, unit: "kg", is_organic: true, grade: "A+" },
        { crop: "Potato", price: 32.0, unit: "kg", is_organic: false, grade: "A" },
        { crop: "Onion", price: 42.0, unit: "kg", is_organic: false, grade: "A" },
        { crop: "Carrot", price: 55.0, unit: "kg", is_organic: true, grade: "A+" },
        { crop: "Palak", price: 25.0, unit: "bunch", is_organic: true, grade: "A+" },
        { crop: "Coriander", price: 18.0, unit: "bunch", is_organic: true, grade: "A+" },
        { crop: "Banana", price: 48.0, unit: "dozen", is_organic: true, grade: "A+" },
        { crop: "Green Chilli", price: 45.0, unit: "kg", is_organic: true, grade: "A" }
    ];

    catalogue.forEach(item => {
        const imgUrl = CROP_IMAGES[item.crop];
        grid.innerHTML += `
            <div class="listing-card">
                <div class="card-header-img" style="background-image: url('${imgUrl}');">
                    <span class="organic-badge">${item.is_organic ? "Organic Certified" : "Conventional Fresh"}</span>
                </div>
                <div class="card-body">
                    <div class="listing-title">${item.crop}</div>
                    <div class="seller-info">North Bengaluru Peri-Urban Cluster</div>
                    <div class="card-metrics-row">
                        <div class="metric-item">
                            <div class="lbl">Price</div>
                            <div class="val">₹${item.price.toFixed(2)}/${item.unit}</div>
                        </div>
                        <div class="metric-item">
                            <div class="lbl">Grade</div>
                            <div class="val">${item.grade}</div>
                        </div>
                        <div class="metric-item">
                            <div class="lbl">Freshness</div>
                            <div class="val" style="color: var(--primary);">96%</div>
                        </div>
                    </div>
                    <div class="card-actions">
                        <button class="btn-action btn-primary" onclick="addToCart('${item.crop}', 'cat-${item.crop}')">
                            <i class="fa-solid fa-cart-plus"></i> Add to Cart
                        </button>
                    </div>
                </div>
            </div>
        `;
    });
}

// ==========================================
// APMC-LINKED DYNAMIC PRICING JAVASCRIPT LOGIC
// ==========================================

const DISTANCE_MAP = {
    "Mandya": 85.0,
    "Maddur": 75.0,
    "Srirangapatna": 115.0,
    "Ramanagara": 50.0
};

async function calculateFairPrice() {
    const container = document.getElementById("pricing-result-container");
    if (!container) return;

    const commodity = document.getElementById("pricing-commodity").value;
    const origin = document.getElementById("pricing-origin").value;
    const grade = document.getElementById("pricing-grade").value;
    const isOrganic = document.getElementById("pricing-organic").value === "true";
    const distanceKm = DISTANCE_MAP[origin] || 85.0;

    container.innerHTML = `
        <div style="text-align: center; color: var(--text-muted); padding: 1rem;">
            <i class="fa-solid fa-spinner fa-spin fa-lg" style="color: var(--primary);"></i>
            <div style="margin-top: 0.5rem; font-size: 0.85rem;">Calculating APMC Oracle Fair-Share Breakdown...</div>
        </div>
    `;

    try {
        const response = await fetch(`${API_ML_URL}/api/v1/pricing/calculate-fair-share`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                commodity: commodity,
                variety: isOrganic ? "Organic Certified" : "Hybrid / Nati",
                grade: grade,
                origin_district: origin,
                distance_km: distanceKm,
                is_organic: isOrganic
            })
        });

        if (response.ok) {
            const data = await response.json();
            renderPricingResult(data);
            return;
        }
    } catch (e) {
        console.log("Pricing API offline, rendering local fallback calculation.");
    }

    // Fallback calculation
    const apmcModal = 28.0;
    const fairPrice = isOrganic ? 46.0 : 36.0;
    renderPricingResult({
        commodity: commodity,
        grade: grade,
        is_organic: isOrganic,
        corridor: `${origin} -> Bengaluru (${distanceKm} km)`,
        apmc_mandi_benchmark_per_kg: apmcModal,
        predicted_fair_consumer_price_per_kg: fairPrice,
        fair_share_breakdown: {
            farmer: { role: "Farmer (Producer)", share_pct: 68, payout_per_kg: +(fairPrice * 0.68).toFixed(2), benefit_description: "+175% vs traditional middlemen" },
            aggregator: { role: "SHG Homemaker (Tier-1) + Corridor Hub (Tier-2)", share_pct: 10, payout_per_kg: +(fairPrice * 0.10).toFixed(2), benefit_description: "Village pooling and quality grading" },
            delivery_partner: { role: "Corridor Highway Transport & Rider", share_pct: 14, payout_per_kg: +(fairPrice * 0.14).toFixed(2), benefit_description: "Corridor freight and last mile" },
            platform: { role: "AgriLink Platform & Quality Tech", share_pct: 8, payout_per_kg: +(fairPrice * 0.08).toFixed(2), benefit_description: "AI pricing oracle and escrow" }
        },
        consumer_savings: {
            supermarket_benchmark_per_kg: +(fairPrice * 1.25).toFixed(2),
            savings_pct: 20.0,
            savings_description: "Delivered 20% cheaper than city supermarket retail"
        }
    });
}

function renderPricingResult(data) {
    const container = document.getElementById("pricing-result-container");
    if (!container) return;

    const shares = data.fair_share_breakdown;
    const savings = data.consumer_savings;

    container.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem; border-bottom: 1px solid #e0e0e0; padding-bottom: 1rem; margin-bottom: 1rem;">
            <div>
                <span style="background: #2e7d32; color: white; padding: 3px 8px; border-radius: 4px; font-size: 0.75rem; font-weight: bold; text-transform: uppercase;">
                    ${data.is_organic ? '🌱 Organic' : '🚜 Conventional'} • ${data.grade}
                </span>
                <h3 style="margin: 0.4rem 0 0.2rem 0; color: #1b5e20;">${data.commodity} (${data.corridor})</h3>
                <div style="font-size: 0.85rem; color: var(--text-muted);">
                    APMC Mandi Modal Benchmark: <b>₹${data.apmc_mandi_benchmark_per_kg.toFixed(2)}/kg</b>
                </div>
            </div>
            <div style="text-align: right;">
                <div style="font-size: 0.8rem; color: var(--text-muted); font-weight: bold;">AGRILINK FAIR CONSUMER PRICE</div>
                <div style="font-size: 1.8rem; font-weight: 800; color: var(--primary);">₹${data.predicted_fair_consumer_price_per_kg.toFixed(2)}<span style="font-size: 1rem; font-weight: normal; color: #555;">/kg</span></div>
                <div style="font-size: 0.8rem; color: #2e7d32; font-weight: bold;">
                    <i class="fa-solid fa-tags"></i> City Supermarket: ₹${savings.supermarket_benchmark_per_kg}/kg (Save ${savings.savings_pct}%)
                </div>
            </div>
        </div>

        <div style="font-weight: bold; font-size: 0.9rem; margin-bottom: 0.75rem; color: #333;">
            <i class="fa-solid fa-chart-pie" style="color: var(--primary);"></i> 4-Way Transparent Value Share Breakdown:
        </div>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 0.75rem;">
            <!-- Farmer -->
            <div style="background: #e8f5e9; border: 1px solid #c8e6c9; border-radius: 8px; padding: 0.75rem;">
                <div style="display: flex; justify-content: space-between; font-weight: bold; color: #2e7d32; font-size: 0.85rem;">
                    <span>🌾 Farmer (Producer)</span>
                    <span style="background: #2e7d32; color: white; padding: 1px 6px; border-radius: 10px; font-size: 0.75rem;">${shares.farmer.share_pct}%</span>
                </div>
                <div style="font-size: 1.3rem; font-weight: 800; color: #1b5e20; margin: 0.3rem 0;">₹${shares.farmer.payout_per_kg.toFixed(2)}/kg</div>
                <div style="font-size: 0.75rem; color: #2e7d32; line-height: 1.2;">${shares.farmer.benefit_description}</div>
            </div>

            <!-- SHG Aggregator -->
            <div style="background: #fff8e1; border: 1px solid #ffe082; border-radius: 8px; padding: 0.75rem;">
                <div style="display: flex; justify-content: space-between; font-weight: bold; color: #f57f17; font-size: 0.85rem;">
                    <span>👩‍🌾 SHG Aggregator</span>
                    <span style="background: #f57f17; color: white; padding: 1px 6px; border-radius: 10px; font-size: 0.75rem;">${shares.aggregator.share_pct}%</span>
                </div>
                <div style="font-size: 1.3rem; font-weight: 800; color: #e65100; margin: 0.3rem 0;">₹${shares.aggregator.payout_per_kg.toFixed(2)}/kg</div>
                <div style="font-size: 0.75rem; color: #e65100; line-height: 1.2;">${shares.aggregator.benefit_description}</div>
            </div>

            <!-- Delivery Partner -->
            <div style="background: #e1f5fe; border: 1px solid #b3e5fc; border-radius: 8px; padding: 0.75rem;">
                <div style="display: flex; justify-content: space-between; font-weight: bold; color: #0277bd; font-size: 0.85rem;">
                    <span>🚚 Delivery Partner</span>
                    <span style="background: #0277bd; color: white; padding: 1px 6px; border-radius: 10px; font-size: 0.75rem;">${shares.delivery_partner.share_pct}%</span>
                </div>
                <div style="font-size: 1.3rem; font-weight: 800; color: #01579b; margin: 0.3rem 0;">₹${shares.delivery_partner.payout_per_kg.toFixed(2)}/kg</div>
                <div style="font-size: 0.75rem; color: #01579b; line-height: 1.2;">${shares.delivery_partner.benefit_description}</div>
            </div>

            <!-- AgriLink Platform -->
            <div style="background: #f3e5f5; border: 1px solid #e1bee7; border-radius: 8px; padding: 0.75rem;">
                <div style="display: flex; justify-content: space-between; font-weight: bold; color: #7b1fa2; font-size: 0.85rem;">
                    <span>⚡ AgriLink Platform</span>
                    <span style="background: #7b1fa2; color: white; padding: 1px 6px; border-radius: 10px; font-size: 0.75rem;">${shares.platform.share_pct}%</span>
                </div>
                <div style="font-size: 1.3rem; font-weight: 800; color: #4a148c; margin: 0.3rem 0;">₹${shares.platform.payout_per_kg.toFixed(2)}/kg</div>
                <div style="font-size: 0.75rem; color: #4a148c; line-height: 1.2;">${shares.platform.benefit_description}</div>
            </div>
        </div>
    `;
}

async function loadApmcBenchmarks() {
    const tbody = document.getElementById("apmc-benchmarks-tbody");
    if (!tbody) return;

    try {
        const response = await fetch(`${API_ML_URL}/api/v1/pricing/benchmarks`);
        if (response.ok) {
            const data = await response.json();
            const benchmarks = data.benchmarks_rs_per_kg || {};
            tbody.innerHTML = "";
            for (const [crop, modal] of Object.entries(benchmarks)) {
                const fairPrice = +(modal * 1.45).toFixed(2);
                const farmerPayout = +(fairPrice * 0.68).toFixed(2);
                const traditionalPayout = +(modal * 0.32).toFixed(2);
                const boostPct = +(((farmerPayout - traditionalPayout) / traditionalPayout) * 100).toFixed(0);

                tbody.innerHTML += `
                    <tr>
                        <td><b>${crop}</b></td>
                        <td>₹${modal.toFixed(2)}</td>
                        <td><b style="color: var(--primary);">₹${fairPrice.toFixed(2)}</b></td>
                        <td><span style="color: #2e7d32; font-weight: bold;">₹${farmerPayout.toFixed(2)}</span></td>
                        <td><span style="color: #c62828;">₹${traditionalPayout.toFixed(2)}</span></td>
                        <td><span style="background: #e8f5e9; color: #2e7d32; padding: 3px 8px; border-radius: 12px; font-weight: bold;">+${boostPct}% Boost</span></td>
                    </tr>
                `;
            }
        }
    } catch (e) {
        console.log("Could not load APMC benchmarks table.");
    }
}

async function loadFarmerRecommendations(farmerId = "FARM-101") {
    const container = document.getElementById("farmer-opportunities-container");
    if (!container) return;
    container.innerHTML = `<div style="grid-column: 1/-1; padding: 1rem; text-align: center; color: var(--text-muted);">Analyzing demand-supply gap & predicting APMC prices...</div>`;

    try {
        const response = await fetch(`${API_ML_URL}/api/v1/recommendations/farmer/${farmerId}`);
        if (response.ok) {
            const data = await response.json();
            const recs = data.recommendations || [];
            container.innerHTML = "";
            if (recs.length === 0) {
                container.innerHTML = `<div style="grid-column: 1/-1; padding: 1rem; text-align: center; color: var(--text-muted);">No active crop opportunities.</div>`;
                return;
            }
            recs.slice(0, 4).forEach(item => {
                container.innerHTML += `
                    <div style="background: white; border-radius: 12px; border: 1px solid #e2e8f0; padding: 1.2rem; box-shadow: 0 2px 8px rgba(0,0,0,0.04);">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                            <span style="font-size: 1.1rem; font-weight: bold; color: var(--text-main);">${item.crop_name}</span>
                            <span style="background: #e8f5e9; color: #2e7d32; font-weight: bold; padding: 3px 8px; border-radius: 12px; font-size: 0.8rem;">Score: ${+(item.opportunity_score * 100).toFixed(0)}%</span>
                        </div>
                        <div style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 0.8rem;">${item.reason}</div>
                        <div style="display: flex; justify-content: space-between; background: #f8fafc; padding: 0.6rem; border-radius: 8px; font-size: 0.85rem;">
                            <div><b>Demand Gap:</b> ${item.supply_gap || item.quantity_demand || 500} kg</div>
                            <div><b>APMC Price:</b> ₹${item.predicted_price || 35}/kg</div>
                        </div>
                    </div>
                `;
            });
        }
    } catch (e) {
        console.log("Could not load farmer recommendations.");
    }
}

async function findAggregatorMatches() {
    const crop = document.getElementById("aggregator-crop-select")?.value || "Tomato";
    const qty = document.getElementById("aggregator-qty-input")?.value || "500";
    const grid = document.getElementById("aggregator-matches-grid");
    if (!grid) return;

    grid.innerHTML = `<div style="grid-column: 1/-1; padding: 1rem; text-align: center; color: var(--text-muted);">Matching verified farm suppliers...</div>`;

    try {
        const response = await fetch(`${API_ML_URL}/api/v1/recommendations/aggregator/match?crop_name=${encodeURIComponent(crop)}&required_quantity=${qty}`);
        if (response.ok) {
            const data = await response.json();
            const recs = data.recommendations || [];
            grid.innerHTML = "";
            if (recs.length === 0) {
                grid.innerHTML = `<div style="grid-column: 1/-1; padding: 1rem; text-align: center; color: var(--text-muted);">No suppliers match criteria.</div>`;
                return;
            }
            renderGrid("aggregator-matches-grid", recs, "📦 Supplier Match");
        }
    } catch (e) {
        grid.innerHTML = `<div style="grid-column: 1/-1; padding: 1rem; text-align: center; color: var(--text-muted);">Unable to load supplier matches.</div>`;
    }
}

// Auto-trigger farmer recommendations on tab switch
const origSwitchTab = switchTab;
switchTab = function(tabId, btnElement) {
    origSwitchTab(tabId, btnElement);
    if (tabId === 'farmer-tab') {
        loadFarmerRecommendations();
        findAggregatorMatches();
    }
    if (tabId === 'discover-tab') {
        loadDiscoverDashboard(currentCustomerId);
    }
};

// ============================================================
// DISCOVER TAB — 4 Extended ML Recommendation Models
// ============================================================

async function loadDiscoverDashboard(customerId) {
    // Show loading state in all 4 grids
    setLoadingState("next-basket-grid", "🛍️ Predicting your next basket items (NBR Engine)...");
    setLoadingState("recency-weighted-grid", "⏱️ Applying time-decay scoring to your purchase history...");
    setLoadingState("price-smart-grid", "💰 Matching items to your budget profile...");
    setLoadingState("local-popular-grid", "📍 Loading trending items near you...");

    try {
        // Fetch unified discover dashboard endpoint
        const response = await fetch(`${API_ML_URL}/api/v1/recommendations/discover/${customerId}`);
        if (response.ok) {
            const data = await response.json();
            
            // Handle cold-start UI
            handleColdStartUI(data.is_new_customer || false);

            // Render 4 sections
            const secs = data.sections || {};
            renderDiscoverGrid("next-basket-grid", (secs.next_basket || {}).items, "🛍️ Next Basket");
            renderDiscoverGrid("recency-weighted-grid", (secs.recency_weighted || {}).items, "⏱️ Recency Weighted");
            renderDiscoverGrid("price-smart-grid", (secs.price_smart || {}).items, "💰 Price Smart");
            renderDiscoverGrid("local-popular-grid", (secs.local_popular || {}).items, "📍 Local Popular");
            return;
        }
    } catch (e) {
        console.log("Discover API unavailable, fetching sections individually...");
    }

    // Fallback: load each section independently
    await Promise.all([
        loadNextBasket(customerId),
        loadRecencyWeighted(customerId),
        loadPriceSmart(customerId),
        loadLocalPopular(customerId)
    ]);
}

async function loadNextBasket(customerId) {
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/recommendations/next-basket/${customerId}?top_k=4`);
        if (res.ok) {
            const data = await res.json();
            handleColdStartUI(data.is_new_customer || false);
            renderDiscoverGrid("next-basket-grid", data.recommendations, "🛍️ Next Basket");
            return;
        }
    } catch(e) {}
    renderDiscoverGrid("next-basket-grid", [], "🛍️ Next Basket");
}

async function loadRecencyWeighted(customerId) {
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/recommendations/recency-weighted/${customerId}?top_k=4`);
        if (res.ok) {
            const data = await res.json();
            renderDiscoverGrid("recency-weighted-grid", data.recommendations, "⏱️ Recency Weighted");
            return;
        }
    } catch(e) {}
    renderDiscoverGrid("recency-weighted-grid", [], "⏱️ Recency Weighted");
}

async function loadPriceSmart(customerId) {
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/recommendations/price-aware/${customerId}?top_k=4`);
        if (res.ok) {
            const data = await res.json();
            renderDiscoverGrid("price-smart-grid", data.recommendations, "💰 Price Smart");
            return;
        }
    } catch(e) {}
    renderDiscoverGrid("price-smart-grid", [], "💰 Price Smart");
}

async function loadLocalPopular(customerId) {
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/recommendations/local-popularity?buyer_id=${customerId}&top_k=4`);
        if (res.ok) {
            const data = await res.json();
            renderDiscoverGrid("local-popular-grid", data.recommendations, "📍 Local Popular");
            return;
        }
    } catch(e) {}
    renderDiscoverGrid("local-popular-grid", [], "📍 Local Popular");
}

function handleColdStartUI(isNewCustomer) {
    const welcomePanel = document.getElementById("cold-start-welcome");
    const personLabel = document.getElementById("discover-personalization-label");
    if (!welcomePanel || !personLabel) return;

    if (isNewCustomer) {
        welcomePanel.style.display = "block";
        personLabel.textContent = "Cold-Start Mode";
        personLabel.style.background = "#ff6b35";
    } else {
        welcomePanel.style.display = "none";
        personLabel.textContent = "Personalized";
        personLabel.style.background = "#1565c0";
    }
}

function renderDiscoverGrid(elementId, items, modelLabel) {
    const grid = document.getElementById(elementId);
    if (!grid) return;
    grid.innerHTML = "";

    if (!items || items.length === 0) {
        grid.innerHTML = `
            <div style="grid-column: 1/-1; text-align: center; color: var(--text-muted); padding: 1.5rem;">
                <i class="fa-solid fa-seedling fa-lg" style="color: var(--primary); margin-bottom: 0.5rem;"></i>
                <div style="font-size: 0.9rem; margin-top: 0.5rem;">No recommendations generated. Add items to cart to train the model!</div>
            </div>`;
        return;
    }

    // Color themes for each section
    const colorMap = {
        "🛍️ Next Basket": { bg: "#e3f2fd", accent: "#1565c0", badge_bg: "#1565c0" },
        "⏱️ Recency Weighted": { bg: "#f3e5f5", accent: "#7b1fa2", badge_bg: "#7b1fa2" },
        "💰 Price Smart": { bg: "#fff3e0", accent: "#e65100", badge_bg: "#e65100" },
        "📍 Local Popular": { bg: "#e1f5fe", accent: "#0277bd", badge_bg: "#0277bd" }
    };
    const colors = colorMap[modelLabel] || { bg: "#e8f5e9", accent: "#2e7d32", badge_bg: "#2e7d32" };

    items.forEach((item, index) => {
        const crop = item.crop_name || "Fresh Harvest";
        const imgUrl = CROP_IMAGES[crop] || item.image_url || "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600";
        const price = item.price_per_unit || 35.0;
        const unit = item.unit || "kg";
        const organicBadge = item.is_organic
            ? `<span class="organic-badge"><i class="fa-solid fa-leaf"></i> Organic</span>`
            : "";
        const badge = item.badge || `${modelLabel} #${index + 1}`;
        const reason = item.reason || "Farm-fresh produce, carefully selected for you.";
        const score = item.score !== undefined ? (item.score * 100).toFixed(0) : null;

        grid.innerHTML += `
            <div class="listing-card" style="border-top: 3px solid ${colors.accent};">
                <div class="card-header-img" style="background-image: url('${imgUrl}');">
                    <span class="ml-rank-badge" style="background: ${colors.badge_bg};">${badge}</span>
                    ${organicBadge}
                </div>
                <div class="card-body">
                    <div>
                        <div class="listing-title">${crop}</div>
                        <div class="seller-info">${item.title || `${crop} — Mandya-Bengaluru Corridor`}</div>
                        
                        <div class="card-metrics-row">
                            <div class="metric-item">
                                <div class="lbl">Price</div>
                                <div class="val">₹${price.toFixed(2)}/${unit}</div>
                            </div>
                            <div class="metric-item">
                                <div class="lbl">Rating</div>
                                <div class="val" style="color: #f57c00;">★ ${item.rating_avg || 4.8}</div>
                            </div>
                            <div class="metric-item">
                                <div class="lbl">Grade</div>
                                <div class="val">${item.grade || "A"}</div>
                            </div>
                            ${score ? `
                            <div class="metric-item">
                                <div class="lbl">ML Score</div>
                                <div class="val" style="color: ${colors.accent}; font-weight: bold;">${score}%</div>
                            </div>` : ""}
                        </div>

                        <div class="ml-reason-box" style="font-size: 0.82rem; margin: 0.75rem 0; background: ${colors.bg}; padding: 0.6rem; border-radius: 8px; border-left: 3px solid ${colors.accent};">
                            <i class="fa-solid fa-wand-magic-sparkles" style="color: ${colors.accent};"></i>
                            <b>ML Reason:</b> ${reason}
                        </div>
                    </div>

                    <div class="card-actions">
                        <button class="btn-action btn-primary" onclick="addToCart('${crop}', '${item.listing_id || ''}')" style="background: ${colors.accent};">
                            <i class="fa-solid fa-cart-plus"></i> Add to Cart
                        </button>
                    </div>
                </div>
            </div>
        `;
    });
}

// Also reload discover tab when customer changes
const origOnCustomerChange = onCustomerChange;
onCustomerChange = function(customerId) {
    origOnCustomerChange(customerId);
    // If discover tab is active, reload it too
    const discoverTab = document.getElementById('discover-tab');
    if (discoverTab && discoverTab.classList.contains('active')) {
        loadDiscoverDashboard(customerId);
    }
};
