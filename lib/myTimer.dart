import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final storage = const FlutterSecureStorage();

  bool _isRunning = false;
  String? _selectedTaskId;
  Timer? _timer;

  final ValueNotifier<int> _timerValue = ValueNotifier<int>(0);

  Future<String> _loadStaffId() async {
    return await storage.read(key: "staffID") ?? '';
  }

  Future<List<Map<String, dynamic>>> fetchAcceptedTasks() async {
    final staffId = await _loadStaffId();
    if (staffId.isEmpty) return [];

    final assignmentsSnap = await FirebaseFirestore.instance
        .collection('jobAssignments')
        .where('staffID', isEqualTo: staffId)
        .get();

    if (assignmentsSnap.docs.isEmpty) return [];

    final futures = assignmentsSnap.docs.map((assignDoc) async {
      final assignData = assignDoc.data();
      final workHours = assignData['hoursWorked'] ?? 0;
      final jobId = assignData['jobID'];

      final jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .get();
      if (!jobDoc.exists) return null;
      final jobData = jobDoc.data()!;
      if (jobData['jobStatus'] != 'Accepted'&& jobData['jobStatus'] != 'In Progress') return null;

      final vehicleId = jobData['vehicleID'];
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .get();
      if (!vehicleDoc.exists) return null;
      final vehicleData = vehicleDoc.data()!;
      final vehicleModel = vehicleData['model'];
      final vehiclePlate = vehicleData['plateNo'];
      final custId = vehicleData['custID'];

      final custDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(custId)
          .get();
      if (!custDoc.exists) return null;
      final custName = custDoc.data()!['custName'];

      return {
        'id': assignDoc.id,
        'custName': custName,
        'vehicleModel': vehicleModel,
        'vehiclePlate': vehiclePlate,
        'timeWorked': workHours,
      };
    });

    final results = await Future.wait(futures);
    return results.whereType<Map<String, dynamic>>().toList();
  }

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

 void _startTimer() {
  if (_isRunning) return;
  _isRunning = true;

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    _timerValue.value++;
  });
}

void _pauseTimer() {
  _timer?.cancel();
  _isRunning = false;
}

  Future<void> _stopTimerAndSave() async {
  _pauseTimer();

  if (_selectedTaskId != null) {
    await FirebaseFirestore.instance
        .collection('jobAssignments')
        .doc(_selectedTaskId)
        .update({'hoursWorked': _timerValue.value});
  }

  setState(() {});
}

  void _onTaskTap(Map<String, dynamic> task) {
    setState(() {
      _selectedTaskId = task['id'];
      _timerValue.value = (task['timeWorked'] ?? 0).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Timer",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Timer using ValueListenableBuilder
              ValueListenableBuilder<int>(
                valueListenable: _timerValue,
                builder: (context, value, _) {
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          formatDuration(value),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _startTimer,
                              child: const Text("Start"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _pauseTimer,
                              child: const Text("Pause"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _stopTimerAndSave,
                              child: const Text("Stop & Save"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              const Text("Today",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchAcceptedTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No accepted tasks"));
                    }

                    final tasks = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 140),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final bool isSelected = task['id'] == _selectedTaskId;
                        final String title = task['custName'] ?? 'No Name';
                        final String subtitle = "${task['vehicleModel'] ?? ''} - ${task['vehiclePlate'] ?? ''}";
                        final String timeText = formatDuration((task['timeWorked'] ?? 0).toInt());

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey.shade300,
                              width: isSelected ? 1.2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _onTaskTap(task),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.build, color: Colors.black87),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitle,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.black : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        timeText,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
