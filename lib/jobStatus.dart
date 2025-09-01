import 'package:flutter/material.dart';

class JobStatusPage extends StatefulWidget {
  const JobStatusPage({super.key});

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
                onPressed: () {},
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
                Icon(Icons.image_outlined, color: Colors.black54, size: 20),
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
                  onPressed: () {},
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
