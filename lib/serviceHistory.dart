import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_profile/showImage.dart';

class ServiceHistoryPage extends StatelessWidget {
  final String jobID;
  const ServiceHistoryPage({super.key, required this.jobID});

  Future<Map<String, String>> _fetchServiceDescriptions() async {
    final snap = await FirebaseFirestore.instance.collection('services').get();
    final map = <String, String>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      map[data['serviceID']] =
          data['serviceDescription'] ??
          data['serviceName'] ??
          data['serviceID'];
    }
    return map;
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
                'History',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, size: 24, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Service History',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Time',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Service',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<Map<String, String>>(
                  future: _fetchServiceDescriptions(),
                  builder: (context, serviceSnap) {
                    if (serviceSnap.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!serviceSnap.hasData) {
                      return Center(child: Text('No service info found.'));
                    }
                    final serviceMap = serviceSnap.data!;
                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('serviceRecord')
                          .where('jobID', isEqualTo: jobID)
                          .orderBy('serviceDate', descending: true)
                          .get()
                          .catchError((e) async {
                            // If orderBy fails (e.g., missing or non-orderable field), try without ordering
                            print(
                              '[DEBUG] orderBy serviceDate failed: ' +
                                  e.toString(),
                            );
                            return await FirebaseFirestore.instance
                                .collection('serviceRecord')
                                .where('jobID', isEqualTo: jobID)
                                .get();
                          }),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No service history found. Make sure serviceRecord has jobID and serviceDate fields.',
                            ),
                          );
                        }
                        // Always sort records by serviceDate descending
                        final records = List<Map<String, dynamic>>.from(
                          snapshot.data!.docs.map(
                            (doc) => doc.data() as Map<String, dynamic>,
                          ),
                        );
                        records.sort((a, b) {
                          final aDate = a['serviceDate'];
                          final bDate = b['serviceDate'];
                          if (aDate is Timestamp && bDate is Timestamp) {
                            return bDate.compareTo(aDate);
                          }
                          return 0;
                        });
                        return ListView.separated(
                          itemCount: records.length,
                          separatorBuilder: (context, idx) =>
                              SizedBox(height: 16),
                          itemBuilder: (context, idx) {
                            final record = records[idx];
                            final date = _formatDate(record['serviceDate']);
                            final serviceID = record['serviceID'] ?? '-';
                            final serviceDesc =
                                serviceMap[serviceID] ?? serviceID;
                            final notes =
                                (record['technicianNotes'] != null &&
                                    record['technicianNotes']
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                ? record['technicianNotes']
                                : '-';
                            final status = record['status'] ?? '-';
                            final recordID =
                                record['serviceRecordID'] ??
                                ''; // your linking ID

                            return GestureDetector(
                              onTap: () {
                                if (recordID.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          JobImagesPage(recordID: recordID),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        date,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFB6FFB6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            serviceDesc,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Status: $status',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Technician Notes:',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            notes,
                                            style: TextStyle(fontSize: 13),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Tap to view images',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final dt = value.toDate();
      return '${_monthName(dt.month)} ${dt.day},\n${dt.year}';
    } else if (value is String) {
      // Try to parse string as date
      try {
        final dt = DateTime.parse(value);
        return '${_monthName(dt.month)} ${dt.day},\n${dt.year}';
      } catch (_) {
        return value;
      }
    }
    return '-';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}

class QuerySnapshotFake implements QuerySnapshot {
  @override
  final List<QueryDocumentSnapshot> docs;
  QuerySnapshotFake(this.docs);
  // The rest of the QuerySnapshot interface can throw UnimplementedError
  @override
  // ignore: no_leading_underscores_for_local_identifiers
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
