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
  bool? showDoneEntries = true;
  List? todoEntries;
  List? doneEntries;

  @override
  void initState() {
    loadEntries();
    super.initState();
  }

  Future loadEntries() async {
    await Future.delayed(Duration(seconds: 2));
    Map? data = {
      "todo": ["Einkaufen", "Wäsche", "Einkaufen", "Wäsche", "Einkaufen", "Wäsche", "Einkaufen", "Wäsche"],
      "done": [
        "Putzen",
        "Bett richten",
        "Putzen",
        "Bett richten",
        "Putzen",
        "Bett richten",
        "Putzen",
        "Bett richten",
        "Putzen",
        "Bett richten",
      ],
    };

    setState(() {
      todoEntries = data?["todo"] as List<String>? ?? [];
      doneEntries = data?["done"] as List<String>? ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (todoEntries == null && doneEntries == null)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Theme.of(context).primaryColor),
                  const SizedBox(height: 20),
                  const Text("Einen Moment ..."),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text("Deine To-Do Liste", style: Theme.of(context).textTheme.headlineLarge),
                    ),

                    if (todoEntries == null)
                      Text("Fehler beim Laden der Aufgaben")
                    else if (todoEntries?.isEmpty == true)
                      Text("Alle Aufgaben erledigt")
                    else
                      for (int i = 0; i < todoEntries!.length; i++)
                        EntryRow(name: todoEntries![i], isDone: false, showDivider: i < todoEntries!.length - 1),
                    Row(
                      children: [
                        Checkbox(
                          value: showDoneEntries,
                          onChanged: (newValue) {
                            setState(() {
                              showDoneEntries = newValue;
                            });
                          },
                        ),
                        Text("Zeige erledigte Einträge"),
                      ],
                    ),
                    if (showDoneEntries == true)
                      Column(
                        children: [
                          AppSpacing.lg.vSpace,
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text("Erledigte Einträge", style: Theme.of(context).textTheme.headlineMedium),
                          ),
                          if (doneEntries == null)
                            Text("Fehler beim Laden der Aufgaben")
                          else if (doneEntries?.isEmpty == true)
                            Text("Noch keine erledigten Aufgaben")
                          else
                            for (int i = 0; i < doneEntries!.length; i++)
                              EntryRow(name: doneEntries![i], isDone: true, showDivider: i < doneEntries!.length - 1),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class EntryRow extends StatelessWidget {
  const EntryRow({super.key, required this.name, required this.isDone, this.showDivider = false});

  final String name;
  final bool isDone;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(name)),
              Checkbox(value: isDone, onChanged: (newValue) {}),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor),
      ],
    );
  }
}
