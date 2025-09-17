import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignedPartsBottomSheet extends StatefulWidget {
  final String? jobID;
  const AssignedPartsBottomSheet({Key? key, this.jobID}) : super(key: key);
  @override
  State<AssignedPartsBottomSheet> createState() =>
      _AssignedPartsBottomSheetState();
}

class _AssignedPartsBottomSheetState extends State<AssignedPartsBottomSheet> {
  String? _selectedPartID;
  int _quantity = 1;
  List<Map<String, dynamic>> _spareParts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpareParts();
  }

  Future<void> _fetchSpareParts() async {
    final db = FirebaseFirestore.instance;
    final snap = await db.collection('spareParts').get();
    setState(() {
      _spareParts = snap.docs.map((doc) => doc.data()).toList();
      _loading = false;
    });
  }

  Future<void> _addAssignedPart() async {
    if (_selectedPartID == null || widget.jobID == null) {
      print('Missing jobID or partID');
      return;
    }
    final db = FirebaseFirestore.instance;
    try {
      // Get the next jobPartID (JPxxx)
      final jobPartsSnap = await db.collection('jobParts').orderBy('jobPartID', descending: true).limit(1).get();
      int nextNumber = 1;
      if (jobPartsSnap.docs.isNotEmpty) {
        final lastID = jobPartsSnap.docs.first['jobPartID'] as String?;
        if (lastID != null && lastID.startsWith('JP')) {
          final numPart = int.tryParse(lastID.substring(2));
          if (numPart != null) {
            nextNumber = numPart + 1;
          }
        }
      }
      final newJobPartID = 'JP' + nextNumber.toString().padLeft(3, '0');
      print('Adding jobPart: jobID=${widget.jobID}, partID=$_selectedPartID, jobPartID=$newJobPartID, qty=$_quantity');
      await db.collection('jobParts').add({
        'jobPartID': newJobPartID,
        'jobID': widget.jobID,
        'partID': _selectedPartID,
        'quantityUsed': _quantity,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('jobPart added successfully');
    } catch (e) {
      print('Error adding jobPart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Parts',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            // ...existing code for displaying assigned parts...
            SizedBox(height: 18),
            Text(
              'Add Spare Part',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            _loading
                ? Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPartID,
                          hint: Text('Select Spare Part'),
                          items: _spareParts.map((part) {
                            return DropdownMenuItem<String>(
                              value: part['partID'],
                              child: Text(
                                '${part['partName']} (Part No: ${part['partID']})',
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPartID = val;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          initialValue: '1',
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Qty',
                          ),
                          onChanged: (val) {
                            final q = int.tryParse(val);
                            if (q != null && q > 0) {
                              _quantity = q;
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4ADE80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () async {
                          await _addAssignedPart();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
