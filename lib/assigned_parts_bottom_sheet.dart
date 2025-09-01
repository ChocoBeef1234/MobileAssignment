import 'package:flutter/material.dart';

class AssignedPartsBottomSheet extends StatefulWidget {
  @override
  State<AssignedPartsBottomSheet> createState() =>
      _AssignedPartsBottomSheetState();
}

class _AssignedPartsBottomSheetState extends State<AssignedPartsBottomSheet> {
  final TextEditingController _assetController = TextEditingController();

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
            ...[
              'Brake Pad Set (Part No: BP-458)',
              'Engine Oil (Part No: EO-001)',
              'Brake Pad Set (Part No: BP-458)',
              'Engine Oil (Part No: EO-001)',
              'Brake Pad Set (Part No: BP-458)',
              'Engine Oil (Part No: EO-001)',
              'Brake Pad Set (Part No: BP-458)',
              'Engine Oil (Part No: EO-001)',
            ].map(
              (part) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text('• $part', style: TextStyle(fontSize: 15)),
              ),
            ),
            SizedBox(height: 18),
            Text(
              'New Asset',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _assetController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'engine pad (Part No : BP1111)',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4ADE80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: () {
                    // Add asset logic here
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
