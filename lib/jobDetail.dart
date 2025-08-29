import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailsPage extends StatelessWidget {
  final String carPlate; // e.g. "ABC1234"

  const JobDetailsPage({super.key, required this.carPlate});

  @override
  Widget build(BuildContext context) {
    final jobQuery = FirebaseFirestore.instance
        .collection('Customer')
        .where('Car Plate', isEqualTo: carPlate) // find by field
        .limit(1);

    return Scaffold(
      appBar: AppBar(title: const Text("Job Details")),
      body: FutureBuilder<QuerySnapshot>(
        future: jobQuery.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No job found"));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          final name = data['Name'] ?? '';
          final carPlate = data['Car Plate'] ?? '';
          final jobStatus = data['Job Status'] ?? '';
          final jobDescription = data['Job Description'] ?? '';
          final vin = data['VIN'] ?? '';
          final assignedParts = List<String>.from(data['Assigned Parts'] ?? []);
          final vehicle = data['Vehicle'] ?? '';
          final timestamp = data['Date'] as Timestamp?;
          final formattedDate =
              timestamp != null ? timestamp.toDate().toString().split(" ")[0] : "";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text("Name: $name"),
                Text("Car Plate: $carPlate"),
                Text("VIN: $vin"),
                Text("Job Status: $jobStatus"),
                Text("Job Description: $jobDescription"),
                Text("Assigned Parts: ${assignedParts.join(", ")}"),
                Text("Vehicle: $vehicle"),
                Text("Date: $formattedDate"),
              ],
            ),
          );
        },
      ),
    );
  }
}
