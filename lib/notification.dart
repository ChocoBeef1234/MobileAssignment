import 'package:flutter/material.dart';
import 'package:user_profile/notificationFilter.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const Text(
                    "Notification",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Filter Icon
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => const NotificationFilterDialog(),
                      );

                      if (result != null) {
                        print("Filter applied: $result");
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Notifications List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionTitle("Today"),
                  _buildNotificationItem(
                    icon: Icons.work_outline,
                    iconColor: Colors.blue,
                    title: "New Job Assigned",
                    subtitle: "Today | 9:21 AM",
                    unread: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.refresh,
                    iconColor: Colors.purple,
                    title: "Job Status Update",
                    subtitle: "Today | 12:31 PM",
                    unread: true,
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle("Yesterday"),
                  _buildNotificationItem(
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                    title: "Job Completed",
                    subtitle: "Yesterday | 01:01 PM",
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle("This Week"),
                  _buildNotificationItem(
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                    title: "Job Completed",
                    subtitle: "Tuesday | 02:01 PM",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Notification Item Widget
  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool unread = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Unread dot
          if (unread)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
