import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_profile/photo.dart';

class JobStatusPage extends StatefulWidget {
  final String jobID;
  final String? serviceRecordID;
  const JobStatusPage({Key? key, required this.jobID, this.serviceRecordID})
    : super(key: key);

  @override
  State<JobStatusPage> createState() => _JobStatusPageState();
}

class _JobStatusPageState extends State<JobStatusPage> {
  String status = 'Waiting';
  final List<String> statusOptions = [
    'Waiting',
    'Accepted',
    'In Progress',
    'Completed',
    'Cancelled',
  ];
  final TextEditingController noteController = TextEditingController(
    text: 'Today...',
  );

  @override
  void initState() {
    super.initState();
    _loadInitialStatus();
  }

  Future<void> _loadInitialStatus() async {
    // Load current job status and note from Firestore
    final db = FirebaseFirestore.instance;
    final jobDoc = await db.collection('jobs').doc(widget.jobID).get();
    if (jobDoc.exists) {
      final job = jobDoc.data()!;
      setState(() {
        status = job['jobStatus'] ?? status;
      });
    }
    if (widget.serviceRecordID != null) {
      final svcDoc = await db
          .collection('serviceRecord')
          .doc(widget.serviceRecordID)
          .get();
      if (svcDoc.exists) {
        final svc = svcDoc.data()!;
        noteController.text = svc['technicianNotes'] ?? noteController.text;
      }
    }
  }

  Future<void> _saveStatus() async {
    final db = FirebaseFirestore.instance;
    // Update job status
    await db.collection('jobs').doc(widget.jobID).update({'jobStatus': status});

    // Get the highest serviceRecordID and increment
    final records = await db
        .collection('serviceRecord')
        .orderBy('serviceRecordID', descending: true)
        .limit(1)
        .get();
    int nextNumber = 1;
    if (records.docs.isNotEmpty) {
      final lastID = records.docs.first['serviceRecordID'] as String?;
      if (lastID != null && lastID.startsWith('SVCR')) {
        final numPart = int.tryParse(lastID.substring(4));
        if (numPart != null) {
          nextNumber = numPart + 1;
        }
      }
    }
    final newServiceRecordID = 'SVCR' + nextNumber.toString().padLeft(3, '0');

    // Fetch serviceID from job document
    String? serviceID;
    final jobDoc = await db.collection('jobs').doc(widget.jobID).get();
    if (jobDoc.exists) {
      final jobData = jobDoc.data();
      serviceID = jobData?['serviceID'] as String?;
    }

    await db.collection('serviceRecord').doc(newServiceRecordID).set({
      'serviceRecordID': newServiceRecordID,
      'jobID': widget.jobID,
      'technicianNotes': noteController.text,
      'serviceDate': FieldValue.serverTimestamp(),
      'serviceID': serviceID ?? '', // Use fetched serviceID or empty string
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Container(
          color: const Color(0xFFF9F9F9),
          padding: EdgeInsets.only(top: 8, left: 8, right: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 4),
              Text(
                'Job Status',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                  size: 22, 
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => CameraUploadPage(jobID: widget.jobID,),
                            )),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: status,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: statusOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      status = newValue!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Note',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      12,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(
                          Icons.circle_outlined,
                          size: 18,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    maxLines: 6,
                    minLines: 4,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    await _saveStatus();
                    if (mounted) Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
