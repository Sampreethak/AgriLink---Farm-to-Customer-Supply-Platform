// AgriLink Multi-Model Customer Recommendation Web Dashboard Logic

// Dynamically detect current host (AWS EC2, custom domain, or localhost)
const API_ML_URL = window.location.origin;
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

let preferredLanguage = localStorage.getItem("agrilink_pref_lang") || "en";

async function onPersonaLanguageChange(langCode) {
    preferredLanguage = langCode;
    localStorage.setItem("agrilink_pref_lang", langCode);
    const activeTab = document.querySelector(".tab-content.active")?.id || "marketplace-tab";
    const persona = activeTab.includes("farmer") ? "FARMER" : (activeTab.includes("delivery") ? "DELIVERY" : "CUSTOMER");
    try {
        await fetch(`${API_ML_URL}/api/v1/users/language`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ persona: persona, language: langCode })
        });
    } catch (e) {
        console.warn("Language preference sync note:", e);
    }
    if (activeTab === "connect-tab") {
        loadPersonaMessages();
    }
}

async function loadPersonaMessages() {
    const box = document.getElementById("persona-chat-messages");
    if (!box) return;
    const channel = document.getElementById("chat-channel-select")?.value || "farmer-delivery";
    box.innerHTML = `<div style="color:var(--text-muted);">Loading &amp; translating messages into ${preferredLanguage.toUpperCase()}...</div>`;
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/messages?channel=${encodeURIComponent(channel)}&viewer_language=${encodeURIComponent(preferredLanguage)}`);
        if (!res.ok) return;
        const data = await res.json();
        const msgs = data.messages || [];
        if (msgs.length === 0) {
            box.innerHTML = `<div style="color:var(--text-muted);">No messages in this channel yet.</div>`;
            return;
        }
        box.innerHTML = msgs.map(m => {
            const translated = m.translated_text || m.text;
            const original = m.original_text || m.text;
            const showOrig = translated !== original;
            const safeSpeak = translated.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
            return `
                <div style="margin-bottom:0.85rem; padding:0.75rem 1rem; border-radius:10px; background:var(--dark-bg); border:1px solid var(--dark-border);">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:0.3rem;">
                        <span style="font-size:0.78rem; font-weight:bold; color:var(--primary);">${m.sender_name || m.sender_persona} (${m.sender_persona}) &bull; ${(m.sender_language || 'en').toUpperCase()}</span>
                        <div style="display:flex; gap:0.5rem; align-items:center;">
                            <button onclick="speakText('${safeSpeak}', '${preferredLanguage}')" style="background:rgba(34,197,94,0.15); border:1px solid var(--primary); color:var(--primary); padding:2px 8px; border-radius:6px; cursor:pointer; font-size:0.75rem;">
                                <i class="fa-solid fa-volume-high"></i> Listen
                            </button>
                            <span style="font-size:0.72rem; color:var(--text-muted);">${m.created_at || ''}</span>
                        </div>
                    </div>
                    <div style="color:#f8fafc; font-size:0.95rem;">${translated}</div>
                    ${showOrig ? `<div style="color:var(--text-muted); font-size:0.78rem; font-style:italic; margin-top:0.25rem;">Original (${(m.sender_language || 'en').toUpperCase()}): ${original}</div>` : ''}
                </div>
            `;
        }).join("");
        box.scrollTop = box.scrollHeight;
    } catch (e) {
        box.innerHTML = `<div style="color:#ef4444;">Failed to load messages: ${e}</div>`;
    }
}

async function sendPersonaMessage() {
    const input = document.getElementById("persona-chat-input");
    const text = (input?.value || "").trim();
    if (!text) return;
    const channel = document.getElementById("chat-channel-select")?.value || "farmer-delivery";
    const senderPersona = document.getElementById("chat-sender-persona")?.value || "FARMER";
    const parts = channel.split("-");
    const recipient = parts.find(p => p.toUpperCase() !== senderPersona) || parts[parts.length - 1];
    input.value = "";
    try {
        await fetch(`${API_ML_URL}/api/v1/messages`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                channel: channel,
                sender_persona: senderPersona,
                sender_name: senderPersona.charAt(0) + senderPersona.slice(1).toLowerCase(),
                recipient_persona: recipient.toUpperCase(),
                text: text,
                sender_language: preferredLanguage
            })
        });
        await loadPersonaMessages();
    } catch (e) {
        console.error("Send message failed:", e);
    }
}

function startMicForPersonaChat() {
    const SpeechRec = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRec) {
        alert("Voice microphone is supported in Chrome/Edge browsers.");
        return;
    }
    const rec = new SpeechRec();
    rec.lang = SPEECH_BCP47[preferredLanguage] || "en-IN";
    rec.interimResults = false;
    rec.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        const input = document.getElementById("persona-chat-input");
        if (input) input.value = transcript;
    };
    rec.start();
}

const WEB_KEYBOARD_KEYS = {
    kn: ["ನಮಸ್ಕಾರ", "ಟೊಮ್ಯಾಟೊ", "ಈರುಳ್ಳಿ", "ಸಿದ್ಧವಾಗಿದೆ", "ಬರುತ್ತಿದ್ದೇನೆ", "ಅ", "ಆ", "ಇ", "ಈ", "ಉ", "ಎ", "ಏ", "ಒ", "ಓ", "ಕ", "ಗ", "ಚ", "ಜ", "ಟ", "ಡ", "ತ", "ದ", "ನ", "ಪ", "ಬ", "ಮ", "ಯ", "ರ", "ಲ", "ವ", "ಶ", "ಸ", "ಹ", "ಳ", "ಾ", "ಿ", "ೀ", "ು", "ೂ", "ೆ", "ೇ", "ೊ", "ೋ", "್"],
    hi: ["नमस्ते", "टमाटर", "प्याज", "तैयार है", "आ रहा हूँ", "अ", "आ", "इ", "ई", "उ", "ए", "ऐ", "ओ", "औ", "क", "ग", "च", "ज", "ट", "ड", "त", "द", "न", "प", "ब", "म", "य", "र", "ल", "व", "श", "स", "ह", "ा", "ि", "ी", "ु", "ू", "े", "ै", "ो", "ौ", "्"],
    te: ["నమస్కారం", "టమోటా", "ఉల్లిపాయ", "సిద్ధంగా ఉంది", "అ", "ఆ", "ఇ", "ఈ", "ఉ", "ఎ", "ఏ", "ఒ", "ఓ", "క", "గ", "చ", "జ", "ట", "డ", "త", "ద", "న", "ప", "బ", "మ", "య", "ర", "ల", "వ", "స", "హ", "ా", "ి", "ీ", "ు", "ూ", "ె", "ే", "ొ", "ో", "్"],
    ta: ["வணக்கம்", "தக்காளி", "வெங்காயம்", "தயாராக உள்ளது", "அ", "ஆ", "இ", "ஈ", "உ", "எ", "ஏ", "ஒ", "ஓ", "க", "ச", "ட", "த", "ந", "ப", "ம", "ய", "ர", "ல", "வ", "ழ", "ள", "ா", "ி", "ீ", "ு", "ூ", "ெ", "ே", "ொ", "ோ", "்"],
    ml: ["നമസ്കാരം", "തക്കാളി", "ഉള്ളി", "തയ്യാറാണ്", "അ", "ആ", "ഇ", "ഈ", "ഉ", "എ", "ഏ", "ഒ", "ഓ", "ക", "ഗ", "ച", "ജ", "ട", "ഡ", "ത", "ദ", "ന", "പ", "ബ", "മ", "യ", "ര", "ല", "വ", "സ", "ഹ", "ാ", "ി", "ീ", "ു", "ൂ", "െ", "േ", "ൊ", "ോ", "്"],
    en: ["Hello", "Ready for pickup", "On my way", "In stock", "Thank you"]
};

function toggleWebKeyboard() {
    const kb = document.getElementById("web-multilingual-keyboard");
    if (!kb) return;
    if (kb.style.display === "none") {
        kb.style.display = "block";
        renderWebKeyboard();
    } else {
        kb.style.display = "none";
    }
}

function renderWebKeyboard() {
    const kb = document.getElementById("web-multilingual-keyboard");
    if (!kb) return;
    const keys = WEB_KEYBOARD_KEYS[preferredLanguage] || WEB_KEYBOARD_KEYS.en;
    kb.innerHTML = `
        <div style="font-size:0.78rem; color:var(--primary); font-weight:bold; margin-bottom:0.5rem;">${preferredLanguage.toUpperCase()} Virtual Keyboard &amp; Quick Farm Phrases</div>
        <div style="display:flex; flex-wrap:wrap; gap:5px;">
            ${keys.map(k => `<button type="button" onclick="insertWebKey('${k}')" style="padding:5px 9px; border-radius:6px; border:1px solid var(--dark-border); background:var(--dark-bg); color:white; cursor:pointer; font-size:0.88rem;">${k}</button>`).join("")}
            <button type="button" onclick="insertWebKey(' ')" style="padding:5px 12px; border-radius:6px; border:1px solid var(--dark-border); background:var(--dark-bg); color:white; cursor:pointer; font-size:0.8rem;">Space</button>
            <button type="button" onclick="backspaceWebKey()" style="padding:5px 10px; border-radius:6px; border:1px solid #ef4444; background:rgba(239,68,68,0.15); color:#fca5a5; cursor:pointer; font-size:0.8rem;">&#9003;</button>
        </div>
    `;
}

function insertWebKey(val) {
    const input = document.getElementById("persona-chat-input");
    if (!input) return;
    input.value += val + (val.length > 1 ? " " : "");
    input.focus();
}

function backspaceWebKey() {
    const input = document.getElementById("persona-chat-input");
    if (!input) return;
    input.value = input.value.slice(0, -1);
    input.focus();
}

async function convertWebPhonetic() {
    const input = document.getElementById("persona-chat-input");
    const raw = (input?.value || "").trim();
    if (!raw || preferredLanguage === "en") return;
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/ai/transliterate`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ text: raw, target_language: preferredLanguage })
        });
        if (res.ok) {
            const data = await res.json();
            if (data.transliterated_text) input.value = data.transliterated_text;
        }
    } catch (e) {
        console.warn("Transliterate error:", e);
    }
}

