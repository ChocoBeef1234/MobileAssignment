import 'dart:io';
import 'dart:convert'; // for base64 encoding
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CameraUploadPage extends StatefulWidget {
  const CameraUploadPage({Key? key}) : super(key: key);

  @override
  State<CameraUploadPage> createState() => _CameraUploadPageState();
}

class _CameraUploadPageState extends State<CameraUploadPage> {
  final ImagePicker _picker = ImagePicker();

  // Store multiple selected image files
  final List<File> _imageFiles = [];
  bool _isLoading = false;

  Future<void> _capturePhoto() async {
    // Open camera to take one photo
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _saveAllToFirebase() async {
    if (_imageFiles.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      for (File imgFile in _imageFiles) {
        // Convert image to bytes
        Uint8List bytes = await imgFile.readAsBytes();
        // Encode to Base64
        String base64Image = base64Encode(bytes);

        // Save each image as a new document in Firestore
        await FirebaseFirestore.instance.collection('imageRecord').add({
          'jobsID': 'JOB001',
          'capturedDate': DateTime.now().toIso8601String(),
          'image': base64Image,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All photos saved to Firestore!')),
      );

      // Clear local list after saving
      setState(() {
        _imageFiles.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Multiple Photos')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: _imageFiles.isEmpty
                ? const Center(child: Text('No photos captured'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              _imageFiles[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: InkWell(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture Photo'),
                  onPressed: _capturePhoto,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _isLoading
                      ? const Text('Saving...')
                      : const Text('Save All'),
                  onPressed: _isLoading ? null : _saveAllToFirebase,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
