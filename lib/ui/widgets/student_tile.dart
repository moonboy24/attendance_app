import 'package:flutter/material.dart';


class StudentTile extends StatelessWidget {
final String name;
final bool isPresent;
final VoidCallback onToggle;
final VoidCallback onDelete;


const StudentTile({
super.key,
required this.name,
required this.isPresent,
required this.onToggle,
required this.onDelete,
});


@override
Widget build(BuildContext context) {
return Card(
margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
child: ListTile(
title: Text(name),
leading: IconButton(
icon: Icon(
isPresent ? Icons.check_circle : Icons.cancel,
color: isPresent ? Colors.green : Colors.red,
),
onPressed: onToggle,
),
trailing: IconButton(
icon: const Icon(Icons.delete, color: Colors.red),
onPressed: onDelete,
),
),
);
}
}