import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../providers.dart';
import 'dashboard_page.dart';
import 'login_page.dart'; // 👈 import login page

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(
                    labelText: 'Password (min 6)',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _handleSignup,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create account'),
                ),
                const SizedBox(height: 12),
                // 👇 Added navigation to go back to LoginPage
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    setState(() => _loading = true);

    final messenger = ScaffoldMessenger.of(context); // Capture before await

    try {
      await ref.read(authRepoProvider).signup(
            _email.text.trim(),
            _password.text,
          );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      String errorMessage = "Signup failed";
      if (e.response?.data is Map && e.response?.data["error"] != null) {
        errorMessage = e.response?.data["error"];
      }

      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (_) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text("Unexpected error occurred")),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
