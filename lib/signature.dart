import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:convert';

class SignatureFeedbackPage extends StatefulWidget {
  final String jobID;

  const SignatureFeedbackPage({super.key, required this.jobID});

  @override
  State<SignatureFeedbackPage> createState() => _SignatureFeedbackPageState();
}

class _SignatureFeedbackPageState extends State<SignatureFeedbackPage> {
  final GlobalKey<SignaturePainterState> _signatureKey = GlobalKey<SignaturePainterState>();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;

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
                'Signature',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _clearSignature,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Signature Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFDDDDDD)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Signature',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            height: 200,
                            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SignaturePainter(key: _signatureKey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              'I agree that the signature and initials will be the electronic representation of my signature and initials for all purposes when I use them on documents, including legally binding contracts - just the same as a pen-and-paper signature or initial.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Feedback Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFDDDDDD)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Feedback',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          // Feedback Text Field
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _feedbackController,
                                maxLines: 8,
                                decoration: InputDecoration(
                                  hintText: 'Write Your Feedback',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12),
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Done Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                onPressed: _isLoading ? null : _saveSignatureAndFeedback,
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearSignature() {
    _signatureKey.currentState?.clear();
  }

  Future<void> _saveSignatureAndFeedback() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get signature as image
      final signatureImage = await _signatureKey.currentState?.toImage();
      String? signatureBase64;

      if (signatureImage != null) {
        final byteData = await signatureImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final uint8List = byteData.buffer.asUint8List();
          signatureBase64 = base64Encode(uint8List);
        }
      }

      // Save to Firestore
      final db = FirebaseFirestore.instance;
      final updateData = <String, dynamic>{};

      if (signatureBase64 != null && signatureBase64.isNotEmpty) {
        updateData['signature'] = signatureBase64;
      }

      if (_feedbackController.text.trim().isNotEmpty) {
        updateData['feedback'] = _feedbackController.text.trim();
      }

      if (updateData.isNotEmpty) {
        await db.collection('jobs').doc(widget.jobID).update(updateData);

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        // Show error if nothing to save
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please provide a signature or feedback before saving.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}

// Custom Signature Painter Widget
class SignaturePainter extends StatefulWidget {
  const SignaturePainter({super.key});

  @override
  State<SignaturePainter> createState() => SignaturePainterState();
}

class SignaturePainterState extends State<SignaturePainter> {
  List<Offset?> points = <Offset?>[];

  void clear() {
    setState(() {
      points.clear();
    });
  }

  Future<ui.Image?> toImage() async {
    if (points.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(400, 200);

    // Fill with white background
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    // Draw the signature
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            Offset localPosition = renderBox.globalToLocal(details.globalPosition);
            points.add(localPosition);
          });
        },
        onPanEnd: (details) => points.add(null),
        child: CustomPaint(
          painter: _SignaturePainter(points),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}