async function translateCardText(btn, originalText) {
    const cardBody = btn.closest(".card-body");
    const titleEl = cardBody ? cardBody.querySelector(".listing-title") : null;
    if (!titleEl) return;
    titleEl.textContent = "Translating...";
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/ai/translate`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ text: originalText, target_language: preferredLanguage })
        });
        if (res.ok) {
            const data = await res.json();
            titleEl.textContent = data.translated_text || originalText;
            return;
        }
    } catch (e) {
        console.warn("Translation note:", e);
    }
    titleEl.textContent = originalText;
}

const SPEECH_BCP47 = {
    en: "en-IN",
    kn: "kn-IN",
    hi: "hi-IN",
    te: "te-IN",
    ta: "ta-IN",
    ml: "ml-IN"
};

let activeTtsAudio = null;

function speakText(text, langCode = preferredLanguage) {
    const clean = (text || "").replace(/<[^>]*>/g, " ").replace(/[*_#`•🌾🧪🌿⚠️⏱️🛡️]/g, " ").replace(/\s+/g, " ").trim();
    if (!clean) return;
    if (activeTtsAudio) {
        activeTtsAudio.pause();
        activeTtsAudio = null;
    }
    if ("speechSynthesis" in window) {
        window.speechSynthesis.cancel();
    }
    const ttsUrl = `${API_ML_URL}/api/v1/ai/tts?text=${encodeURIComponent(clean)}&lang=${encodeURIComponent(langCode || "en")}`;
    const audio = new Audio(ttsUrl);
    activeTtsAudio = audio;
    audio.play().catch(() => {
        if (!("speechSynthesis" in window)) return;
        const utterance = new SpeechSynthesisUtterance(clean);
        utterance.lang = SPEECH_BCP47[langCode] || "en-IN";
        utterance.rate = 0.95;
        window.speechSynthesis.speak(utterance);
    });
}

function speakCardText(btn) {
    const cardBody = btn.closest(".card-body");
    const title = cardBody ? (cardBody.querySelector(".listing-title")?.textContent || "") : "";
    const seller = cardBody ? (cardBody.querySelector(".seller-info")?.textContent || "") : "";
    speakText(`${title}. ${seller}`, preferredLanguage);
}

