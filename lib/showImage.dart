import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';

class JobImagesPage extends StatelessWidget {
  final String jobID; // Pass jobID to filter images
  const JobImagesPage({Key? key, required this.jobID}) : super(key: key);

  // Helper: group docs by date (yyyy-MM-dd)
  Map<String, List<QueryDocumentSnapshot>> _groupByDate(
      List<QueryDocumentSnapshot> docs) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final dateString = data['capturedDate'] ?? '';
      if (dateString.isEmpty) continue;

      final DateTime dt = DateTime.tryParse(dateString) ?? DateTime.now();
      final String day =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(day, () => []);
      grouped[day]!.add(doc);
    }

    // Sort keys descending by date
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final Map<String, List<QueryDocumentSnapshot>> sortedMap = {};
    for (var k in sortedKeys) {
      sortedMap[k] = grouped[k]!;
    }
    return sortedMap;
  }

  void _showFullImage(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: MemoryImage(bytes),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Images')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('imageRecord')
            .where('jobsID', isEqualTo: jobID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No images found.'));
          }

          final docs = snapshot.data!.docs;
          final grouped = _groupByDate(docs);

          return ListView(
            children: grouped.entries.map((entry) {
              final String date = entry.key;
              final List<QueryDocumentSnapshot> images = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[300],
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Captured Date: $date',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final data =
                          images[index].data() as Map<String, dynamic>;
                      final String base64Img = data['image'] ?? '';
                      Uint8List bytes = base64Decode(base64Img);

                      return GestureDetector(
                        onTap: () => _showFullImage(context, bytes),
                        child: Hero(
                          tag: '$date-$index',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
