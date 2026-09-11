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


