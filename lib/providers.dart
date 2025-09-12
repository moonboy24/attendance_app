import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_client.dart';
import 'data/auth_repository.dart';
import 'data/student_repository.dart';
import 'data/attendance_repository.dart';

final apiClientProvider = Provider((ref) => ApiClient());
final authRepoProvider = Provider((ref) => AuthRepository(ref.read(apiClientProvider)));
final studentRepoProvider = Provider((ref) => StudentRepository(ref.read(apiClientProvider)));
final attendanceRepoProvider = Provider((ref) => AttendanceRepository(ref.read(apiClientProvider)));

final authStateProvider = StateProvider<bool>((ref) => false);