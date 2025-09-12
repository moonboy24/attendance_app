import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/attendance_repository.dart';
import '../../services/api_client.dart';
import '../../models/student.dart';
import '../../data/student_repository.dart';
import 'package:intl/intl.dart';

final studentRepoProvider = Provider((ref) => StudentRepository(ApiClient()));
final attendanceRepoProvider = Provider((ref) => AttendanceRepository(ApiClient()));

class MarkAttendancePage extends ConsumerStatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  ConsumerState<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends ConsumerState<MarkAttendancePage> {
  DateTime _date = DateTime.now();
  List<Student> _students = [];
  Map<int, bool> _status = {}; // Use bool for Present/Absent
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // ✅ Fixed _fetchStudents method
  Future<void> _fetchStudents() async {
    setState(() => _loading = true);

    try {
      final students = await ref.read(studentRepoProvider).fetchStudents();
      final records = await ref.read(attendanceRepoProvider).forDate(_date);

      // Map studentId → isPresent safely
      final Map<int, bool> statusMap = {
        for (var r in records) if (r.studentId != null) r.studentId!: r.isPresent
      };

      setState(() {
        _students = students;
        _status = statusMap;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load students/attendance: $e")),
      );
    }
  }

  Future<void> _saveAttendance() async {
    try {
      await ref.read(attendanceRepoProvider).mark(_date, _status);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Attendance saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save attendance: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Save Attendance",
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text("Date: "),
                      TextButton(
                        child: Text(DateFormat('yyyy-MM-dd').format(_date)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _date = picked);
                            _fetchStudents(); // reload attendance for new date
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return ListTile(
                        title: Text(student.name),
                        subtitle: Text("Roll No: ${student.rollNo}"),
                        trailing: DropdownButton<bool>(
                          value: _status[student.id] ?? false, // default Absent = false
                          items: const [
                            DropdownMenuItem(value: true, child: Text("Present")),
                            DropdownMenuItem(value: false, child: Text("Absent")),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _status[student.id] = val!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
