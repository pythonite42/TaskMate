import 'package:flutter/material.dart';
import 'package:to_do_list/spacing.dart';
import 'theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // auto-switch with device
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map> loadEntries() async {
    await Future.delayed(Duration(seconds: 2));
    return {
      "todo": ["Einkaufen", "Wäsche"],
      "done": ["Putzen", "Bett richten"],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: loadEntries(),
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Theme.of(context).primaryColor),
                      const SizedBox(height: 20),
                      const Text("Einen Moment ..."),
                    ],
                  ),
                );
              }
            case ConnectionState.done:
              {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text("Deine To-Do Liste", style: Theme.of(context).textTheme.headlineLarge),
                      ),
                      for (String entry in snapshot.data?["todo"]) EntryRow(name: entry, isDone: false),
                      AppSpacing.lg.vSpace,
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text("Erledigte Einträge", style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      for (String entry in snapshot.data?["done"]) EntryRow(name: entry, isDone: true),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

class EntryRow extends StatelessWidget {
  const EntryRow({super.key, required this.name, required this.isDone});

  final String name;
  final bool isDone;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(name),
        Checkbox(value: isDone, onChanged: (newValue) {}),
      ],
    );
  }
}
