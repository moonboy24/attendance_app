import 'package:intl/intl.dart';
import '../models/attendance.dart';
import '../services/api_client.dart';

class AttendanceRepository {
  final ApiClient api;
  AttendanceRepository(this.api);

  // Fetch attendance records for a specific date
  Future<List<AttendanceRecord>> forDate(DateTime date) async {
    final d = DateFormat('yyyy-MM-dd').format(date);

    final res = await api.client.get('/attendance', queryParameters: { 'date': d });

    final List<dynamic> data = res.data;

    // Only include records with a valid student_id
    final records = data.where((e) => e['student_id'] != null).toList();

    return records.map((e) => AttendanceRecord.fromJson(e)).toList();
  }

  // Mark attendance for a specific date
  Future<void> mark(DateTime date, Map<int, bool> studentIdToStatus) async {
    final d = DateFormat('yyyy-MM-dd').format(date);

    final records = studentIdToStatus.entries.map((e) => {
      'student_id': e.key,
      'date': d,
      'is_present': e.value,
    }).toList();

    await api.client.post('/attendance/mark', data: records);
  }
}
