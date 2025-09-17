import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController oldController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  bool loading = false;

  @override
  void dispose() {
    oldController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar('No user logged in.');
      return;
    }

    final oldPassword = oldController.text.trim();
    final newPassword = newController.text.trim();
    final confirmPassword = confirmController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty || oldPassword.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnackBar('New passwords do not match.');
      return;
    }

    setState(() => loading = true);

    try {
      // Reauthenticate user first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Now update password
      await user.updatePassword(newPassword);

      _showSnackBar('Password updated successfully!');
      Navigator.pop(context); // back to previous screen
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showSnackBar('Old password is incorrect.');
      } else if (e.code == 'weak-password') {
        _showSnackBar('New password is too weak.');
      } else {
        _showSnackBar('Error: ${e.message}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Set Your New Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter and confirm your new password to gain access.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),

              _buildLabel('Old Password'),
              _buildPasswordField(
                controller: oldController,
                visible: showOld,
                onToggle: () => setState(() => showOld = !showOld),
              ),
              const SizedBox(height: 20),

              _buildLabel('New Password'),
              _buildPasswordField(
                controller: newController,
                visible: showNew,
                onToggle: () => setState(() => showNew = !showNew),
              ),
              const SizedBox(height: 20),

              _buildLabel('Confirm New Password'),
              _buildPasswordField(
                controller: confirmController,
                visible: showConfirm,
                onToggle: () => setState(() => showConfirm = !showConfirm),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: loading ? null : _changePassword,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Change Password',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),
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
          color: Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
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
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            visible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[700],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