document.addEventListener("DOMContentLoaded", () => {
    const langSel = document.getElementById("persona-lang-select");
    if (langSel) langSel.value = preferredLanguage;
    loadAllRecommendations(currentCustomerId);
    renderAllListings();
    loadFarmerListings();
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

async function renderAllListings(searchQuery = "") {
    const grid = document.getElementById("all-listings-grid");
    if (!grid) return;

    let items = [];
    try {
        const q = (searchQuery || "").trim();
        const url = q
            ? `${API_ML_URL}/api/v1/listings?search=${encodeURIComponent(q)}`
            : `${API_ML_URL}/api/v1/listings`;
        const res = await fetch(url);
        if (res.ok) {
            const data = await res.json();
            items = data.products || [];
        }
    } catch (e) {
        console.warn("Live listings fetch note:", e);
    }

    grid.innerHTML = "";
    if (items.length === 0) {
        grid.innerHTML = `<div style="grid-column: 1 / -1; text-align: center; padding: 2rem; color: var(--text-muted);">No matching crop listings found${searchQuery ? ` for "<b>${searchQuery}</b>"` : ""}.</div>`;
        return;
    }

    items.forEach(item => {
        const crop = item.crop_name || item.name || "Produce";
        const title = item.title || item.name || crop;
        const farmer = item.farmer_name || "Direct Farmer";
        const price = Number(item.price_per_unit ?? item.price ?? 30);
        const unit = item.unit || "kg";
        const grade = item.grade || "A";
        const location = item.location || "Mandya, Karnataka";
        const inStock = item.in_stock !== undefined ? Boolean(item.in_stock) : (Number(item.available_quantity ?? 1) > 0 && item.status !== "OUT_OF_STOCK");
        const imgUrl = item.image_url || CROP_IMAGES[crop] || CROP_IMAGES["Tomato"];

        grid.innerHTML += `
            <div class="listing-card" style="${inStock ? "" : "opacity: 0.72;"}">
                <div class="card-header-img" style="background-image: url('${imgUrl}');">
                    <span class="organic-badge">${item.is_organic ? "Organic Certified" : "Conventional Fresh"}</span>
                    <span class="organic-badge" style="top: auto; bottom: 8px; background: ${inStock ? "#16a34a" : "#dc2626"};">${inStock ? "In Stock" : "Out of Stock"}</span>
                </div>
                <div class="card-body">
                    <div class="listing-title">${title}</div>
                    <div class="seller-info"><i class="fa-solid fa-user-tie"></i> Farmer: <b>${farmer}</b> &bull; ${location}</div>
                    <div class="card-metrics-row">
                        <div class="metric-item">
                            <div class="lbl">Price</div>
                            <div class="val">₹${price.toFixed(2)}/${unit}</div>
                        </div>
                        <div class="metric-item">
                            <div class="lbl">Crop</div>
                            <div class="val">${crop}</div>
                        </div>
                        <div class="metric-item">
                            <div class="lbl">Grade</div>
                            <div class="val">${grade}</div>
                        </div>
                    </div>
                    <div class="card-actions" style="display:flex; gap:0.4rem;">
                        <button class="btn-action btn-primary" ${inStock ? "" : "disabled style='background:#64748b;cursor:not-allowed;'"} onclick="addToCart('${crop}', '${item.id || ''}')">
                            <i class="fa-solid fa-cart-plus"></i> ${inStock ? "Add to Cart" : "Out of Stock"}
                        </button>
                        <button class="btn-action btn-secondary" style="width:auto; padding:0 10px;" title="Translate to preferred language" onclick="translateCardText(this, '${title.replace(/'/g, "\\'")}')">
                            <i class="fa-solid fa-language"></i>
                        </button>
                        <button class="btn-action btn-secondary" style="width:auto; padding:0 10px;" title="Listen (Speaker)" onclick="speakCardText(this)">
                            <i class="fa-solid fa-volume-high"></i>
                        </button>
                    </div>
                </div>
            </div>
        `;
    });
}

async function loadFarmerListings() {
    const tbody = document.getElementById("farmer-listings-tbody");
    if (!tbody) return;
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/listings`);
        if (!res.ok) return;
        const data = await res.json();
        const items = data.products || [];
        tbody.innerHTML = items.map(item => {
            const inStock = item.in_stock !== undefined ? Boolean(item.in_stock) : (Number(item.available_quantity ?? 0) > 0 && item.status !== "OUT_OF_STOCK");
            const qty = Number(item.available_quantity ?? item.stock_quantity ?? 0);
            const price = Number(item.price_per_unit ?? item.price ?? 0);
            return `
                <tr>
                    <td><b>${item.title || item.name}</b> <span style="color:var(--text-muted);font-size:0.8rem;">(${item.crop_name})</span></td>
                    <td>${item.farmer_name || "Farmer"}</td>
                    <td>${item.location || "Mandya"}</td>
                    <td>₹${price.toFixed(2)}/${item.unit || "kg"}</td>
                    <td>${qty} ${item.unit || "kg"}</td>
                    <td>
                        <button onclick="toggleFarmerStock(${item.id}, ${!inStock})" style="padding: 5px 12px; border: none; border-radius: 999px; font-weight: bold; cursor: pointer; color: white; background: ${inStock ? "#16a34a" : "#dc2626"};">
                            ${inStock ? "✓ In Stock (Click to Mark Out)" : "✕ Out of Stock (Click to Restock)"}
                        </button>
                    </td>
                </tr>
            `;
        }).join("");
    } catch (e) {
        console.warn("Farmer listings load error:", e);
    }
}

async function toggleFarmerStock(listingId, newInStock) {
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/listings/${listingId}/stock`, {
            method: "PATCH",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ in_stock: newInStock })
        });
        if (res.ok) {
            await loadFarmerListings();
            const q = document.getElementById("marketplace-crop-search")?.value || "";
            await renderAllListings(q);
        }
    } catch (e) {
        console.error("Stock toggle failed:", e);
    }
}

async function publishFarmerListing(event) {
    event.preventDefault();
    const farmerName = document.getElementById("f-farmer-name").value.trim();
    const cropName = document.getElementById("f-crop-name").value.trim();
    const price = parseFloat(document.getElementById("f-price").value);
    const qty = parseFloat(document.getElementById("f-qty").value);
    const location = document.getElementById("f-location").value.trim();

    try {
        const res = await fetch(`${API_ML_URL}/api/v1/listings`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                farmer_name: farmerName,
                title: `Fresh ${cropName} (${farmerName})`,
                crop_name: cropName,
                category_id: 1,
                description: `Freshly harvested ${cropName} listed by ${farmerName}.`,
                price_per_unit: price,
                unit: "kg",
                available_quantity: qty,
                is_organic: true,
                grade: "A",
                location: location
            })
        });
        if (res.ok) {
            document.getElementById("f-crop-name").value = "";
            document.getElementById("f-price").value = "";
            await loadFarmerListings();
            await renderAllListings(document.getElementById("marketplace-crop-search")?.value || "");
        }
    } catch (e) {
        console.error("Publish listing failed:", e);
    }
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
        initNlpDashboard();
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

