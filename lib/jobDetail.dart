import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailsPage extends StatelessWidget {
  final String jobID; 

  const JobDetailsPage({super.key, required this.jobID});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Text(jobID),

      ),
    );
  }
}
