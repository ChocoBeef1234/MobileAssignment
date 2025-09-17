import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_profile/main.dart'; // your main screen

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> clearAllData() async {
    await _secureStorage.deleteAll(); // Clears all stored data
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await clearAllData();
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Firebase Authentication Sign In
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Save UID securely
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _secureStorage.write(key: 'staffID', value: uid);
      }

      // Navigate to main screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed';
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Incorrect password.';
      }
      setState(() {
        _error = msg;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: WaveBottomClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/loginBackground.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),
                height: 300,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                      decorationColor: Colors.black.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      hintText: "rahman@workshop.com",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Error message
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 50);
    final cp1 = Offset(size.width * 0.25, size.height);
    final ep1 = Offset(size.width * 0.50, size.height - 20);
    path.quadraticBezierTo(cp1.dx, cp1.dy, ep1.dx, ep1.dy);

    final cp2 = Offset(size.width * 0.75, size.height - 80);
    final ep2 = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(cp2.dx, cp2.dy, ep2.dx, ep2.dy);

    path
      ..lineTo(size.width, size.height - 30)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
