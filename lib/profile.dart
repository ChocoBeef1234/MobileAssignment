import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_profile/edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // State variables
  String? fullName;
  String? phone;
  String? email;
  double rating = 0.0;
  int totalJobs = 0;
  double avgCompletionTime = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  String formatDuration(double seconds) {
    final int totalSeconds = seconds.round();
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int remainingSeconds = totalSeconds % 60;

    final String hStr = hours.toString().padLeft(2, '0');
    final String mStr = minutes.toString().padLeft(2, '0');
    final String sStr = remainingSeconds.toString().padLeft(2, '0');

    return '$hStr:$mStr:$sStr'; // hh:mm:ss format
  }

  Future<void> _loadStaffData() async {
    try {
      // 🔹 Get staffID from secure storage
      final staffID = await _secureStorage.read(key: 'staffID');
      if (staffID == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      // 🔹 Fetch staff info
      final staffSnap = await FirebaseFirestore.instance
          .collection('staff')
          .where('staffID', isEqualTo: staffID) // query by staffID field
          .limit(1)
          .get();

      if (staffSnap.docs.isNotEmpty) {
        final staffData = staffSnap.docs.first.data();
        fullName = staffData['staffName'] ?? '';
        phone = staffData['staffContactNo'] ?? '';
        email = staffData['staffEmail'] ?? '';
        rating = (staffData['rating'] ?? 0).toDouble();
      }

      // 🔹 Fetch jobs assigned to staff
      final assignmentsSnap = await FirebaseFirestore.instance
          .collection('jobAssignments')
          .where('staffID', isEqualTo: staffID)
          .get();

      int completedCount = 0;
      int totalTime = 0;

      for (var doc in assignmentsSnap.docs) {
        final jobID = doc['jobID'];
        final completionTime = doc['hoursWorked'];

        // Check job status
        final jobSnap = await FirebaseFirestore.instance
            .collection('jobs')
            .doc(jobID)
            .get();

        if (jobSnap.exists && jobSnap['jobStatus'] == 'Completed') {
          completedCount++;
          if (completionTime != null) {
            totalTime += (completionTime as num).toInt();
          }
        }
      }

      totalJobs = completedCount;
      avgCompletionTime = completedCount > 0 ? totalTime / completedCount : 0.0;

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    // Title
                    const Positioned(
                      top: 20,
                      left: 20,
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Edit Icon
                    Positioned(
                      top: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF2C2C2C),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Picture
              Transform.translate(
                offset: const Offset(0, -50),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Profile Information Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Full Name', fullName ?? ''),
                      const SizedBox(height: 15),
                      _buildInfoRow('Phone', phone ?? ''),
                      const SizedBox(height: 15),
                      _buildInfoRow('Email', email ?? ''),
                      const SizedBox(height: 15),
                      _buildInfoRow('Rating', rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Performance Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow('Total Job Completed', '$totalJobs'),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        'Average Completion Time',
                        formatDuration(avgCompletionTime),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ),
      ],
    );
  }
}
