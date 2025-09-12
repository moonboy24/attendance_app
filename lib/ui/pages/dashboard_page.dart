import 'package:flutter/material.dart';
import 'students_page.dart';
import 'mark_attendance_page.dart';
import '../../utils/pdf_export.dart';
import 'login_page.dart'; // 👈 make sure you have this file
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token"); // 👈 clear JWT token

    // Navigate back to login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sign Out",
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ------------------- COMMENT -------------------
                // Button to go to Mark Attendance Page
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MarkAttendancePage()),
                  ),
                  child: const Text('Student Mark Attendance'),
                ),
                const SizedBox(height: 8),

                // ------------------- COMMENT -------------------
                // Button to view Students List
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentsPage()),
                  ),
                  child: const Text('Students List (Add/Delete)'),
                ),
                const SizedBox(height: 8),

                // ------------------- COMMENT -------------------
                // Button to export PDF for a single date
                FilledButton(
                  onPressed: () async {
                    await exportSingleDatePdf(context);
                  },
                  child: const Text('Download Attendance PDF (Single Date)'),
                ),

                const SizedBox(height: 8),

                // ------------------- COMMENT -------------------
                // Button to export PDF for a date range
                FilledButton(
                  onPressed: () async {
                    await exportAttendancePdf(context);
                  },
                  child: const Text('Download Attendance PDF (Date Range)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
