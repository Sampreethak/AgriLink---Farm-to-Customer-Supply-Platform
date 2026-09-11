import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/platform_state.dart';
import '../customer/fair_pricing_screen.dart';
import '../auth/role_selection_screen.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  final PlatformState _platformState = PlatformState();
  int _currentIndex = 0;
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    final user = _platformState.currentUser;

    final List<Widget> tabs = [
      JobBoardTab(isOnline: isOnline),
      const ActiveDeliveryTab(),
      const DeliveryEarningsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
              "${user.region} • 14% Value Share Partner",
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Dynamic Pricing Oracle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FairPricingScreen()),
              );
            },
          ),
          Row(
            children: [
              Text(
                isOnline ? "ON" : "OFF",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isOnline ? Colors.white : Colors.white70),
              ),
              Switch(
                value: isOnline,
                activeColor: Colors.white,
                activeTrackColor: Colors.green.shade900,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.black26,
                onChanged: (val) {
                  setState(() {
                    isOnline = val;
                  });
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 70,
        indicatorColor: Colors.green.shade100,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: "Job Board"),
          NavigationDestination(icon: Icon(Icons.navigation_outlined), selectedIcon: Icon(Icons.navigation), label: "Active Trip"),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: "Earnings"),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ----------------------------------------------------
// Tab 1: Job Board (Live Synced with Customer Orders)
// ----------------------------------------------------
class JobBoardTab extends StatefulWidget {
  final bool isOnline;
  const JobBoardTab({super.key, required this.isOnline});

  @override
  State<JobBoardTab> createState() => _JobBoardTabState();
}

class _JobBoardTabState extends State<JobBoardTab> {
  final PlatformState _platformState = PlatformState();

  @override
  void initState() {
    super.initState();
    _platformState.addListener(_onPlatformChange);
  }

  @override
  void dispose() {
    _platformState.removeListener(_onPlatformChange);
    super.dispose();
  }

  void _onPlatformChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 70, color: Colors.grey),
            SizedBox(height: 15),
            Text("You are Offline", style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text("Switch to ONLINE from top header to receive dispatch requests.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final liveJobs = _platformState.getDeliveryJobBoard();

    if (liveJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 12),
            Text("All delivery trips completed!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("New orders from customers will appear here automatically.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: liveJobs.length,
      itemBuilder: (context, index) {
        final job = liveJobs[index];
        final payout = job.deliveryPayout > 0 ? "₹${job.deliveryPayout.toStringAsFixed(0)}" : "₹250";
        final itemsSummary = "${job.items.length} Produce Item(s) (${job.items.map((i) => i.cropName).join(', ')})";
        final isAssigned = job.status == 'IN_TRANSIT';

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order #${job.orderId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        "14% Logistics Share: $payout",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _locationRow(Icons.radio_button_checked, "Pickup: Mandya Agro Hub / ${job.items.firstOrNull?.farmerName ?? 'Cluster Farm'}", Colors.orange),
                const SizedBox(height: 8),
                _locationRow(Icons.location_on, "Dropoff: ${job.customerName} (${job.deliveryAddress})", Colors.green),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.shopping_basket, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(itemsSummary, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (!isAssigned)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text("Accept Delivery Trip"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            _platformState.updateOrderStatus(job.orderId, 'IN_TRANSIT', driverName: _platformState.currentUser.fullName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.primaryGreen,
                                content: Text("Trip accepted! Order #${job.orderId} is now IN TRANSIT."),
                              ),
                            );
                          },
                        ),
                      )
                    else ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.done_all, size: 16),
                          label: const Text("Complete & Mark Delivered"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            _platformState.updateOrderStatus(job.orderId, 'DELIVERED');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("Order #${job.orderId} DELIVERED! Payment of $payout credited."),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _locationRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// Tab 2: Active Delivery Trip
// ----------------------------------------------------
class ActiveDeliveryTab extends StatelessWidget {
  const ActiveDeliveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlatformState();
    final inTransit = state.allOrders.where((o) => o.status == 'IN_TRANSIT').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Active Delivery Route", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Mandya ➔ Bengaluru Highway Cold Chain Highway Route (85 km).", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 15),

          // Map Simulation Box
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.local_shipping, size: 60, color: AppColors.primaryGreen),
                Positioned(
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      inTransit.isNotEmpty ? "En Route: Order #${inTransit.first.orderId}" : "No Active Trip In Transit",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (inTransit.isNotEmpty) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Trip Order #${inTransit.first.orderId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text("Customer: ${inTransit.first.customerName}"),
                    Text("Destination: ${inTransit.first.deliveryAddress}"),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                      onPressed: () {
                        state.updateOrderStatus(inTransit.first.orderId, 'DELIVERED');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Order marked DELIVERED!"), backgroundColor: AppColors.primaryGreen),
                        );
                      },
                      child: const Center(child: Text("Confirm Delivery & Handover")),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Tab 3: Delivery Earnings (14% Logistics Share)
// ----------------------------------------------------
class DeliveryEarningsTab extends StatelessWidget {
  const DeliveryEarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlatformState();
    final earnings = state.getDeliveryTotalEarnings();
    final completedTrips = state.allOrders.where((o) => o.status == 'DELIVERED').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Logistics Earnings & Escrow", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total 14% Logistics Payout", style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text("₹${earnings.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                const SizedBox(height: 8),
                Text("Settled for $completedTrips cold-corridor delivery trips.", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.analytics, color: Colors.green),
              title: const Text("APMC Dynamic Pricing Simulator"),
              subtitle: const Text("View logistics share calculation per km/kg"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FairPricingScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
