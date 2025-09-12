import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);

  Future<void> signup(String email, String password) async {
    final res = await api.client.post('/auth/signup', data: { 'email': email, 'password': password });
    await _saveToken(res.data['token']);
  }

  Future<void> login(String email, String password) async {
    final res = await api.client.post('/auth/login', data: { 'email': email, 'password': password });
    await _saveToken(res.data['token']);
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
  }

  Future<void> _saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', token);
  }
}