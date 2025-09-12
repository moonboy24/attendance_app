import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../models/student.dart';

class StudentsPage extends ConsumerStatefulWidget {
  const StudentsPage({super.key});
  @override
  ConsumerState<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends ConsumerState<StudentsPage> {
  late Future<List<Student>> _future;
  final _name = TextEditingController();
  final _roll = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = ref.read(studentRepoProvider).fetchStudents();
  }

  Future<void> _reload() async {
    setState(() { _future = ref.read(studentRepoProvider).fetchStudents(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _roll, decoration: const InputDecoration(labelText: 'Roll No'))),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  await ref.read(studentRepoProvider).addStudent(_name.text.trim(), _roll.text.trim());
                  _name.clear(); _roll.clear();
                  await _reload();
                },
                child: const Text('Add'),
              )
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Student>>(
                future: _future,
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final items = snap.data!;
                  if (items.isEmpty) return const Center(child: Text('No students yet'));
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = items[i];
                      return ListTile(
                        title: Text('${s.rollNo} — ${s.name}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async { await ref.read(studentRepoProvider).deleteStudent(s.id); await _reload(); },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}