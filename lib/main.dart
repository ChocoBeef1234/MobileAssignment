import 'package:flutter/material.dart';
import 'package:user_profile/mySchedule.dart';
import 'package:user_profile/myTask.dart';
import 'package:user_profile/myTimer.dart';
import 'package:user_profile/profile.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter engine is ready

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await SeedFirestore.seed();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;


  final List<Widget> pages = const [
    MyTasksPage(),
    MySchedulePage(),
    TimerPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          // Current page content5
          pages[currentIndex],

          // Floating nav bar
          Positioned(
            left: 60,
            right: 60,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                spacing: 0,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: currentIndex == 0
                            ? Colors.white
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.list,
                        color: currentIndex == 0
                            ? Colors.black
                            : Colors.white54,
                        size: 18,
                      ),
                    ),
                    onPressed: () => setState(() => currentIndex = 0),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: currentIndex == 1
                            ? Colors.white
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: currentIndex == 1
                            ? Colors.black
                            : Colors.white54,
                        size: 18,
                      ),
                    ),
                    onPressed: () => setState(() => currentIndex = 1),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: currentIndex == 2
                            ? Colors.white
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: currentIndex == 2
                            ? Colors.black
                            : Colors.white54,
                        size: 18,
                      ),
                    ),
                    onPressed: () => setState(() => currentIndex = 2),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: currentIndex == 3
                            ? Colors.white
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: currentIndex == 3
                            ? Colors.black
                            : Colors.white54,
                        size: 18,
                      ),
                    ),
                    onPressed: () => setState(() => currentIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("Calendar Page"));
}
