# 📱 AgriLink — Flutter Mobile App

The customer-facing, farmer-facing, admin, aggregator, and delivery agent dashboards built with Flutter.

## Structure

```
lib/
├── core/           → Config, constants, theme
├── models/         → Data models (Product, Order, Cart, etc.)
├── providers/      → State management providers
├── screens/
│   ├── auth/       → Login, registration screens
│   ├── customer/   → Buyer: Home, Cart, Orders, Profile
│   ├── farmer/     → Seller: Products, Orders, Earnings
│   ├── admin/      → Admin panel
│   ├── aggregator/ → Aggregator dashboard
│   └── delivery/   → Delivery agent screens
├── services/       → Supabase, auth, order, payment services
├── utils/          → Helpers and formatters
└── widgets/        → Reusable UI components
```

## Setup

```bash
flutter pub get
flutter run -d web-server --web-port 8080 --web-hostname 127.0.0.1
```

## Key Features
- 🛒 Real-time cart synced across tabs
- 📦 Order placement with Razorpay / COD
- 🌾 Farmer listing management
- 🤖 ML-powered product recommendations
- 🔔 Notifications system
