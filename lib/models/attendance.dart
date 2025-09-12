class AttendanceRecord {
  final int id;
  final int studentId; // non-nullable
  final String name;
  final String rollNo;
  final DateTime date;
  final bool isPresent;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.name,
    required this.rollNo,
    required this.date,
    required this.isPresent,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    if (json['student_id'] == null) {
      throw Exception("Missing student_id in attendance record JSON");
    }

    return AttendanceRecord(
      id: json['id'] ?? 0,
      studentId: json['student_id'] as int,
      name: json['name'] ?? '',
      rollNo: json['roll_no'] ?? '',
      date: DateTime.parse(json['date']),
      isPresent: json['is_present'] == 1 || json['is_present'] == true,
    );
  }
}
