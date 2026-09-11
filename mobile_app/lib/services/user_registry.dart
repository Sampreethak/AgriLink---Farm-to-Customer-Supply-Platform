class AppUserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'customer', 'farmer', 'aggregator', 'delivery', 'admin'
  final String customerType; // 'Individual Customer', 'Hostel / PG', 'Hospital', 'Corporate', 'Farmer (Producer)', 'Aggregator Hub', 'Delivery Partner'
  final String region;
  final String phone;
  final String avatarUrl;

  const AppUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.customerType,
    required this.region,
    required this.phone,
    this.avatarUrl = '',
  });
}

class UserRegistry {
  // Pre-configured recognized users from datasets (Supabase seed, benchmark users, and credentials)
  static final List<AppUserModel> users = [
    // -------------------------------------------------------------------------
    // 1. BUYERS / CUSTOMERS
    // -------------------------------------------------------------------------
    const AppUserModel(
      id: "99999999-9999-9999-9999-999999999999",
      email: "priya.buyer@agrilink.com",
      fullName: "Priya Verma",
      role: "customer",
      customerType: "Individual Customer",
      region: "Mumbai / Bengaluru Urban",
      phone: "+91 98111 22233",
    ),
    const AppUserModel(
      id: "66666666-6666-6666-6666-666666666666",
      email: "amit.buyer@agrilink.com",
      fullName: "Amit Roy",
      role: "customer",
      customerType: "Hostel / PG",
      region: "Pune / Kolar Central",
      phone: "+91 98111 22234",
    ),
    const AppUserModel(
      id: "77777777-7777-7777-7777-777777777777",
      email: "sneha.buyer@agrilink.com",
      fullName: "Sneha Kapoor",
      role: "customer",
      customerType: "Hospital",
      region: "Delhi NCR / Bengaluru Rural",
      phone: "+91 98111 22235",
    ),
    const AppUserModel(
      id: "88888888-8888-8888-8888-888888888888",
      email: "rajesh.buyer@agrilink.com",
      fullName: "Rajesh Joshi",
      role: "customer",
      customerType: "Corporate",
      region: "Ahmedabad / Chickballapur",
      phone: "+91 98111 22236",
    ),
    // Benchmark dataset sample customers
    const AppUserModel(
      id: "d48b9f71-c110-4f5f-83da-7b65dbfbc328",
      email: "cust1001@agrilink.com",
      fullName: "Ananya Deshmukh (CUST-1001)",
      role: "customer",
      customerType: "Individual Customer",
      region: "Malur Aggregator Hub",
      phone: "+91 98000 00001",
    ),
    const AppUserModel(
      id: "d48b9f71-c110-4f5f-83da-7b65dbfbc329",
      email: "cust1004@agrilink.com",
      fullName: "Fortis Care Hospital (CUST-1004)",
      role: "customer",
      customerType: "Hospital",
      region: "Bangalore Rural",
      phone: "+91 98000 00004",
    ),
    const AppUserModel(
      id: "d48b9f71-c110-4f5f-83da-7b65dbfbc330",
      email: "cust1005@agrilink.com",
      fullName: "St. John Hostel Mess (CUST-1005)",
      role: "customer",
      customerType: "Hostel / PG",
      region: "Kolar Central",
      phone: "+91 98000 00005",
    ),

    // -------------------------------------------------------------------------
    // 2. FARMERS / PRODUCERS
    // -------------------------------------------------------------------------
    const AppUserModel(
      id: "11111111-1111-1111-1111-111111111111",
      email: "ramesh.farmer@agrilink.com",
      fullName: "Ramesh Kumar",
      role: "farmer",
      customerType: "Farmer (Producer)",
      region: "Nashik / Mandya Corridor",
      phone: "+91 98765 43210",
    ),
    const AppUserModel(
      id: "22222222-2222-2222-2222-222222222222",
      email: "suresh.farmer@agrilink.com",
      fullName: "Suresh Patel",
      role: "farmer",
      customerType: "Farmer (Producer)",
      region: "Anand / Mandya Corridor",
      phone: "+91 98765 43211",
    ),
    const AppUserModel(
      id: "33333333-3333-3333-3333-333333333333",
      email: "anita.farmer@agrilink.com",
      fullName: "Anita Sharma",
      role: "farmer",
      customerType: "Farmer (Producer)",
      region: "Shimla Organic Farm",
      phone: "+91 98765 43212",
    ),
    const AppUserModel(
      id: "44444444-4444-4444-4444-444444444444",
      email: "vikram.farmer@agrilink.com",
      fullName: "Vikram Singh",
      role: "farmer",
      customerType: "Farmer (Producer)",
      region: "Ludhiana Farm Cluster",
      phone: "+91 98765 43213",
    ),
    const AppUserModel(
      id: "55555555-4444-3333-2222-111111111111",
      email: "farmer1@agrilink.com",
      fullName: "Farmer Guptha (Mandya)",
      role: "farmer",
      customerType: "Farmer (Producer)",
      region: "Mandya Agro Corridor",
      phone: "+91 98000 00071",
    ),

    // -------------------------------------------------------------------------
    // 3. AGGREGATORS / SHG HUBS
    // -------------------------------------------------------------------------
    const AppUserModel(
      id: "aaaa1111-bbbb-2222-cccc-333333333333",
      email: "aggregator.kolar@agrilink.com",
      fullName: "Kolar Market Yard Hub Manager",
      role: "aggregator",
      customerType: "Aggregator Hub",
      region: "Kolar Central Market Yard",
      phone: "+91 98000 00096",
    ),
    const AppUserModel(
      id: "aaaa2222-bbbb-2222-cccc-333333333333",
      email: "aggregator.mandya@agrilink.com",
      fullName: "Mandya SHG Aggregation Hub",
      role: "aggregator",
      customerType: "Aggregator Hub",
      region: "Mandya Agro Corridor Hub",
      phone: "+91 98000 00097",
    ),
    const AppUserModel(
      id: "aaaa3333-bbbb-2222-cccc-333333333333",
      email: "aggregator@agrilink.com",
      fullName: "Malur Aggregator Hub",
      role: "aggregator",
      customerType: "Aggregator Hub",
      region: "Malur Hub",
      phone: "+91 98000 00098",
    ),

    // -------------------------------------------------------------------------
    // 4. DELIVERY PARTNERS / LOGISTICS
    // -------------------------------------------------------------------------
    const AppUserModel(
      id: "dddd1111-eeee-2222-ffff-333333333333",
      email: "delivery.partner@agrilink.com",
      fullName: "Raju Delivery Partner (Express Cold Fleet)",
      role: "delivery",
      customerType: "Delivery Partner",
      region: "Mandya ➔ Bengaluru Highway Corridor",
      phone: "+91 98777 66655",
    ),
    const AppUserModel(
      id: "dddd2222-eeee-2222-ffff-333333333333",
      email: "delivery@agrilink.com",
      fullName: "Express Cold Logistics Rider",
      role: "delivery",
      customerType: "Delivery Partner",
      region: "Bengaluru Urban Express",
      phone: "+91 98777 66656",
    ),

    // -------------------------------------------------------------------------
    // 5. ADMIN / ANALYTICS
    // -------------------------------------------------------------------------
    const AppUserModel(
      id: "00000000-0000-0000-0000-000000000000",
      email: "admin@agrilink.com",
      fullName: "AgriLink System Administrator",
      role: "admin",
      customerType: "Admin",
      region: "Headquarters (Bengaluru)",
      phone: "+91 80000 12345",
    ),
  ];

