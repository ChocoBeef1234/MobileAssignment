// job_images_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobImagesPage extends StatelessWidget {
  final String recordID; // this is the serviceRecordID
  const JobImagesPage({Key? key, required this.recordID}) : super(key: key);

  Uint8List _decodeBase64(String base64String) {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Images for $recordID'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('imageRecord')
            .where('recordID', isEqualTo: recordID)
            .orderBy('timestamp', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No images found for this record.'));
          }
          final docs = snapshot.data!.docs;
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final base64Image = data['image'] ?? '';
              final imgBytes = _decodeBase64(base64Image);
              return GestureDetector(
                onTap: () {
                  // full-screen viewer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullImagePage(
                        imageBytes: imgBytes,
                        recordID: recordID,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    imgBytes,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FullImagePage extends StatelessWidget {
  final Uint8List imageBytes;
  final String recordID;
  const FullImagePage({
    Key? key,
    required this.imageBytes,
    required this.recordID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(recordID),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
