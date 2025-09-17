import 'package:flutter/material.dart';

class NotificationFilterDialog extends StatefulWidget {
  const NotificationFilterDialog({super.key});

  @override
  _NotificationFilterDialogState createState() =>
      _NotificationFilterDialogState();
}

class _NotificationFilterDialogState extends State<NotificationFilterDialog> {
  DateTime? fromDate;
  DateTime? toDate;
  String sortBy = "Newest to Oldest (Newest First)";

  final List<String> sortOptions = [
    "Newest to Oldest (Newest First)",
    "Oldest to Newest",
  ];

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void _setToday() {
    final today = DateTime.now();
    setState(() {
      fromDate = DateTime(today.year, today.month, today.day);
      toDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
    });
  }

  void _setThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    setState(() {
      fromDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      toDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
    });
  }

  void _setThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    setState(() {
      fromDate = startOfMonth;
      toDate = DateTime(endOfMonth.year, endOfMonth.month, endOfMonth.day, 23, 59, 59);
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter by:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Date pickers
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "From",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        onPressed: () => _pickDate(context, true),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                fromDate == null
                                    ? "Select date"
                                    : _formatDate(fromDate!),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "To",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        onPressed: () => _pickDate(context, false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                toDate == null
                                    ? "Select date"
                                    : _formatDate(toDate!),
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size(85, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _setToday,
                  child: const Text("Today", style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size(85, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _setThisWeek,
                  child: const Text(
                    "This Week",
                    style: TextStyle(fontSize: 12),
                  ),
                ),

                const SizedBox(width: 6),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size(85, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _setThisMonth,
                  child: const Text(
                    "This Month",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sort dropdown
            const Text(
              "Sort by",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: sortBy,
              items: sortOptions
                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: 12)),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() => sortBy = value!);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                      sortBy = sortOptions[0];
                    });
                  },
                  child: const Text("Reset All"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      "from": fromDate,
                      "to": toDate,
                      "sortBy": sortBy,
                    });
                  },
                  child: const Text(
                    "Apply Filter",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}