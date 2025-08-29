// Firestore schema + seeding for the Vehicle Service/Repair system shown in your ERD
// -----------------------------------------------------------------------------
// What this file does
// 1) Initializes Firebase
// 2) Creates collections/documents that mirror your ERD
// 3) Provides strongly-typed helpers to create records with referential checks
// 4) Includes a one-off seed() you can run to generate sample data
// -----------------------------------------------------------------------------
// How to use
// - Add firebase_core: ^3 and cloud_firestore: ^5 to pubspec.yaml
// - Configure Firebase in your Flutter project (flutterfire configure)
// - Put this file in lib/ and call SeedFirestore.seed() from a debug/admin-only flow
//   e.g., in main() after WidgetsFlutterBinding.ensureInitialized()
// -----------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Fire {
  static FirebaseFirestore get db => FirebaseFirestore.instance;
}

// ---------------------------- Collection names -------------------------------
class Col {
  static const customers = 'customers';
  static const vehicles = 'vehicles';
  static const jobs = 'jobs';
  static const spareParts = 'spareParts';
  static const jobParts = 'jobParts';
  static const services = 'services';
  static const jobServices = 'jobServices';
  static const staff = 'staff';
  static const jobAssignments = 'jobAssignments';
}

// ------------------------------- Data models ---------------------------------
class Customer {
  final String id;
  final String name;
  final String contactNo;
  final String email;
  final String passwordHash; // never store plaintext passwords

