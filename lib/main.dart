import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/app.dart';
import 'package:task_manager/core/utils/nitializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppData();
  runApp(ProviderScope(child: TaskManagerApp()));
}