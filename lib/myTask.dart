import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_profile/notification.dart';
import 'package:user_profile/jobDetail.dart';

import 'package:intl/intl.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

final storage = const FlutterSecureStorage();
String? staffId;
String? staffImageBase64;
String? staffName;
String? staffContactNo;

class _MyTasksPageState extends State<MyTasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStaffId();
  }

  Future<void> _loadStaffId() async {
    staffId = await storage.read(key: "staffID");
    if (staffId != null) {
      // 🔹 Get staff image
      final staffSnap = await FirebaseFirestore.instance
          .collection('staff')
          .where('staffID', isEqualTo: staffId)
          .limit(1)
          .get();

      if (staffSnap.docs.isNotEmpty) {
        final data = staffSnap.docs.first.data();
        staffImageBase64 = data['profile_image'];
        final staffData = staffSnap.docs.first.data();
        staffName = staffData['staffName'] as String?;
        final staffPho = staffSnap.docs.first.data();
        staffContactNo = staffPho['staffContactNo'] as String?;
      }
    }
    setState(() {});
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "Time In: --:--";

    final dateTime = timestamp.toDate();
    final timeFormat = DateFormat('HH:mm');
    return "Time In: ${timeFormat.format(dateTime)}";
  }

  String _formatTimeOut(Timestamp? timestamp) {
    if (timestamp == null) return "Time Out: --:--";

    final dateTime = timestamp.toDate();
    final timeFormat = DateFormat('HH:mm');
    return "Time Out: ${timeFormat.format(dateTime)}";
  }

  Future<List<Widget>> generateTaskCards(
      String staffId, {
        String? filterStatus,
      }) async {
    final assignmentsSnap = await FirebaseFirestore.instance
        .collection('jobAssignments')
        .where('staffID', isEqualTo: staffId)
        .get();

    List<Widget> taskCards = [];

    for (var doc in assignmentsSnap.docs) {
      final jobId = doc['jobID'];
      final jobSnap = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .get();

      if (!jobSnap.exists) continue;

      final jobData = jobSnap.data()!;
      final status = jobData['jobStatus'];

      if (filterStatus != null && status != filterStatus) continue;

      Color statusColor;
      Color statusTextColor;

      switch (status) {
        case 'Accepted':
          statusColor = Color(0xFFD7C1F7);
          statusTextColor = Color(0xFF7B3FD5);
          break;
        case 'In Progress':
          statusColor = Color(0xFFFFE4B5);
          statusTextColor = Color(0xFFB87333);
          break;
        case 'Completed':
          statusColor = Color(0xFFD4F8E8);
          statusTextColor = Color(0xFF059669);
          break;
        default:
          statusColor = Colors.grey;
          statusTextColor = Colors.black;
      }

      // Fetch related collections (vehicles, customers)
      final vehicleSnap = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(jobData['vehicleID'])
          .get();
      final vehicleData = vehicleSnap.data()!;
      final customerSnap = await FirebaseFirestore.instance
          .collection('customers')
          .doc(vehicleData['custID'])
          .get();
      final customerName = customerSnap.data()?['custName'] ?? 'Unknown';

      // Convert timestamp to readable date
      final jobDate = (jobData['createdAt'] as Timestamp).toDate();
      final formattedDate = "${jobDate.day}/${jobDate.month}/${jobDate.year}";

      // Get car in and car out times
      final carInTime = jobData['carIn'] as Timestamp?;
      final carOutTime = jobData['carOut'] as Timestamp?;

      taskCards.add(
        TaskCard(
          jobID: jobId,
          status: status,
          statusColor: statusColor,
          statusTextColor: statusTextColor,
          name: customerName,
          car: "${vehicleData['model']} - ${vehicleData['plateNo']}",
          date: formattedDate,
          carInTime: carInTime,
          carOutTime: carOutTime,
        ),
      );
    }

    return taskCards;
  }

  Widget buildTaskList(String? filter) {
    return FutureBuilder<List<Widget>>(
      future: generateTaskCards(staffId!, filterStatus: filter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No tasks found"));
        }
        return ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 140),
          children: snapshot.data!,
        );
      },
    );
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
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            (staffImageBase64 != null &&
                                staffImageBase64!.isNotEmpty)
                            ? MemoryImage(base64Decode(staffImageBase64!))
                            : null,
                        child:
                            (staffImageBase64 == null ||
                                staffImageBase64!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),

                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, $staffName 👋",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Phone Number: $staffContactNo",
                            style: const TextStyle(color: Colors.grey),
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
                    child: staffId == null
                        ? Center(child: CircularProgressIndicator())
                        : TabBarView(
                      controller: _tabController,
                      children: [
                        // All Tasks
                        buildTaskList(null),

                        // Accepted Tasks
                        buildTaskList("Accepted"),

                        // In Progress Tasks
                        buildTaskList("In Progress"),

                        // On Hold Tasks
                        buildTaskList("On Hold"),
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
  final String jobID;
  final Color statusColor;
  final Color statusTextColor;
  final String name;
  final String car;
  final String date;
  final Timestamp? carInTime;
  final Timestamp? carOutTime;

  const TaskCard({
    super.key,
    required this.jobID,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.name,
    required this.car,
    required this.date,
    this.carInTime,
    this.carOutTime,
  });

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "--:--";

    final dateTime = timestamp.toDate();
    final timeFormat = DateFormat('HH:mm');
    return timeFormat.format(dateTime);
  }

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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Time In: ${_formatTime(carInTime)}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Time Out: ${_formatTime(carOutTime)}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetailsPage(jobID: jobID),
                          ),
                        );

                        (context.findAncestorStateOfType<_MyTasksPageState>())
                            ?.setState(() {});
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white,
                      ),
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