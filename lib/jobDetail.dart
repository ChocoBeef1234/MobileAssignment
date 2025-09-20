import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'jobStatus.dart';
import 'serviceHistory.dart';
import 'assigned_parts_bottom_sheet.dart';
import 'signature.dart';
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
          final signatureData = data['signature'] as String?;
          final feedbackData = data['feedback'] as String?;
          final completionTime = data['completionTime'] as double?;

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
                                        _formatDate(job?['createdAt']),
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
                                      Wrap(
                                        spacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
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
                                      if (job?['statusChange'] != null) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          'Status Changed: ' +
                                              _formatDate(job?['statusChange']),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
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
                                  onTap:
                                      (job?['jobStatus']
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'waiting' ||
                                          job?['jobStatus']
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'completed' ||
                                          job?['jobStatus']
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'cancelled')
                                      ? null
                                      : () async {
                                          final result =
                                              await showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (context) {
                                                  return AssignedPartsBottomSheet(
                                                    jobID: widget.jobID,
                                                  );
                                                },
                                              );
                                          if (result == true) {
                                            _refreshJobDetails();
                                          }
                                        },
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 28,
                                    color:
                                        (job?['jobStatus']
                                                    ?.toString()
                                                    .toLowerCase() ==
                                                'waiting' ||
                                            job?['jobStatus']
                                                    ?.toString()
                                                    .toLowerCase() ==
                                                'completed' ||
                                            job?['jobStatus']
                                                    ?.toString()
                                                    .toLowerCase() ==
                                                'cancelled')
                                        ? Colors.grey[300]
                                        : Colors.grey[400],
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

                            // Completion Time Section (only show when job is completed)
                            if (job?['jobStatus']?.toString().toLowerCase() == 'completed' && completionTime != null) ...[
                              SizedBox(height: 16),
                              Text(
                                'Completion Time',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                _formatDuration(completionTime),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ],

                            // Signature and Feedback Section
                            if (job?['jobStatus']?.toString().toLowerCase() ==
                                'completed') ...[
                              SizedBox(height: 24),
                              Row(
                                children: [
                                  Text(
                                    'Signature and Feedback',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Spacer(),
                                  if (signatureData == null &&
                                      feedbackData == null)
                                    InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () async {
                                        final result =
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SignatureFeedbackPage(
                                                      jobID: widget.jobID,
                                                    ),
                                              ),
                                            );
                                        if (result == true) {
                                          _refreshJobDetails();
                                        }
                                      },
                                      child: Icon(
                                        Icons.edit_rounded,
                                        size: 28,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Signature Display
                              if (signatureData != null) ...[
                                Text(
                                  'Signature',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _base64ToUint8List(signatureData),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],

                              // Feedback Display
                              if (feedbackData != null) ...[
                                Text(
                                  'Feedback',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[50],
                                  ),
                                  child: Text(
                                    feedbackData,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],

                              if (signatureData == null && feedbackData == null)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[50],
                                  ),
                                  child: Text(
                                    'No signature or feedback provided yet.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
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
                        backgroundColor:
                            job?['jobStatus']?.toString().toLowerCase() ==
                                'completed'
                            ? Colors.grey[400] // Disabled color
                            : Colors.black, // Active color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed:
                          (job?['jobStatus']?.toString().toLowerCase() ==
                                  'completed' ||
                              job?['jobStatus']?.toString().toLowerCase() ==
                                  'cancelled')
                          ? null // Disable button when completed or cancelled
                          : () async {
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
                        job?['jobStatus']?.toString().toLowerCase() ==
                                'completed'
                            ? 'Status Completed'
                            : job?['jobStatus']?.toString().toLowerCase() ==
                                  'cancelled'
                            ? 'Status Cancelled'
                            : 'Edit Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              (job?['jobStatus']?.toString().toLowerCase() ==
                                      'completed' ||
                                  job?['jobStatus']?.toString().toLowerCase() ==
                                      'cancelled')
                              ? Colors.grey[600] // Disabled text color
                              : Color(0xFFE6D6FA), // Active text color
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

  Future<Map<String, dynamic>> _fetchJobDetails(String jobID) async {
    final db = FirebaseFirestore.instance;
    final jobDoc = await db.collection('jobs').doc(jobID).get();
    if (!jobDoc.exists) return {};
    final job = jobDoc.data()!;

    final vehicleDoc = await db
        .collection('vehicles')
        .doc(job['vehicleID'])
        .get();
    final vehicle = vehicleDoc.data();

    Map<String, dynamic>? customer;
    if (vehicle != null) {
      final custDoc = await db
          .collection('customers')
          .doc(vehicle['custID'])
          .get();
      customer = custDoc.data();
    }

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

    String? signature = job['signature'];
    String? feedback = job['feedback'];

    // Fetch completion time from jobAssignments
    double? completionTime;
    final jobAssignmentsSnap = await db
        .collection('jobAssignments')
        .where('jobID', isEqualTo: jobID)
        .get();
    
    if (jobAssignmentsSnap.docs.isNotEmpty) {
      final assignmentData = jobAssignmentsSnap.docs.first.data();
      completionTime = (assignmentData['hoursWorked'] as num?)?.toDouble();
    }

    return {
      'job': job,
      'vehicle': vehicle,
      'customer': customer,
      'parts': parts,
      'serviceDescription': serviceDescription,
      'signature': signature,
      'feedback': feedback,
      'completionTime': completionTime,
    };
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    return '-';
  }

  String _formatDuration(double seconds) {
    // The input is already in seconds, no conversion needed
    final int totalSeconds = seconds.round();
    
    // Calculate hours, minutes, and seconds
    final int h = totalSeconds ~/ 3600;
    final int m = (totalSeconds % 3600) ~/ 60;
    final int s = totalSeconds % 60;

    final String hStr = h.toString().padLeft(2, '0');
    final String mStr = m.toString().padLeft(2, '0');
    final String sStr = s.toString().padLeft(2, '0');

    return '$hStr:$mStr:$sStr'; // hh:mm:ss format
  }

  Uint8List _base64ToUint8List(String base64String) {
    try {
      return const Base64Decoder().convert(base64String);
    } catch (e) {
      print('Error decoding base64: $e');
      return Uint8List(0);
    }
  }
}