// ============================================================
// FARMER QUERY & ADVISORY INSIGHTS DASHBOARD (NLP PHASE 3)
// ============================================================

const NLP_ADVISORY_DATA = [
    {
        id: "rice-stem-borer",
        crop: "Rice",
        problem: "Stem Borer & Leaf Folder",
        category: "PEST_DISEASE",
        frequency: 89,
        severity: "High",
        symptoms: "Dead hearts at tillering stage, white ears at heading, folded leaf blades with larval scraping.",
        chemicalRemedy: "Tricel / Chlorpyrifos 20 EC @ 2ml/L water, or Cartap Hydrochloride 4G @ 10kg/acre.",
        bioControl: "Release Trichogramma japonicum egg parasitoid @ 5 cards/acre; avoid staggered planting.",
        suggestedQuery: "How to control stem borer and leaf folder in rice?"
    },
    {
        id: "potato-late-blight",
        crop: "Potato",
        problem: "Late Blight Outbreak",
        category: "PEST_DISEASE",
        frequency: 65,
        severity: "Critical",
        symptoms: "Irregular water-soaked brown lesions on leaves and stems, white fungal growth under humid canopy.",
        chemicalRemedy: "Indofil M-45 (Mancozeb 75 WP) @ 2.5g/L preventive; Ridomil Gold @ 2g/L curative.",
        bioControl: "Spray Trichoderma viride @ 5g/L; avoid overhead sprinkler irrigation during cloudy weather.",
        suggestedQuery: "Treatment for potato late blight fungal infection"
    },
    {
        id: "cucurbits-fruit-fly",
        crop: "Cucurbits",
        problem: "Fruit Fly Maggot Rot",
        category: "PEST_DISEASE",
        frequency: 56,
        severity: "High",
        symptoms: "Sunken oviposition punctures on young gourds/melons, larval rotting and premature fruit dropping.",
        chemicalRemedy: "Bait spray: Malathion 50 EC (2ml/L) + 10g Jaggery / Molasses in 1L water on foliage.",
        bioControl: "Install Cue-lure pheromone traps (6-8 traps per acre) 15 days before flowering.",
        suggestedQuery: "Control of fruit fly maggots in cucumber and bottle gourd"
    },
    {
        id: "brinjal-shoot-borer",
        crop: "Brinjal",
        problem: "Shoot & Fruit Borer (Leucinodes)",
        category: "PEST_DISEASE",
        frequency: 52,
        severity: "High",
        symptoms: "Wilted and drooping terminal shoot tips, circular exit holes in mature brinjal fruits with frass.",
        chemicalRemedy: "Spinosad 45 SC @ 0.4ml/L or Emamectin Benzoate 5 SG @ 0.5g/L water.",
        bioControl: "Clip and burn wilted shoots weekly; spray Neem oil 1500 ppm @ 5ml/L.",
        suggestedQuery: "How to treat shoot and fruit borer in brinjal?"
    },
    {
        id: "chilli-leaf-curl",
        crop: "Chilli",
        problem: "Viral Leaf Curl & Thrips/Whitefly",
        category: "PEST_DISEASE",
        frequency: 50,
        severity: "High",
        symptoms: "Leaves curling upwards (thrips) or downwards (mites), thickened brittle veins, stunted bush.",
        chemicalRemedy: "Rogor (Dimethoate 30 EC) @ 2ml/L or Imidacloprid 17.8 SL @ 0.5ml/L for vector insect suppression.",
        bioControl: "Set up yellow and blue sticky traps (10-12 per acre); spray systemic neem formulation.",
        suggestedQuery: "Best spray for leaf curl and thrips in green chilli"
    },
    {
        id: "tomato-bacterial-wilt",
        crop: "Tomato",
        problem: "Bacterial & Fungal Wilt",
        category: "PEST_DISEASE",
        frequency: 39,
        severity: "Critical",
        symptoms: "Rapid daytime wilting of foliage without yellowing; vascular browning visible inside cut stem.",
        chemicalRemedy: "Root drench with Streptocycline (1g/10L) + Copper Oxychloride / Blitox (30g/10L water).",
        bioControl: "Incorporate bio-agent Pseudomonas fluorescens @ 2.5kg/acre enriched in FYM at planting.",
        suggestedQuery: "Tomato bacterial wilt root drenching and cure"
    },
    {
        id: "tomato-blight",
        crop: "Tomato",
        problem: "Early & Late Blight Spots",
        category: "PEST_DISEASE",
        frequency: 34,
        severity: "High",
        symptoms: "Concentric target-board rings on bottom leaves, yellow chlorotic margins turning into brown necrosis.",
        chemicalRemedy: "Indofil M-45 (Mancozeb) @ 2.5g/L or Saaf (Carbendazim + Mancozeb) @ 2g/L at first symptom.",
        bioControl: "Maintain good crop canopy air circulation; mulch beds to prevent rain-splash spores.",
        suggestedQuery: "How to cure tomato blight spots and leaf yellowing"
    },
    {
        id: "coconut-nut-drop",
        crop: "Coconut",
        problem: "Button Shedding & Nut Drop",
        category: "FERTILIZER",
        frequency: 31,
        severity: "Moderate",
        symptoms: "Immature female flowers (buttons) and marble-sized young coconuts drying and dropping profusely.",
        chemicalRemedy: "Soil application of Borax (50g/palm/year) + balanced annual NPK ring dose (500g N, 320g P, 1200g K).",
        bioControl: "Maintain summer basin irrigation (45L/palm/day) and apply green leaf mulch.",
        suggestedQuery: "Coconut premature nut drop and borax fertilizer dose"
    },
    {
        id: "rice-blast",
        crop: "Rice",
        problem: "Blast & Brown Spot (Pyricularia)",
        category: "PEST_DISEASE",
        frequency: 30,
        severity: "High",
        symptoms: "Spindle-shaped lesions with ash-grey center and brownish-red borders on leaf blades and neck nodes.",
        chemicalRemedy: "Tricyclazole 75 WP (Baan) @ 0.6g/L or Bavistin (Carbendazim 50 WP) @ 1g/L at panicle emergence.",
        bioControl: "Avoid excessive nitrogen split applications; seed treatment with Trichoderma @ 10g/kg seed.",
        suggestedQuery: "Rice leaf blast and neck blast fungicide treatment"
    },
    {
        id: "npk-dosing-bigha",
        crop: "All",
        problem: "NPK Fertilizer Dosing per Bigha/Acre",
        category: "FERTILIZER",
        frequency: 293,
        severity: "Moderate",
        symptoms: "Uneven vegetative vigor, nitrogen deficiency chlorosis or excessive lush prone to lodging.",
        chemicalRemedy: "Paddy: Urea 44kg, SSP 125kg, MOP 33kg per bigha. Split Urea 50% basal, 25% tillering, 25% panicle.",
        bioControl: "Apply Azospirillum and PSB biofertilizer @ 2kg/acre mixed with 200kg vermicompost.",
        suggestedQuery: "What is the recommended NPK fertilizer dose per bigha for crops?"
    },
    {
        id: "cattle-diarrhoea",
        crop: "All",
        problem: "Cattle Diarrhoea & Bovine Health",
        category: "VETERINARY",
        frequency: 250,
        severity: "High",
        symptoms: "Profuse watery dung, calf scour, dehydration, loss of appetite, hollow flanks.",
        chemicalRemedy: "Oral electrolyte hydration solution + Bolus Neblon / Sulpha bolus (2 boluses twice daily for 3 days).",
        bioControl: "Feed boiled rice gruel (congee) with fenugreek; withhold lush wet forage during acute phase.",
        suggestedQuery: "Treatment for cow diarrhoea and dehydration remedies"
    },
    {
        id: "pm-kisan-portal",
        crop: "All",
        problem: "PM-Kisan & KCC Direct Assistance",
        category: "SCHEMES",
        frequency: 234,
        severity: "Moderate",
        symptoms: "Beneficiary status pending, e-KYC mismatch, land seeding status no, or bank DBT rejected.",
        chemicalRemedy: "Verify Aadhaar-Bank NPCI mapping on pmkisan.gov.in portal. Visit local Raitha Samparka Kendra.",
        bioControl: "Call national Kisan Call Center helpline 1800-180-1551 (toll-free, 6 AM to 10 PM in Kannada/Hindi/English).",
        suggestedQuery: "How to check PM-Kisan installment status and KCC loan interest rate"
    }
];

