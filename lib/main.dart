import 'package:flutter/material.dart';
import 'package:to_do_list/global_settings/theme.dart';
import 'package:to_do_list/pages/todo.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const ToDoPage(),
    );
  }
}