  Customer({
    required this.id,
    required this.name,
    required this.contactNo,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() => {
        'custID': id,
        'custName': name,
        'custContactNo': contactNo,
        'custEmail': email,
        'custPasswordHash': passwordHash,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class Vehicle {
  final String id;
  final String plateNo;
  final String model;
  final int year;
  final String vinNo;
  final String custID; // FK -> customers

  Vehicle({
    required this.id,
    required this.plateNo,
    required this.model,
    required this.year,
    required this.vinNo,
    required this.custID,
  });

  Map<String, dynamic> toMap() => {
        'vehicleID': id,
        'plateNo': plateNo,
        'model': model,
        'year': year,
        'vinNo': vinNo,
        'custID': custID,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class Job {
  final String id;
  final Timestamp jobDate;
  final String jobStatus; // e.g., pending, in_progress, done
  final num totalCost; // sum(services + parts)
  final String vehicleID; // FK -> vehicles

  Job({
    required this.id,
    required this.jobDate,
    required this.jobStatus,
    required this.totalCost,
    required this.vehicleID,
  });

  Map<String, dynamic> toMap() => {
        'jobID': id,
        'jobDate': jobDate,
        'jobStatus': jobStatus,
        'totalCost': totalCost,
        'vehicleID': vehicleID,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class SparePart {
  final String id;
  final String name;
  final num cost;
  final int stockQty;

  SparePart({
    required this.id,
    required this.name,
    required this.cost,
    required this.stockQty,
  });

  Map<String, dynamic> toMap() => {
        'partID': id,
        'partName': name,
        'partCost': cost,
        'stockQty': stockQty,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class JobPart {
  final String id;
  final String jobID; // FK -> jobs
  final String partID; // FK -> spareParts
  final int quantityUsed;

  JobPart({
    required this.id,
    required this.jobID,
    required this.partID,
    required this.quantityUsed,
  });

  Map<String, dynamic> toMap() => {
        'jobPartID': id,
        'jobID': jobID,
        'partID': partID,
        'quantityUsed': quantityUsed,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class ServiceItem {
  final String id;
  final String serviceName;
  final String serviceDescription;
  final num serviceCost;

  ServiceItem({
    required this.id,
    required this.serviceName,
    required this.serviceDescription,
    required this.serviceCost,
  });

  Map<String, dynamic> toMap() => {
        'serviceID': id,
        'serviceName': serviceName,
        'serviceDescription': serviceDescription,
        'serviceCost': serviceCost,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class JobService {
  final String id;
  final String jobID; // FK -> jobs
  final String serviceID; // FK -> services
  final num subtotal; // copy of serviceCost or computed price

  JobService({
    required this.id,
    required this.jobID,
    required this.serviceID,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() => {
        'jobServiceID': id,
        'jobID': jobID,
        'serviceID': serviceID,
        'subtotal': subtotal,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class Staff {
  final String id;
  final String name;
  final String contactNo;
  final String email;
  final String passwordHash;
  final int jobCompleted;
  final num averageCompletionTime; // in hours
  final num rating; // 1..5

  Staff({
    required this.id,
    required this.name,
    required this.contactNo,
    required this.email,
    required this.passwordHash,
    this.jobCompleted = 0,
    this.averageCompletionTime = 0,
    this.rating = 0,
  });

  Map<String, dynamic> toMap() => {
        'staffID': id,
        'staffName': name,
        'staffContactNo': contactNo,
        'staffEmail': email,
        'staffPasswordHash': passwordHash,
        'jobCompleted': jobCompleted,
        'averageCompletionTime': averageCompletionTime,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class JobAssignment {
  final String id;
  final String jobID; // FK -> jobs
  final String staffID; // FK -> staff
  final num hoursWorked;

  JobAssignment({
    required this.id,
    required this.jobID,
    required this.staffID,
    required this.hoursWorked,
  });

  Map<String, dynamic> toMap() => {
        'jobAssignmentID': id,
        'jobID': jobID,
        'staffID': staffID,
        'hoursWorked': hoursWorked,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// ---------------------------- CRUD helper service ----------------------------
class Repo {
  final db = Fire.db;

  // Generic add helpers -------------------------------------------------------
  Future<void> addCustomer(Customer c) async =>
      db.collection(Col.customers).doc(c.id).set(c.toMap());

  Future<void> addVehicle(Vehicle v) async {
    // Ensure FK: customer exists
    final custDoc = await db.collection(Col.customers).doc(v.custID).get();
    if (!custDoc.exists) throw Exception('Customer ${v.custID} not found');
    await db.collection(Col.vehicles).doc(v.id).set(v.toMap());
  }

  Future<void> addJob(Job j) async {
    final veh = await db.collection(Col.vehicles).doc(j.vehicleID).get();
    if (!veh.exists) throw Exception('Vehicle ${j.vehicleID} not found');
    await db.collection(Col.jobs).doc(j.id).set(j.toMap());
  }

  Future<void> addSparePart(SparePart p) async =>
      db.collection(Col.spareParts).doc(p.id).set(p.toMap());

  Future<void> addService(ServiceItem s) async =>
      db.collection(Col.services).doc(s.id).set(s.toMap());

  Future<void> addStaff(Staff s) async =>
      db.collection(Col.staff).doc(s.id).set(s.toMap());

  // Add JobPart while decrementing stock in a transaction --------------------
  Future<void> addJobPart(JobPart jp) async {
    final jobRef = db.collection(Col.jobs).doc(jp.jobID);
    final partRef = db.collection(Col.spareParts).doc(jp.partID);
    final jobPartRef = db.collection(Col.jobParts).doc(jp.id);

    await db.runTransaction((tx) async {
      final jobSnap = await tx.get(jobRef);
      if (!jobSnap.exists) throw Exception('Job ${jp.jobID} not found');

      final partSnap = await tx.get(partRef);
      if (!partSnap.exists) throw Exception('Part ${jp.partID} not found');

      final currentStock = (partSnap.data()! as Map<String, dynamic>)['stockQty'] as int;
      if (currentStock < jp.quantityUsed) {
        throw Exception('Not enough stock for part ${jp.partID}');
      }

      tx.set(jobPartRef, jp.toMap());
      tx.update(partRef, {'stockQty': currentStock - jp.quantityUsed});
    });
  }

  // Add JobService ------------------------------------------------------------
  Future<void> addJobService(JobService js) async {
    final jobRef = db.collection(Col.jobs).doc(js.jobID);
    final serviceRef = db.collection(Col.services).doc(js.serviceID);
    final jsRef = db.collection(Col.jobServices).doc(js.id);

    await db.runTransaction((tx) async {
      final jobSnap = await tx.get(jobRef);
      if (!jobSnap.exists) throw Exception('Job ${js.jobID} not found');

      final servSnap = await tx.get(serviceRef);
      if (!servSnap.exists) throw Exception('Service ${js.serviceID} not found');

      tx.set(jsRef, js.toMap());
    });
  }

  Future<void> addJobAssignment(JobAssignment ja) async {
    final jobRef = db.collection(Col.jobs).doc(ja.jobID);
    final staffRef = db.collection(Col.staff).doc(ja.staffID);
    final jaRef = db.collection(Col.jobAssignments).doc(ja.id);

    await db.runTransaction((tx) async {
      final jobSnap = await tx.get(jobRef);
      if (!jobSnap.exists) throw Exception('Job ${ja.jobID} not found');

      final staffSnap = await tx.get(staffRef);
      if (!staffSnap.exists) throw Exception('Staff ${ja.staffID} not found');

      tx.set(jaRef, ja.toMap());
    });
  }
}

// --------------------------------- Seeding -----------------------------------
class SeedFirestore {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  static Future<void> seed() async {
    final repo = Repo();

    // Sample baseline data ----------------------------------------------------
    final customer = Customer(
      id: 'CUST001',
      name: 'Alice Tan',
      contactNo: '+60-12-3456789',
      email: 'alice@example.com',
      passwordHash: 'hash:dummy',
    );

    final vehicle = Vehicle(
      id: 'VEH001',
      plateNo: 'WXY1234',
      model: 'Perodua Myvi',
      year: 2020,
      vinNo: 'VIN-XYZ-0001',
      custID: customer.id,
    );

    final job = Job(
      id: 'JOB001',
      jobDate: Timestamp.now(),
      jobStatus: 'in_progress',
      totalCost: 0, // will be computed later
      vehicleID: vehicle.id,
    );

    final mechanic = Staff(
      id: 'STF001',
      name: 'Rahman',
      contactNo: '+60-19-2222222',
      email: 'rahman@workshop.com',
      passwordHash: 'hash:dummy',
      rating: 4.8,
    );

    final partOil = SparePart(id: 'PRT001', name: 'Engine Oil 4L', cost: 120, stockQty: 30);
    final partFilter = SparePart(id: 'PRT002', name: 'Oil Filter', cost: 25, stockQty: 100);

    final svcOilChange = ServiceItem(
      id: 'SVC001',
      serviceName: 'Oil Change',
      serviceDescription: 'Replace engine oil and filter',
      serviceCost: 60,
    );

    // Write in a batch for speed --------------------------------------------
    final batch = Fire.db.batch();
    batch.set(Fire.db.collection(Col.customers).doc(customer.id), customer.toMap());
    batch.set(Fire.db.collection(Col.vehicles).doc(vehicle.id), vehicle.toMap());
    batch.set(Fire.db.collection(Col.jobs).doc(job.id), job.toMap());
    batch.set(Fire.db.collection(Col.staff).doc(mechanic.id), mechanic.toMap());
    batch.set(Fire.db.collection(Col.spareParts).doc(partOil.id), partOil.toMap());
    batch.set(Fire.db.collection(Col.spareParts).doc(partFilter.id), partFilter.toMap());
    batch.set(Fire.db.collection(Col.services).doc(svcOilChange.id), svcOilChange.toMap());
    await batch.commit();

    // Use helpers that enforce FKs -------------------------------------------
    await repo.addJobAssignment(JobAssignment(
      id: 'ASSIGN001',
      jobID: job.id,
      staffID: mechanic.id,
      hoursWorked: 1.5,
    ));

    await repo.addJobPart(JobPart(
      id: 'JP001',
      jobID: job.id,
      partID: partOil.id,
      quantityUsed: 1,
    ));

    await repo.addJobPart(JobPart(
      id: 'JP002',
      jobID: job.id,
      partID: partFilter.id,
      quantityUsed: 1,
    ));

    await repo.addJobService(JobService(
      id: 'JS001',
      jobID: job.id,
      serviceID: svcOilChange.id,
      subtotal: svcOilChange.serviceCost,
    ));

    debugPrint('Seeding complete.');
  }
}

// Example main() you can use during development only -------------------------
// void main() async {
//   await SeedFirestore.init();
//   await SeedFirestore.seed();
// }