let currentNlpDomain = 'All';
let currentNlpCrop = 'All';
let nlpChartsInitialized = false;

function initNlpDashboard() {
    renderNlpAdvisoryGrid();
    if (!nlpChartsInitialized && typeof Chart !== 'undefined') {
        renderNlpCharts();
        nlpChartsInitialized = true;
    }
}

function renderNlpCharts() {
    const doughnutCanvas = document.getElementById('nlpDomainDoughnutChart');
    if (doughnutCanvas) {
        new Chart(doughnutCanvas, {
            type: 'doughnut',
            data: {
                labels: ['Pest & Disease Control', 'Cultivation & General', 'Fertilizer Dose', 'Livestock Treatment', 'PM-Kisan & Schemes'],
                datasets: [{
                    data: [45.0, 22.3, 13.4, 11.2, 8.2],
                    backgroundColor: ['#10b981', '#f59e0b', '#3b82f6', '#ef4444', '#8b5cf6'],
                    borderWidth: 2,
                    borderColor: '#1e293b'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { color: '#94a3b8', font: { size: 11 } }
                    },
                    tooltip: {
                        callbacks: {
                            label: (c) => ` ${c.label}: ${c.raw}% (Cluster share)`
                        }
                    }
                }
            }
        });
    }

    const barCanvas = document.getElementById('nlpCropProblemBarChart');
    if (barCanvas) {
        new Chart(barCanvas, {
            type: 'bar',
            data: {
                labels: [
                    'Rice × Stem Borer',
                    'Potato × Late Blight',
                    'Cucurbits × Fruit Fly',
                    'Brinjal × Shoot Borer',
                    'Chilli × Leaf Curl',
                    'Tomato × Wilt',
                    'Rice × Sucking Pests',
                    'Tomato × Blight'
                ],
                datasets: [{
                    label: 'Farmer Query Frequency',
                    data: [89, 65, 56, 52, 50, 39, 35, 34],
                    backgroundColor: [
                        '#10b981', '#3b82f6', '#f59e0b', '#8b5cf6',
                        '#ef4444', '#06b6d4', '#10b981', '#3b82f6'
                    ],
                    borderRadius: 6
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: (c) => ` ${c.raw} Verified Farmer Inquiries`
                        }
                    }
                },
                scales: {
                    x: {
                        grid: { color: 'rgba(255,255,255,0.06)' },
                        ticks: { color: '#94a3b8' }
                    },
                    y: {
                        grid: { display: false },
                        ticks: { color: '#f8fafc', font: { size: 11 } }
                    }
                }
            }
        });
    }
}

function setNlpDomain(domain, btn) {
    currentNlpDomain = domain;
    document.querySelectorAll('#nlp-domain-filter-btns .nav-btn').forEach(b => b.classList.remove('active'));
    if (btn) btn.classList.add('active');
    renderNlpAdvisoryGrid();
}

function setNlpCrop(crop, btn) {
    currentNlpCrop = crop;
    document.querySelectorAll('.crop-pill').forEach(b => b.classList.remove('active'));
    if (btn) btn.classList.add('active');
    renderNlpAdvisoryGrid();
}

function filterNlpAdvisory() {
    renderNlpAdvisoryGrid();
}