  /// Find user by email, phone, or intelligent persona mapping
  static AppUserModel? findByEmail(String email) {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // 1. Direct exact email match
    for (final user in users) {
      if (user.email.toLowerCase() == clean) {
        return user;
      }
    }

    // 2. Direct exact phone match
    final cleanPhone = clean.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.length >= 8) {
      for (final user in users) {
        final uPhone = user.phone.replaceAll(RegExp(r'[^\d+]'), '');
        if (uPhone.endsWith(cleanPhone) || cleanPhone.endsWith(uPhone)) {
          return user;
        }
      }
    }

    // 3. Username / prefix alias matching (e.g. 'ramesh.farmer', 'priya.buyer', 'delivery.partner')
    for (final user in users) {
      final userPrefix = user.email.split('@').first.toLowerCase();
      if (userPrefix == clean || clean.startsWith(userPrefix)) {
        return user;
      }
    }

    // 4. Keyword-based role detection & persona creation for seamless testing with any email
    final nameTokens = clean.split('@').first.replaceAll(RegExp(r'[._\-]'), ' ')
        .split(' ')
        .where((s) => s.isNotEmpty && !['farmer', 'buyer', 'customer', 'delivery', 'aggregator', 'driver', 'admin', 'user'].contains(s.toLowerCase()))
        .map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : ''))
        .toList();

    final personalName = nameTokens.isNotEmpty 
        ? nameTokens.join(' ') 
        : (clean.split('@').first.isNotEmpty ? clean.split('@').first[0].toUpperCase() + clean.split('@').first.substring(1) : "AgriLink User");

    if (clean.contains('farmer') || clean.contains('kisan') || clean.contains('producer') || clean.contains('cultivator')) {
      return AppUserModel(
        id: "usr-farmer-${clean.hashCode.abs()}",
        email: clean.contains('@') ? clean : "$clean@agrilink.com",
        fullName: personalName == "Farmer" ? "Ramesh Kumar" : personalName,
        role: "farmer",
        customerType: "Farmer (Producer)",
        region: "Mandya & Nashik Farming Cluster",
        phone: "+91 98765 43210",
      );
    }

    if (clean.contains('aggregator') || clean.contains('aggr') || clean.contains('hub') || clean.contains('mandi') || clean.contains('shg') || clean.contains('yard')) {
      return AppUserModel(
        id: "usr-aggregator-${clean.hashCode.abs()}",
        email: clean.contains('@') ? clean : "$clean@agrilink.com",
        fullName: personalName == "Aggregator" ? "Kolar Market Yard Hub Manager" : "$personalName Hub Manager",
        role: "aggregator",
        customerType: "Aggregator Hub",
        region: "Kolar Central Market Yard & Aggregation Hub",
        phone: "+91 98000 00096",
      );
    }

    if (clean.contains('delivery') || clean.contains('driver') || clean.contains('rider') || clean.contains('fleet') || clean.contains('logistics') || clean.contains('transport')) {
      return AppUserModel(
        id: "usr-delivery-${clean.hashCode.abs()}",
        email: clean.contains('@') ? clean : "$clean@agrilink.com",
        fullName: personalName == "Delivery" ? "Raju Delivery Partner" : "$personalName Delivery Partner",
        role: "delivery",
        customerType: "Delivery Partner",
        region: "Mandya ➔ Bengaluru Highway Express",
        phone: "+91 98777 66655",
      );
    }

    if (clean.contains('admin') || clean.contains('root') || clean.contains('superuser') || clean.contains('manager')) {
      return AppUserModel(
        id: "usr-admin-${clean.hashCode.abs()}",
        email: clean.contains('@') ? clean : "$clean@agrilink.com",
        fullName: personalName == "Admin" ? "AgriLink System Administrator" : "$personalName (Admin)",
        role: "admin",
        customerType: "Admin",
        region: "AgriLink HQ (Bengaluru)",
        phone: "+91 80000 12345",
      );
    }

    if (clean.contains('hostel') || clean.contains('pg') || clean.contains('mess') || clean.contains('canteen')) {
      return AppUserModel(
        id: "usr-hostel-${clean.hashCode.abs()}",
        email: clean.contains('@') ? clean : "$clean@agrilink.com",
        fullName: personalName == "Hostel" ? "Amit Roy" : personalName,
        role: "customer",
        customerType: "Hostel / PG",
        region: "Pune / Bengaluru Student Mess Hub",
        phone: "+91 98111 22234",
      );
    }

    if (clean.contains('hospital') || clean.contains('clinic') || clean.contains('medical') || clean.contains('care')) {
      return AppUserModel(
        id: "usr-hospital-${clean.hashCode.abs()}",
        email: clean.contains('@') ? clean : "$clean@agrilink.com",
        fullName: personalName == "Hospital" ? "Sneha Kapoor" : personalName,
        role: "customer",
        customerType: "Hospital",
        region: "Bengaluru Healthcare Hub",
        phone: "+91 98111 22235",
      );
    }

    if (clean.contains('corporate') || clean.contains('store') || clean.contains('b2b') || clean.contains('hotel') || clean.contains('restaurant')) {
      return AppUserModel(
        id: "usr-corporate-${clean.hashCode.abs()}",
        email: clean.contains('@') ? clean : "$clean@agrilink.com",
        fullName: personalName == "Corporate" ? "Rajesh Joshi" : personalName,
        role: "customer",
        customerType: "Corporate",
        region: "Bengaluru Urban Tech Corridor",
        phone: "+91 98111 22236",
      );
    }

    // Default: Customer with their exact email and clean personal name
    return AppUserModel(
      id: "usr-cust-${clean.hashCode.abs()}",
      email: clean.contains('@') ? clean : "$clean@agrilink.com",
      fullName: personalName,
      role: "customer",
      customerType: "Individual Customer",
      region: "Bengaluru Urban",
      phone: "+91 98111 22233",
    );
  }

  /// Check if an email is registered or valid
  static bool isValidEmail(String email) {
    return email.trim().isNotEmpty;
  }

  /// Get list of sample test emails grouped by role for UI quick selection
  static Map<String, List<AppUserModel>> getUsersByRole() {
    final Map<String, List<AppUserModel>> map = {
      'Customer': [],
      'Farmer': [],
      'Aggregator': [],
      'Delivery': [],
      'Admin': [],
    };

    for (final u in users) {
      switch (u.role.toLowerCase()) {
        case 'customer':
          map['Customer']!.add(u);
          break;
        case 'farmer':
          map['Farmer']!.add(u);
          break;
        case 'aggregator':
          map['Aggregator']!.add(u);
          break;
        case 'delivery':
          map['Delivery']!.add(u);
          break;
        case 'admin':
          map['Admin']!.add(u);
          break;
      }
    }
    return map;
  }
}
