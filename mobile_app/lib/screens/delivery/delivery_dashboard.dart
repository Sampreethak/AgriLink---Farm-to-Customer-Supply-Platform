import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../auth/role_selection_screen.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  int _currentIndex = 0;
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      JobBoardTab(isOnline: isOnline),
      const ActiveDeliveryTab(),
      const DeliveryEarningsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Partner Portal"),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          Row(
            children: [
              Text(
                isOnline ? "ONLINE" : "OFFLINE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isOnline ? Colors.white : Colors.white70),
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
// Tab 1: Job Board
// ----------------------------------------------------
class JobBoardTab extends StatefulWidget {
  final bool isOnline;
  const JobBoardTab({super.key, required this.isOnline});

  @override
  State<JobBoardTab> createState() => _JobBoardTabState();
}

class _JobBoardTabState extends State<JobBoardTab> {
  final List<Map<String, dynamic>> jobs = [
    {
      "id": "JOB-9921",
      "origin": "Aggregator Hub A (Kengeri)",
      "destination": "City General Hospital - Diet Wing",
      "payout": "₹450.00",
      "distance": "12.4 Km",
      "items": "3 Items (Bulk Tomatoes + Spinach + Rice)",
    },
    {
      "id": "JOB-9924",
      "origin": "Aggregator Hub B (Whitefield)",
      "destination": "Green Meadows PG Mess Office",
      "payout": "₹320.00",
      "distance": "8.1 Km",
      "items": "2 Items (Potatoes + Onions Bulk)",
    }
  ];

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
            Text("Go online from the top switch to receive orders.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
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
                    Text("Order ${job['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      job['payout'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18),
                    ),
                  ],
                ),
                const Divider(height: 25),
                _locationRow(Icons.radio_button_checked, "Pickup: ${job['origin']}", Colors.orange),
                const SizedBox(height: 8),
                _locationRow(Icons.location_on, "Dropoff: ${job['destination']}", Colors.green),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.shopping_basket, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(job['items'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const Spacer(),
                    const Icon(Icons.map, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(job['distance'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: () {
                          setState(() {
                            jobs.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Order request declined")),
                          );
                        },
                        child: const Text("Decline"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.primaryGreen,
                              content: Text("Trip accepted! Navigate to active trip tab."),
                            ),
                          );
                        },
                        child: const Text("Accept Trip"),
                      ),
                    ),
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
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

// ----------------------------------------------------
// Tab 2: Active Delivery
// ----------------------------------------------------
class ActiveDeliveryTab extends StatefulWidget {
  const ActiveDeliveryTab({super.key});

  @override
  State<ActiveDeliveryTab> createState() => _ActiveDeliveryTabState();
}

class _ActiveDeliveryTabState extends State<ActiveDeliveryTab> {
  int deliveryPhase = 0; // 0: Pickup pending, 1: Loaded/In-transit, 2: Arrived, 3: Completed
  final _otpController = TextEditingController();
  final List<Offset> signaturePoints = [];

  @override
  Widget build(BuildContext context) {
    if (deliveryPhase == 3) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 15),
            const Text("Delivery Complete", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Great job! Go back to Job Board to receive more orders.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  deliveryPhase = 0;
                });
              },
              child: const Text("Simulate New Job"),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Active Cargo Route", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: Colors.orange.withValues(alpha: 0.1),
                child: Text(
                  deliveryPhase == 0 ? "PICKUP PENDING" : "ON ROUTE",
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Map Mockup
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    "https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=600",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.map, size: 70, color: Colors.green));
                    },
                  ),
                ),
                Positioned(
                  left: 30,
                  top: 40,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 14,
                    child: Icon(Icons.radio_button_checked, color: Colors.orange.shade800, size: 16),
                  ),
                ),
                Positioned(
                  right: 40,
                  bottom: 30,
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 14,
                    child: Icon(Icons.location_on, color: Colors.green, size: 16),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    color: Colors.white,
                    child: Text(
                      deliveryPhase == 0 ? "Drive to Kengeri Aggregator Hub" : "En route to City General Hospital",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Step Details
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Trip Instructions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                  const SizedBox(height: 10),
                  Text(
                    deliveryPhase == 0
                        ? "1. Drive to Kengeri Aggregator Hub.\n2. Collect Crop Batch BATCH-QA-882.\n3. Verify Temperature constraints (3-5°C)."
                        : "1. Deliver produce batch to General Ward Kitchen.\n2. Verify identity and get Mess Warden's OTP + Signature verification.",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Render Actions based on Delivery Phase
          if (deliveryPhase == 0) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("Confirm Cargo Pickup at Hub"),
              onPressed: () {
                setState(() {
                  deliveryPhase = 1;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cargo verified & locked. Delivery path active.")),
                );
              },
            ),
          ] else if (deliveryPhase == 1) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.sports_motorsports),
              label: const Text("Arrived at Delivery Facility"),
              onPressed: () {
                setState(() {
                  deliveryPhase = 2;
                });
              },
            ),
          ] else ...[
            // Verification panel: Signature, OTP, and photo
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Consignee Clearance verification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                    const SizedBox(height: 15),

                    // OTP input
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter Customer Clearance OTP",
                        prefixIcon: Icon(Icons.key),
                        hintText: "OTP (Mock: 1234)",
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Signature capture pad mock
                    const Text("Client Signature", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            RenderBox renderBox = context.findRenderObject() as RenderBox;
                            signaturePoints.add(renderBox.globalToLocal(details.globalPosition));
                          });
                        },
                        child: CustomPaint(
                          painter: SignaturePainter(points: signaturePoints),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          signaturePoints.clear();
                        });
                      },
                      child: const Text("Clear Signature"),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
                      onPressed: () {
                        if (_otpController.text == "1234" || _otpController.text.isEmpty) {
                          setState(() {
                            deliveryPhase = 3;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.primaryGreen,
                              content: Text("Clearance OK. Delivery completed successfully!"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("Invalid verification OTP. Please enter 1234"),
                            ),
                          );
                        }
                      },
                      child: const Text("Submit Delivery Clearance"),
                    )
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

class SignaturePainter extends CustomPainter {
  final List<Offset> points;
  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue.shade900
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}

// ----------------------------------------------------
// Tab 3: Earnings
// ----------------------------------------------------
class DeliveryEarningsTab extends StatelessWidget {
  const DeliveryEarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Delivery Earnings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Review your payouts and commission history.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("Total Wallet Balance", style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  const Text("₹1,850.00", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cashout request of ₹1,850 sent to Bank Account")),
                      );
                    },
                    child: const Text("Instant Cashout to Bank"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text("Completed Deliveries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _completedTripCard("JOB-9811", "2026-06-22", "Kengeri to ICU Wing", "₹450.00"),
          _completedTripCard("JOB-9742", "2026-06-21", "Whitefield to PG Mess", "₹320.00"),
          _completedTripCard("JOB-9710", "2026-06-20", "Chikballapur to Mall of India", "₹1,080.00"),
        ],
      ),
    );
  }

  Widget _completedTripCard(String job, String date, String route, String amount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.check, color: Colors.green),
        ),
        title: Text("$job • $route"),
        subtitle: Text("Date: $date"),
        trailing: Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
        ),
      ),
    );
  }
}