function renderNlpAdvisoryGrid() {
    const grid = document.getElementById('nlp-advisory-cards-grid');
    if (!grid) return;

    const searchInput = document.getElementById('nlp-search-input');
    const query = searchInput ? searchInput.value.trim().toLowerCase() : '';

    const filtered = NLP_ADVISORY_DATA.filter(item => {
        if (currentNlpDomain !== 'All' && item.category !== currentNlpDomain) {
            return false;
        }
        if (currentNlpCrop !== 'All' && item.crop !== currentNlpCrop && item.crop !== 'All') {
            return false;
        }
        if (query) {
            const matches = item.crop.toLowerCase().includes(query) ||
                            item.problem.toLowerCase().includes(query) ||
                            item.symptoms.toLowerCase().includes(query) ||
                            item.chemicalRemedy.toLowerCase().includes(query);
            if (!matches) return false;
        }
        return true;
    });

    if (filtered.length === 0) {
        grid.innerHTML = `
            <div style="grid-column: 1/-1; padding: 2rem; text-align: center; background: var(--dark-surface); border-radius: 12px; border: 1px dashed var(--dark-border); color: var(--text-muted);">
                <i class="fa-solid fa-seedling fa-2xl" style="color: var(--warning); margin-bottom: 0.75rem;"></i>
                <div style="font-weight: bold; color: var(--text-main); font-size: 1rem;">No matching advisory cards found</div>
                <div style="font-size: 0.85rem; margin-top: 0.25rem;">Try searching for Rice, Blight, Leaf Curl, Urea, or Borax.</div>
            </div>
        `;
        return;
    }

    grid.innerHTML = filtered.map(item => {
        let severityBadge = `<span style="background: rgba(245, 158, 11, 0.15); color: #f59e0b; border: 1px solid #f59e0b; font-size: 0.7rem; font-weight: bold; padding: 2px 8px; border-radius: 6px;">${item.severity}</span>`;
        if (item.severity === 'Critical') {
            severityBadge = `<span style="background: rgba(239, 68, 68, 0.15); color: #ef4444; border: 1px solid #ef4444; font-size: 0.7rem; font-weight: bold; padding: 2px 8px; border-radius: 6px;">Critical</span>`;
        } else if (item.severity === 'Moderate') {
            severityBadge = `<span style="background: rgba(59, 130, 246, 0.15); color: #3b82f6; border: 1px solid #3b82f6; font-size: 0.7rem; font-weight: bold; padding: 2px 8px; border-radius: 6px;">Moderate</span>`;
        }

        return `
            <div class="stat-card" style="background: var(--dark-surface); border: 1px solid var(--dark-border); border-radius: 12px; padding: 1.25rem; display: flex; flex-direction: column; justify-content: space-between;">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 0.5rem;">
                        <span style="background: rgba(16, 185, 129, 0.15); color: var(--primary); padding: 3px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: bold;">${item.crop}</span>
                        <div style="display: flex; gap: 0.4rem; align-items: center;">
                            ${severityBadge}
                            <span style="font-size: 0.7rem; color: var(--text-muted);">${item.frequency} calls</span>
                        </div>
                    </div>

                    <h4 style="font-size: 1rem; color: var(--text-main); margin: 0.75rem 0 0.4rem 0;">${item.problem}</h4>
                    <p style="font-size: 0.8rem; color: var(--text-muted); line-height: 1.4; margin-bottom: 0.75rem;">
                        <i class="fa-solid fa-circle-exclamation" style="color: var(--warning); margin-right: 4px;"></i> <b>Symptoms:</b> ${item.symptoms}
                    </p>

                    <div style="background: rgba(16, 185, 129, 0.08); border-left: 3px solid var(--primary); padding: 0.6rem 0.8rem; border-radius: 6px; font-size: 0.8rem; color: #a7f3d0; margin-bottom: 0.5rem; line-height: 1.4;">
                        <b><i class="fa-solid fa-prescription-bottle-medical"></i> Remedy:</b> ${item.chemicalRemedy}
                    </div>

                    <div style="background: rgba(245, 158, 11, 0.08); border-left: 3px solid var(--warning); padding: 0.6rem 0.8rem; border-radius: 6px; font-size: 0.78rem; color: #fde68a; line-height: 1.35;">
                        <b><i class="fa-solid fa-leaf"></i> Bio Tip:</b> ${item.bioControl}
                    </div>
                </div>

                <div style="margin-top: 1rem; border-top: 1px solid var(--dark-border); padding-top: 0.75rem;">
                    <div id="inline-response-${item.id}" style="display: none; margin-bottom: 0.75rem; padding: 0.75rem; background: var(--dark-bg); border-radius: 8px; border: 1px solid var(--primary); font-size: 0.82rem; color: #e2e8f0; line-height: 1.45;"></div>
                    <button onclick="askAgriTalkInline('${item.suggestedQuery.replace(/'/g, "\\'")}', '${item.id}')" style="background: var(--primary); color: white; border: none; padding: 6px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: bold; cursor: pointer; width: 100%; display: flex; align-items: center; justify-content: center; gap: 0.5rem;">
                        <i class="fa-solid fa-robot"></i> Ask AgriTalk AI
                    </button>
                </div>
            </div>
        `;
    }).join('');
}

