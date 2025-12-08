# Workshop Job Management Module

A Flutter + Firebase–powered job management system designed for workshop mechanics to manage work orders efficiently.
This module provides mechanics with a clean dashboard, real-time updates, time tracking, job documentation, and optional digital sign-off — all in one streamlined application.

---

## Overview
The Workshop Job Management Module improves productivity and documentation accuracy inside automotive or equipment service workshops.

Mechanics and staff can:

1. View all assigned jobs for the day/week
2. Access detailed job information
3. Update job status in real time
4. Track task durations
5. Capture notes and photos for evidence
6. Allow customers to sign upon completion

Every feature enhances workflow transparency and ensures high-quality service.

---

## Features

### Dashboard View 
- Overview of daily and weekly work orders
- Displays job priority and assignment
- Quick access to active tasks

### Job Details 
Each job contains complete information, including:
- Customer name & contact
- Vehicle/equipment details
- Job description & requested services
- Assigned parts
- Vehicle/equipment service history

### Job Status Updates
Mechanics can update statuses with one tap:
- Accepted
- In Progress
- On Hold
- Completed

### Time Tracking
- Start, pause, and stop task timers
- Track labour time per job
- Useful for reporting and cost estimation

### Notes & Photo Capture
- Add text notes for findings or instructions
- Capture photos of:
  - Part issues
  - Vehicle damages
  - Completed repair work
- Media stored in Firebase Storage and linked to the job

### Digital Customer Sign-off
- Customers sign digitally upon job completion
- Signature stored alongside job record

---

##  Tech Stack

| Component | Technology |
|------------|-------------|
| **Frontend / UI** | Flutter (Dart) |
| **Database** | Firebase Firestore |
| **State Management** | Provider |
| **Auth** | Firebase Authentication |
| **Version Control** | GitHub |
| **Collaboration** | Multi-developer contribution via branches and pull requests |

---

##  Installation & Setup

### Prerequisites
- Flutter SDK (latest version)
- Firebase CLI
- Android Studio / VS Code
- Git

### Steps
```bash
# 1️⃣ Clone the repository
git clone https://github.com/ChocoBeef1234/MobileAssignment
cd MobileAssignment

# 2️⃣ Get dependencies
flutter pub get

# 3️⃣ Run the application
flutter run
