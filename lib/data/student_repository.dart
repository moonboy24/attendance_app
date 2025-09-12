import '../models/student.dart';
import '../services/api_client.dart';

class StudentRepository {
  final ApiClient api;
  StudentRepository(this.api);

  Future<List<Student>> fetchStudents() async {
    final res = await api.client.get('/students');
    return (res.data as List).map((e) => Student.fromJson(e)).toList();
  }

  Future<void> addStudent(String name, String rollNo) async {
    await api.client.post('/students', data: { 'name': name, 'roll_no': rollNo });
  }

  Future<void> deleteStudent(int id) async {
    await api.client.delete('/students/$id');
  }
}