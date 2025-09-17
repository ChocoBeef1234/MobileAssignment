import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_profile/notificationFilter.dart';

class FirebaseNotification {
  final String id;
  final String title;
  final String detail;
  final String type;
  final DateTime date;
  final bool read;
  final String? staffId;

  FirebaseNotification({
    required this.id,
    required this.title,
    required this.detail,
    required this.type,
    required this.date,
    required this.read,
    this.staffId,
  });

  factory FirebaseNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return FirebaseNotification(
      id: doc.id,
      title: data['Title'] ?? 'No Title',
      detail: data['Detail'] ?? 'No details available',
      type: data['Type'] ?? 'Unknown',
      date: (data['Date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['Read'] ?? false,
      staffId: data['staffId'],
    );
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'newassigned':
        return Icons.work_outline;
      case 'updated':
        return Icons.refresh;
      case 'assigned':
        return Icons.assignment;
      default:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'newassigned':
        return Colors.blue;
      case 'updated':
        return Colors.purple;
      case 'assigned':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get subtitle {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    String timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    if (notificationDate == today) {
      return "Today | $timeStr";
    } else if (notificationDate == yesterday) {
      return "Yesterday | $timeStr";
    } else {

      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      if (notificationDate.isAfter(weekStart.subtract(Duration(days: 1)))) {
        final weekday = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        return "${weekday[date.weekday - 1]} | $timeStr";
      } else {
        return "${date.day}-${date.month}-${date.year} | $timeStr";
      }
    }
  }
}

class NotificationPage extends StatefulWidget {
  final String? staffId;

  const NotificationPage({super.key, this.staffId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Stream<QuerySnapshot> _notificationStream;
  Map<String, dynamic>? _currentFilter;

  @override
  void initState() {
    super.initState();
    _initializeNotificationStream();
  }

  void _initializeNotificationStream() {
    Query query = FirebaseFirestore.instance.collection('notification');

    if (widget.staffId != null && widget.staffId!.isNotEmpty) {
      query = query.where('staffId', isEqualTo: widget.staffId);
    }

    if (_currentFilter != null) {
      query = _applyFiltersToQuery(query, _currentFilter!);
    } else {
      query = query.orderBy('Date', descending: true);
    }

    _notificationStream = query.snapshots();
  }

  Query _applyFiltersToQuery(Query query, Map<String, dynamic> filters) {
    // Apply sorting first (only call orderBy once)
    bool ascending = filters['sortBy'] == 'Oldest to Newest';
    query = query.orderBy('Date', descending: !ascending);

    // Apply date filters
    if (filters['from'] != null) {
      query = query.where('Date', isGreaterThanOrEqualTo: Timestamp.fromDate(filters['from']));
    }
    if (filters['to'] != null) {
      query = query.where('Date', isLessThanOrEqualTo: Timestamp.fromDate(filters['to']));
    }

    return query;
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notification')
          .doc(notificationId)
          .update({'Read': true});
    } catch (e) {
      print('Error marking notification as read: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark notification as read')),
        );
      }
    }
  }

  void _navigateToDetails(FirebaseNotification notification) {
    if (!notification.read) {
      _markAsRead(notification.id);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationDetailsPage(
          notification: notification,
        ),
      ),
    );
  }

  void _applyFilter(Map<String, dynamic> filterData) {
    setState(() {
      _currentFilter = filterData;
      _initializeNotificationStream();
    });
  }

  List<FirebaseNotification> _groupNotificationsByPeriod(
      List<FirebaseNotification> notifications, String period) {
    final now = DateTime.now();

    return notifications.where((notification) {
      switch (period) {
        case 'Today':
          return _isSameDay(notification.date, now);
        case 'Yesterday':
          return _isSameDay(notification.date, now.subtract(Duration(days: 1)));
        case 'This Week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final yesterday = now.subtract(Duration(days: 1));
          return notification.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
              notification.date.isBefore(yesterday.add(Duration(days: 1)));
        default:
          return false;
      }
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const Text(
                    "Notification",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => const NotificationFilterDialog(),
                      );

                      if (result != null) {
                        _applyFilter(result);
                      } else {
                        // Handle reset - clear all filters
                        setState(() {
                          _currentFilter = null;
                          _initializeNotificationStream();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _notificationStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    String errorMessage = 'Something went wrong';
                    if (snapshot.error.toString().contains('invalid-argument')) {
                      errorMessage = 'No Work Founded.';
                    } else if (snapshot.error.toString().contains('permission-denied')) {
                      errorMessage = 'Permission denied. Please check your access rights.';
                    } else {
                      errorMessage = 'Unable to load notifications. Please try again later.';
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage,
                              style: TextStyle(fontSize: 16, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentFilter = null;
                                _initializeNotificationStream();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: Text('Reset Filter', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            _currentFilter != null
                                ? 'No notifications found for the selected date range'
                                : 'No notifications found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          if (_currentFilter != null) ...[
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentFilter = null;
                                  _initializeNotificationStream();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: Text('Clear Filter', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  final notifications = snapshot.data!.docs
                      .map((doc) => FirebaseNotification.fromFirestore(doc))
                      .toList();

                  final todayNotifications = _groupNotificationsByPeriod(notifications, 'Today');
                  final yesterdayNotifications = _groupNotificationsByPeriod(notifications, 'Yesterday');
                  final thisWeekNotifications = _groupNotificationsByPeriod(notifications, 'This Week');

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (todayNotifications.isNotEmpty) ...[
                        _buildSectionTitle("Today"),
                        ...todayNotifications.map((notification) =>
                            _buildNotificationItem(notification)),
                        const SizedBox(height: 16),
                      ],

                      if (yesterdayNotifications.isNotEmpty) ...[
                        _buildSectionTitle("Yesterday"),
                        ...yesterdayNotifications.map((notification) =>
                            _buildNotificationItem(notification)),
                        const SizedBox(height: 16),
                      ],

                      if (thisWeekNotifications.isNotEmpty) ...[
                        _buildSectionTitle("This Week"),
                        ...thisWeekNotifications.map((notification) =>
                            _buildNotificationItem(notification)),
                      ],

                      if (todayNotifications.isEmpty &&
                          yesterdayNotifications.isEmpty &&
                          thisWeekNotifications.isEmpty &&
                          notifications.isNotEmpty) ...[
                        _buildSectionTitle("All Notifications"),
                        ...notifications.map((notification) =>
                            _buildNotificationItem(notification)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildNotificationItem(FirebaseNotification notification) {
    return GestureDetector(
      onTap: () => _navigateToDetails(notification),
      child: Container(
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
                color: notification.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 20
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            if (!notification.read)
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
      ),
    );
  }
}

class NotificationDetailsPage extends StatelessWidget {
  final FirebaseNotification notification;

  const NotificationDetailsPage({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Notification Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timestamp
                    Text(
                      notification.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      notification.detail,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Got It',
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
      ),
    );
  }
}