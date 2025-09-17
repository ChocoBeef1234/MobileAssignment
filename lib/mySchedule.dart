import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JobDetail {
  final String jobId;
  final String status;
  final DateTime date;
  final String carModel;
  final String plateNo;
  final String customerName;

  JobDetail({
    required this.jobId,
    required this.status,
    required this.date,
    required this.carModel,
    required this.plateNo,
    required this.customerName,
  });
}

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  final storage = const FlutterSecureStorage();
  List<JobDetail> jobs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final staffId = await storage.read(key: 'staffID');
      if (staffId == null) {
        setState(() => loading = false);
        return;
      }

      final jobAssignSnap = await FirebaseFirestore.instance
          .collection('jobAssignments')
          .where('staffID', isEqualTo: staffId)
          .get();

      List<JobDetail> jobDetails = [];

      for (var doc in jobAssignSnap.docs) {
        final jobID = doc['jobID'] as String;

        // jobs collection
        final jobSnap =
            await FirebaseFirestore.instance.collection('jobs').doc(jobID).get();
        if (!jobSnap.exists) continue;

        final jobData = jobSnap.data()!;
        final status = jobData['jobStatus'] ?? '';
        final vehicleID = jobData['vehicleID'] ?? '';
        DateTime date = DateTime.now();
        if (jobData['createdAt'] is Timestamp) {
          date = (jobData['createdAt'] as Timestamp).toDate();
        }

        // vehicles collection
        final vehicleSnap = await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(vehicleID)
            .get();
        if (!vehicleSnap.exists) continue;
        final vehicleData = vehicleSnap.data()!;
        final model = vehicleData['model'] ?? '';
        final plateNo = vehicleData['plateNo'] ?? '';
        final custID = vehicleData['custID'] ?? '';

        // customers collection
        final custSnap = await FirebaseFirestore.instance
            .collection('customers')
            .doc(custID)
            .get();
        String custName = '';
        if (custSnap.exists) {
          custName = custSnap['custName'] ?? '';
        }

        jobDetails.add(JobDetail(
          jobId: jobID,
          status: status,
          date: date,
          carModel: model,
          plateNo: plateNo,
          customerName: custName,
        ));
      }

      setState(() {
        jobs = jobDetails;
        loading = false;
      });
    } catch (e) {
      debugPrint('Error loading jobs: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // filter today/upcoming
    final now = DateTime.now();
    final todayJobs = jobs.where((j) =>
        j.date.year == now.year &&
        j.date.month == now.month &&
        j.date.day == now.day).toList();

    final upcomingJobs = jobs.where((j) => j.date.isAfter(
        DateTime(now.year, now.month, now.day, 23, 59, 59))).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Schedule"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Today"),
              Tab(text: "Upcoming"),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildJobList(todayJobs, 'No jobs for today'),
                  _buildJobList(upcomingJobs, 'No upcoming jobs'),
                ],
              ),
      ),
    );
  }

  Widget _buildJobList(List<JobDetail> list, String emptyMsg) {
    if (list.isEmpty) {
      return Center(child: Text(emptyMsg));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildJobCard(list[index]),
    );
  }

  Widget _buildJobCard(JobDetail job) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(job.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.status,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                Text(job.customerName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${job.carModel} - ${job.plateNo}",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM dd, yyyy').format(job.date),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.purple.shade200;
      case 'In Progress':
        return Colors.orange.shade200;
      case 'completed':
        return Colors.green.shade200;
      default:
        return Colors.grey.shade300;
    }
  }
}