async function askAgriTalkInline(query, cardId) {
    const box = document.getElementById(`inline-response-${cardId}`);
    if (!box) return;

    box.style.display = 'block';
    box.innerHTML = `<i class="fa-solid fa-spinner fa-spin" style="color: var(--primary);"></i> Consulting AgriTalk AI NLP Engine for: <i>"${query}"</i>...`;

    try {
        const res = await fetch('/api/v1/nlp/query', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ query: query, language: 'en', role: 'FARMER' })
        });
        if (res.ok) {
            const data = await res.json();
            const reply = data.response ? data.response.replace(/\n/g, '<br>') : 'Received recommendation from AgriTalk.';
            box.innerHTML = `
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.4rem;">
                    <span style="font-weight: bold; color: var(--primary);"><i class="fa-solid fa-robot"></i> AgriTalk AI Advisory:</span>
                    <div style="display:flex; gap:0.5rem; align-items:center;">
                        <button onclick="speakText(document.getElementById('inline-reply-${cardId}').innerText, preferredLanguage)" title="Listen" style="background: rgba(34,197,94,0.15); border: 1px solid var(--primary); color: var(--primary); padding: 2px 8px; border-radius: 6px; cursor: pointer; font-size: 0.75rem;"><i class="fa-solid fa-volume-high"></i> Listen</button>
                        <button onclick="document.getElementById('inline-response-${cardId}').style.display='none'" style="background: none; border: none; color: var(--text-muted); cursor: pointer;"><i class="fa-solid fa-xmark"></i></button>
                    </div>
                </div>
                <div id="inline-reply-${cardId}">${reply}</div>
            `;
            return;
        }
    } catch (e) {
        console.warn('FastAPI live NLP query note:', e);
    }

    // Fallback response if offline
    box.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.4rem;">
            <span style="font-weight: bold; color: var(--primary);"><i class="fa-solid fa-robot"></i> AgriTalk AI Advisory:</span>
            <button onclick="document.getElementById('inline-response-${cardId}').style.display='none'" style="background: none; border: none; color: var(--text-muted); cursor: pointer;"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <div>🛡️ <b>Verified Treatment:</b> For <i>"${query}"</i>, apply recommended dose early morning or late afternoon. Combine bio-control sticky traps and avoid water-logging.</div>
    `;
}

// Auto-initialize when page loads if on farmer tab
let preferredLanguage = localStorage.getItem("agrilink_pref_lang") || "en";

async function onPersonaLanguageChange(langCode) {
    preferredLanguage = langCode;
    localStorage.setItem("agrilink_pref_lang", langCode);
    const activeTab = document.querySelector(".tab-content.active")?.id || "marketplace-tab";
    const persona = activeTab.includes("farmer") ? "FARMER" : (activeTab.includes("delivery") ? "DELIVERY" : "CUSTOMER");
    try {
        await fetch(`${API_ML_URL}/api/v1/users/language`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ persona: persona, language: langCode })
        });
    } catch (e) {
        console.warn("Language preference sync note:", e);
    }
    if (activeTab === "connect-tab") {
        loadPersonaMessages();
    }
}

async function loadPersonaMessages() {
    const box = document.getElementById("persona-chat-messages");
    if (!box) return;
    const channel = document.getElementById("chat-channel-select")?.value || "farmer-delivery";
    box.innerHTML = `<div style="color:var(--text-muted);">Loading &amp; translating messages into ${preferredLanguage.toUpperCase()}...</div>`;
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/messages?channel=${encodeURIComponent(channel)}&viewer_language=${encodeURIComponent(preferredLanguage)}`);
        if (!res.ok) return;
        const data = await res.json();
        const msgs = data.messages || [];
        if (msgs.length === 0) {
            box.innerHTML = `<div style="color:var(--text-muted);">No messages in this channel yet.</div>`;
            return;
        }
        box.innerHTML = msgs.map(m => {
            const translated = m.translated_text || m.text;
            const original = m.original_text || m.text;
            const showOrig = translated !== original;
            const safeSpeak = translated.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
            return `
                <div style="margin-bottom:0.85rem; padding:0.75rem 1rem; border-radius:10px; background:var(--dark-bg); border:1px solid var(--dark-border);">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:0.3rem;">
                        <span style="font-size:0.78rem; font-weight:bold; color:var(--primary);">${m.sender_name || m.sender_persona} (${m.sender_persona}) &bull; ${(m.sender_language || 'en').toUpperCase()}</span>
                        <div style="display:flex; gap:0.5rem; align-items:center;">
                            <button onclick="speakText('${safeSpeak}', '${preferredLanguage}')" style="background:rgba(34,197,94,0.15); border:1px solid var(--primary); color:var(--primary); padding:2px 8px; border-radius:6px; cursor:pointer; font-size:0.75rem;">
                                <i class="fa-solid fa-volume-high"></i> Listen
                            </button>
                            <span style="font-size:0.72rem; color:var(--text-muted);">${m.created_at || ''}</span>
                        </div>
                    </div>
                    <div style="color:#f8fafc; font-size:0.95rem;">${translated}</div>
                    ${showOrig ? `<div style="color:var(--text-muted); font-size:0.78rem; font-style:italic; margin-top:0.25rem;">Original (${(m.sender_language || 'en').toUpperCase()}): ${original}</div>` : ''}
                </div>
            `;
        }).join("");
        box.scrollTop = box.scrollHeight;
    } catch (e) {
        box.innerHTML = `<div style="color:#ef4444;">Failed to load messages: ${e}</div>`;
    }
}

async function sendPersonaMessage() {
    const input = document.getElementById("persona-chat-input");
    const text = (input?.value || "").trim();
    if (!text) return;
    const channel = document.getElementById("chat-channel-select")?.value || "farmer-delivery";
    const senderPersona = document.getElementById("chat-sender-persona")?.value || "FARMER";
    const parts = channel.split("-");
    const recipient = parts.find(p => p.toUpperCase() !== senderPersona) || parts[parts.length - 1];
    input.value = "";
    try {
        await fetch(`${API_ML_URL}/api/v1/messages`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                channel: channel,
                sender_persona: senderPersona,
                sender_name: senderPersona.charAt(0) + senderPersona.slice(1).toLowerCase(),
                recipient_persona: recipient.toUpperCase(),
                text: text,
                sender_language: preferredLanguage
            })
        });
        await loadPersonaMessages();
    } catch (e) {
        console.error("Send message failed:", e);
    }
}

function startMicForPersonaChat() {
    const SpeechRec = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRec) {
        alert("Voice microphone is supported in Chrome/Edge browsers.");
        return;
    }
    const rec = new SpeechRec();
    rec.lang = SPEECH_BCP47[preferredLanguage] || "en-IN";
    rec.interimResults = false;
    rec.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        const input = document.getElementById("persona-chat-input");
        if (input) input.value = transcript;
    };
    rec.start();
}

const WEB_KEYBOARD_KEYS = {
    kn: ["ನಮಸ್ಕಾರ", "ಟೊಮ್ಯಾಟೊ", "ಈರುಳ್ಳಿ", "ಸಿದ್ಧವಾಗಿದೆ", "ಬರುತ್ತಿದ್ದೇನೆ", "ಅ", "ಆ", "ಇ", "ಈ", "ಉ", "ಎ", "ಏ", "ಒ", "ಓ", "ಕ", "ಗ", "ಚ", "ಜ", "ಟ", "ಡ", "ತ", "ದ", "ನ", "ಪ", "ಬ", "ಮ", "ಯ", "ರ", "ಲ", "ವ", "ಶ", "ಸ", "ಹ", "ಳ", "ಾ", "ಿ", "ೀ", "ು", "ೂ", "ೆ", "ೇ", "ೊ", "ೋ", "್"],
    hi: ["नमस्ते", "टमाटर", "प्याज", "तैयार है", "आ रहा हूँ", "अ", "आ", "इ", "ई", "उ", "ए", "ऐ", "ओ", "औ", "क", "ग", "च", "ज", "ट", "ड", "त", "द", "न", "प", "ब", "म", "य", "र", "ल", "व", "श", "स", "ह", "ा", "ि", "ी", "ु", "ू", "े", "ै", "ो", "ौ", "्"],
    te: ["నమస్కారం", "టమోటా", "ఉల్లిపాయ", "సిద్ధంగా ఉంది", "అ", "ఆ", "ఇ", "ఈ", "ఉ", "ఎ", "ఏ", "ఒ", "ఓ", "క", "గ", "చ", "జ", "ట", "డ", "త", "ద", "న", "ప", "బ", "మ", "య", "ర", "ల", "వ", "స", "హ", "ా", "ి", "ీ", "ు", "ూ", "ె", "ే", "ొ", "ో", "్"],
    ta: ["வணக்கம்", "தக்காளி", "வெங்காயம்", "தயாராக உள்ளது", "அ", "ஆ", "இ", "ஈ", "உ", "எ", "ஏ", "ஒ", "ஓ", "க", "ச", "ட", "த", "ந", "ப", "ம", "ய", "ர", "ல", "வ", "ழ", "ள", "ா", "ி", "ீ", "ு", "ூ", "ெ", "ே", "ொ", "ோ", "்"],
    ml: ["നമസ്കാരം", "തക്കാളി", "ഉള്ളി", "തയ്യാറാണ്", "അ", "ആ", "ഇ", "ഈ", "ഉ", "എ", "ഏ", "ഒ", "ഓ", "ക", "ഗ", "ച", "ജ", "ട", "ഡ", "ത", "ദ", "ന", "പ", "ബ", "മ", "യ", "ര", "ല", "വ", "സ", "ഹ", "ാ", "ി", "ീ", "ു", "ൂ", "െ", "േ", "ൊ", "ോ", "്"],
    en: ["Hello", "Ready for pickup", "On my way", "In stock", "Thank you"]
};

