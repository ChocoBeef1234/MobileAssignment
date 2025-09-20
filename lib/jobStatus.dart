import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController noteController =
      TextEditingController(text: 'Today...');

  List<XFile> selectedImages = []; // local images selected or taken

  @override
  void initState() {
    super.initState();
    _loadInitialStatus();
  }

  Future<void> _loadInitialStatus() async {
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

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (!mounted) return;
    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (!mounted) return;
    if (photo != null) {
      setState(() {
        selectedImages.add(photo);
      });
    }
  }

  Future<void> _saveStatus() async {
    final db = FirebaseFirestore.instance;
    // Update job status and statusChange timestamp
    await db.collection('jobs').doc(widget.jobID).update({
      'jobStatus': status,
      'statusChange': FieldValue.serverTimestamp(),
    });

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

    // Save service record
    await db.collection('serviceRecord').doc(newServiceRecordID).set({
      'serviceRecordID': newServiceRecordID,
      'jobID': widget.jobID,
      'technicianNotes': noteController.text,
      'serviceDate': FieldValue.serverTimestamp(),
      'serviceID': serviceID ?? '',
      'status': status,
    });

    // Save images to imageRecord collection
    for (final image in selectedImages) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final newImageDoc = db.collection('imageRecord').doc();
      await newImageDoc.set({
        'imageID': newImageDoc.id,
        'recordID': newServiceRecordID, // link to the service record
        'jobID': widget.jobID,
        'image': base64Image,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  List<String> getValidStatusOptions(String currentStatus) {
    switch (currentStatus) {
      case 'Accepted':
        return ['Accepted', 'In Progress', 'Completed', 'Cancelled'];
      case 'In Progress':
        return ['In Progress', 'Completed', 'Cancelled'];
      case 'Completed':
      case 'Cancelled':
        return [currentStatus];
      default:
        return statusOptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Job Status'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImages,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _takePhoto,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE0E0E0)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: status,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: getValidStatusOptions(status).map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        status = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Note',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
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
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: noteController,
                maxLines: 6,
                minLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 16),
            Text('Selected Images',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          // ignore: unnecessary_cast
                          (selectedImages[index] as XFile).path != null
                              ? File(selectedImages[index].path)
                              : File(''),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImages.removeAt(index);
                            });
                          },
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _saveStatus,
                child: const Text(
                  'Save',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
