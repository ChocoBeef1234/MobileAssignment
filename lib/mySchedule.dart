import 'package:flutter/material.dart';

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  _MySchedulePageState createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  int selectedTab = 0; // 0 = Today, 1 = Upcoming
  int currentIndex = 1; // bottom nav index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "My Schedule",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton("Today", 0),
                    _buildSegmentButton("Up Coming", 1),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildScheduleCard(
                      status: "Accepted",
                      statusColor: Colors.purple.shade200,
                      name: "Ms Lim Jia Jia",
                      vehicle: "Perodua Myvi - WXY 4567",
                      date: "Aug 30, 2025",
                    ),
                    const SizedBox(height: 12),
                    _buildScheduleCard(
                      status: "In Progress",
                      statusColor: Colors.orange.shade200,
                      name: "Ms Wong Ean Ean",
                      vehicle: "Perodua Myvi - ABC 1234",
                      date: "Aug 30, 2025",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
    );
  }

  // Segmented Button Widget
  Widget _buildSegmentButton(String text, int index) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Schedule Card Widget
  Widget _buildScheduleCard({
    required String status,
    required Color statusColor,
    required String name,
    required String vehicle,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Name & Vehicle
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  vehicle,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
        ],
      ),
    );
  }

  // Bottom Nav Icon Widget
  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? Colors.black : Colors.white54,
        ),
      ),
    );
  }
}
