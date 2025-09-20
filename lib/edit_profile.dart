import 'dart:convert'; // for base64
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart'; // to pick image
import 'package:user_profile/change_Password.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();


  bool loading = true;
  String? docId; // Firestore document ID of staff
  String? profileBase64; // holds the Base64 image string

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  Future<void> _loadStaffData() async {
    try {
      // 🔹 Get staffID from secure storage
      final staffID = await _secureStorage.read(key: 'staffID');
      if (staffID == null) {
        setState(() => loading = false);
        return;
      }

      // 🔹 Get staff document by staffID field
      final staffSnap = await FirebaseFirestore.instance
          .collection('staff')
          .where('staffID', isEqualTo: staffID)
          .limit(1)
          .get();

      if (staffSnap.docs.isNotEmpty) {
        final staffDoc = staffSnap.docs.first;
        docId = staffDoc.id;
        final data = staffDoc.data();
        nameController.text = data['staffName'] ?? '';
        phoneController.text = data['staffContactNo'] ?? '';
        profileBase64 = data['profile_image']; // your base64 string
      }
    } catch (e) {
      debugPrint('Error loading staff info: $e');
    }

    setState(() => loading = false);
  }

  Future<void> _saveProfile() async {
    if (docId == null) return;

    try {
      await FirebaseFirestore.instance.collection('staff').doc(docId).update({
        'staffName': nameController.text.trim(),
        'staffContactNo': phoneController.text.trim(),
        'profile_image': profileBase64 ?? '', // save updated base64 image
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  /// 🔹 Pick new image from gallery and update `profileBase64`
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() => profileBase64 = base64String);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Convert base64 to bytes if not null
    Uint8List? imageBytes;
    if (profileBase64 != null && profileBase64!.isNotEmpty) {
      try {
        imageBytes = base64Decode(profileBase64!);
      } catch (_) {
        imageBytes = null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Avatar overlapping — tap to change
              Transform.translate(
                offset: const Offset(0, -40),
                child: GestureDetector(
                  onTap: _pickImage, // 🔹 tap to select new image
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: imageBytes != null
                        ? MemoryImage(imageBytes)
                        : null,
                    child: imageBytes == null
                        ? const Icon(Icons.person,
                            size: 56, color: Colors.grey)
                        : null,
                  ),
                ),
              ),

              // Card with fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Name'),
                      _buildTextField(controller: nameController, hint: 'Name'),
                      const SizedBox(height: 16),
                      _buildLabel('Phone'),
                      _buildTextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Password'),
                      _buildPasswordField(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _saveProfile,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 1.2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      readOnly: true,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 1.2),
        ),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordPage(),
                ),
              );
            },
            child: const Text('Change'),
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
