import 'package:flutter/material.dart';
import 'package:user_profile/notification.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          // Main content with SafeArea
          SafeArea(
            bottom: false, // allow content under nav bar
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Profile Section
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Hi, Fahmi 👋",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Today is: July 17, 2025",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "My Tasks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    indicator: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 4,
                    ),
                    tabs: const [
                      Tab(text: "All task"),
                      Tab(text: "Accepted"),
                      Tab(text: "In Progress"),
                      Tab(text: "On Hold"),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Task list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 140, // give more space for floating nav bar
                      ),
                      children: const [
                        TaskCard(
                          status: "Accepted",
                          statusColor: Color(0xFFD7C1F7),
                          statusTextColor: Color(0xFF7B3FD5),
                          name: "Ms Lim Jia Jia",
                          car: "Perodua Myvi - WXY 4567",
                          date: "Aug 30, 2025",
                        ),
                        TaskCard(
                          status: "Accepted",
                          statusColor: Color(0xFFD7C1F7),
                          statusTextColor: Color(0xFF7B3FD5),
                          name: "Ms Lim Jia Jia",
                          car: "Perodua Myvi - WXY 4567",
                          date: "Aug 30, 2025",
                        ),
                        TaskCard(
                          status: "In Progress",
                          statusColor: Color(0xFFFFE4B5),
                          statusTextColor: Color(0xFFB87333),
                          name: "Ms Wong Ean Ean",
                          car: "Perodua Myvi - ABC 1234",
                          date: "Aug 30, 2025",
                        ),
                        TaskCard(
                          status: "In Progress",
                          statusColor: Color(0xFFFFE4B5),
                          statusTextColor: Color(0xFFB87333),
                          name: "Ms Wong Ean Ean",
                          car: "Perodua Myvi - ABC 1234",
                          date: "Aug 30, 2025",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final String name;
  final String car;
  final String date;

  const TaskCard({
    super.key,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.name,
    required this.car,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(car, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(date, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
