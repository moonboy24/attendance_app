// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart'; // Make sure this path is correct

void main() {
  runApp(
    const ProviderScope( // Required for Riverpod
      child: AttendanceApp(),
    ),
  );
}
