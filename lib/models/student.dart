class Student {
  final int id;
  final String name;
  final String rollNo;

  Student({required this.id, required this.name, required this.rollNo});

  factory Student.fromJson(Map<String, dynamic> j) =>
      Student(id: j['id'], name: j['name'], rollNo: j['roll_no']);
}