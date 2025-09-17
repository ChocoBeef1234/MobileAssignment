import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'jobStatus.dart';
import 'serviceHistory.dart';
import 'assigned_parts_bottom_sheet.dart';

import 'firebase.dart';

class JobDetailsPage extends StatefulWidget {
  const JobDetailsPage({super.key, this.jobID = ''});
  final String jobID;

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late Future<Map<String, dynamic>> _jobDetailsFuture;

  @override
  void initState() {
    super.initState();
    _jobDetailsFuture = _fetchJobDetails(widget.jobID);
  }

  void _refreshJobDetails() {
    setState(() {
      _jobDetailsFuture = _fetchJobDetails(widget.jobID);
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
                'Job Details',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.history, color: Colors.black, size: 26),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceHistoryPage(jobID: widget.jobID),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _jobDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No job found.'));
          }
          final data = snapshot.data!;
          final customer = data['customer'] as Map<String, dynamic>?;
          final vehicle = data['vehicle'] as Map<String, dynamic>?;
          final job = data['job'] as Map<String, dynamic>?;
          final parts = data['parts'] as List<Map<String, dynamic>>?;

          return Container(
            color: const Color(0xFFF9F9F9),
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 18.0,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Color(0xFFDDDDDD)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                    'assets/avatar.png',
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer?['custName'] ?? '-',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Phone: ${customer?['custContactNo'] ?? '-'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phone',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        customer?['custContactNo'] ?? '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        'Car Plate',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        vehicle?['plateNo'] ?? '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        'VIN',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        vehicle?['vinNo'] ?? '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 24),
                                // Right column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        _formatDate(job?['jobDate']),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      Text(
                                        'Vehicle',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        vehicle != null
                                            ? '${vehicle['model']}, ${vehicle['year']}'
                                            : '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Text(
                                            'Job Status',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE6D6FA),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              job?['jobStatus'] ?? '-',
                                              style: TextStyle(
                                                color: Color(0xFF7C3AED),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Job Description',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              data['serviceDescription'] ?? '-',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'Assigned Parts',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Spacer(),
                                InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return AssignedPartsBottomSheet();
                                      },
                                    );
                                  },
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 28,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            if (parts != null)
                              ...parts.map(
                                (part) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                  ),
                                  child: Text(
                                    '• ${part['partName']} (Part No: ${part['partID']})',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                JobStatusPage(jobID: widget.jobID),
                          ),
                        );
                        if (result == true) {
                          _refreshJobDetails();
                        }
                      },
                      child: Text(
                        'Edit Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE6D6FA),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Removed duplicate trailing code after refactor

  Future<Map<String, dynamic>> _fetchJobDetails(String jobID) async {
    final db = FirebaseFirestore.instance;
    // Get job
    final jobDoc = await db.collection('jobs').doc(jobID).get();
    if (!jobDoc.exists) return {};
    final job = jobDoc.data()!;
    // Get vehicle
    final vehicleDoc = await db
        .collection('vehicles')
        .doc(job['vehicleID'])
        .get();
    final vehicle = vehicleDoc.data();
    // Get customer
    Map<String, dynamic>? customer;
    if (vehicle != null) {
      final custDoc = await db
          .collection('customers')
          .doc(vehicle['custID'])
          .get();
      customer = custDoc.data();
    }
    // Get assigned parts (join jobParts and spareParts)
    final jobPartsSnap = await db
        .collection('jobParts')
        .where('jobID', isEqualTo: jobID)
        .get();
    final List<Map<String, dynamic>> parts = [];
    for (final jp in jobPartsSnap.docs) {
      final jpData = jp.data();
      final partDoc = await db
          .collection('spareParts')
          .doc(jpData['partID'])
          .get();
      if (partDoc.exists) {
        final partData = partDoc.data()!;
        parts.add({
          'partID': partData['partID'],
          'partName': partData['partName'],
        });
      }
    }
    // Get service description from services collection using job['serviceID']
    String? serviceDescription;
    if (job['serviceID'] != null) {
      print('Job serviceID: \'${job['serviceID']}\'');
      final serviceDoc = await db
          .collection('services')
          .doc(job['serviceID'])
          .get();
      if (serviceDoc.exists) {
        final serviceData = serviceDoc.data();
        serviceDescription = serviceData?['serviceDescription'] ?? '';
        print('Fetched serviceDescription: \'$serviceDescription\'');
      } else {
        print(
          'No service document found for serviceID: \'${job['serviceID']}\'',
        );
      }
    } else {
      print('No serviceID found in job document');
    }
    return {
      'job': job,
      'vehicle': vehicle,
      'customer': customer,
      'parts': parts,
      'serviceDescription': serviceDescription,
    };
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    return '-';
  }
}
