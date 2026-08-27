import 'package:flutter/material.dart';
import '../../core/colors.dart';

class ScheduledDeliveryScreen extends StatefulWidget {
  const ScheduledDeliveryScreen({super.key});

  @override
  State<ScheduledDeliveryScreen> createState() => _ScheduledDeliveryScreenState();
}

class _ScheduledDeliveryScreenState extends State<ScheduledDeliveryScreen> {
  String selectedSlot = "Morning Slot (06:00 AM - 08:00 AM)";
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

  final List<Map<String, String>> schedules = [
    {"date": "2026-06-23", "slot": "Morning Slot (06:00 AM - 08:00 AM)", "status": "Scheduled"},
    {"date": "2026-06-25", "slot": "Noon Slot (11:00 AM - 01:00 PM)", "status": "Scheduled"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Scheduling"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Strict Delivery Slots",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hospitals require fresh produce before kitchen prep shifts. Select exact time windows for delivery.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Book Delivery Slot",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading: const Icon(Icons.calendar_month, color: AppColors.primaryGreen),
                      title: const Text("Select Delivery Date"),
                      subtitle: Text("${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}"),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedSlot,
                      decoration: const InputDecoration(
                        labelText: "Available Time Slots",
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Morning Slot (06:00 AM - 08:00 AM)", child: Text("Early Morning (06-08 AM)")),
                        DropdownMenuItem(value: "Noon Slot (11:00 AM - 01:00 PM)", child: Text("Before Lunch (11 AM-01 PM)")),
                        DropdownMenuItem(value: "Evening Slot (04:00 PM - 06:00 PM)", child: Text("Evening Prep (04-06 PM)")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedSlot = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.schedule),
                      label: const Text("Confirm Delivery Slot"),
                      onPressed: () {
                        setState(() {
                          schedules.add({
                            "date": "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                            "slot": selectedSlot,
                            "status": "Scheduled",
                          });
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.primaryGreen,
                            content: Text("Delivery time slot scheduled successfully!"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Upcoming Scheduled Deliveries",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final sch = schedules[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.local_shipping),
                    ),
                    title: Text(sch['slot'] ?? ''),
                    subtitle: Text("Delivery Date: ${sch['date']}"),
                    trailing: Text(
                      sch['status'] ?? '',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