function toggleWebKeyboard() {
    const kb = document.getElementById("web-multilingual-keyboard");
    if (!kb) return;
    if (kb.style.display === "none") {
        kb.style.display = "block";
        renderWebKeyboard();
    } else {
        kb.style.display = "none";
    }
}

function renderWebKeyboard() {
    const kb = document.getElementById("web-multilingual-keyboard");
    if (!kb) return;
    const keys = WEB_KEYBOARD_KEYS[preferredLanguage] || WEB_KEYBOARD_KEYS.en;
    kb.innerHTML = `
        <div style="font-size:0.78rem; color:var(--primary); font-weight:bold; margin-bottom:0.5rem;">${preferredLanguage.toUpperCase()} Virtual Keyboard &amp; Quick Farm Phrases</div>
        <div style="display:flex; flex-wrap:wrap; gap:5px;">
            ${keys.map(k => `<button type="button" onclick="insertWebKey('${k}')" style="padding:5px 9px; border-radius:6px; border:1px solid var(--dark-border); background:var(--dark-bg); color:white; cursor:pointer; font-size:0.88rem;">${k}</button>`).join("")}
            <button type="button" onclick="insertWebKey(' ')" style="padding:5px 12px; border-radius:6px; border:1px solid var(--dark-border); background:var(--dark-bg); color:white; cursor:pointer; font-size:0.8rem;">Space</button>
            <button type="button" onclick="backspaceWebKey()" style="padding:5px 10px; border-radius:6px; border:1px solid #ef4444; background:rgba(239,68,68,0.15); color:#fca5a5; cursor:pointer; font-size:0.8rem;">&#9003;</button>
        </div>
    `;
}

function insertWebKey(val) {
    const input = document.getElementById("persona-chat-input");
    if (!input) return;
    input.value += val + (val.length > 1 ? " " : "");
    input.focus();
}

function backspaceWebKey() {
    const input = document.getElementById("persona-chat-input");
    if (!input) return;
    input.value = input.value.slice(0, -1);
    input.focus();
}

async function convertWebPhonetic() {
    const input = document.getElementById("persona-chat-input");
    const raw = (input?.value || "").trim();
    if (!raw || preferredLanguage === "en") return;
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/ai/transliterate`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ text: raw, target_language: preferredLanguage })
        });
        if (res.ok) {
            const data = await res.json();
            if (data.transliterated_text) input.value = data.transliterated_text;
        }
    } catch (e) {
        console.warn("Transliterate error:", e);
    }
}

async function translateCardText(btn, originalText) {
    const cardBody = btn.closest(".card-body");
    const titleEl = cardBody ? cardBody.querySelector(".listing-title") : null;
    if (!titleEl) return;
    titleEl.textContent = "Translating...";
    try {
        const res = await fetch(`${API_ML_URL}/api/v1/ai/translate`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ text: originalText, target_language: preferredLanguage })
        });
        if (res.ok) {
            const data = await res.json();
            titleEl.textContent = data.translated_text || originalText;
            return;
        }
    } catch (e) {
        console.warn("Translation note:", e);
    }
    titleEl.textContent = originalText;
}

const SPEECH_BCP47 = {
    en: "en-IN",
    kn: "kn-IN",
    hi: "hi-IN",
    te: "te-IN",
    ta: "ta-IN",
    ml: "ml-IN"
};

let activeTtsAudio = null;

function speakText(text, langCode = preferredLanguage) {
    const clean = (text || "").replace(/<[^>]*>/g, " ").replace(/[*_#`•🌾🧪🌿⚠️⏱️🛡️]/g, " ").replace(/\s+/g, " ").trim();
    if (!clean) return;
    if (activeTtsAudio) {
        activeTtsAudio.pause();
        activeTtsAudio = null;
    }
    if ("speechSynthesis" in window) {
        window.speechSynthesis.cancel();
    }
    const ttsUrl = `${API_ML_URL}/api/v1/ai/tts?text=${encodeURIComponent(clean)}&lang=${encodeURIComponent(langCode || "en")}`;
    const audio = new Audio(ttsUrl);
    activeTtsAudio = audio;
    audio.play().catch(() => {
        if (!("speechSynthesis" in window)) return;
        const utterance = new SpeechSynthesisUtterance(clean);
        utterance.lang = SPEECH_BCP47[langCode] || "en-IN";
        utterance.rate = 0.95;
        window.speechSynthesis.speak(utterance);
    });
}

function speakCardText(btn) {
    const cardBody = btn.closest(".card-body");
    const title = cardBody ? (cardBody.querySelector(".listing-title")?.textContent || "") : "";
    const seller = cardBody ? (cardBody.querySelector(".seller-info")?.textContent || "") : "";
    speakText(`${title}. ${seller}`, preferredLanguage);
}

document.addEventListener("DOMContentLoaded", () => {
    const langSel = document.getElementById("persona-lang-select");
    if (langSel) langSel.value = preferredLanguage;
    const farmerTab = document.getElementById('farmer-tab');
    if (farmerTab && farmerTab.classList.contains('active')) {
        initNlpDashboard();
    }
});
