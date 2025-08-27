import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_mate/data/todo_model.dart';
import 'package:task_mate/data/todo_repository.dart';
import 'package:task_mate/global_settings/spacing.dart';
import 'package:task_mate/widgets/add_entry.dart';
import 'package:task_mate/widgets/entry.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final repo = ToDoRepository();
  bool _showDone = true;
  bool _isRefreshing = false;
  StreamSubscription<String>? _errorSubscription;
  String? _lastErrorMessage;
  DateTime _lastErrorShownAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    repo.loadData(); // loads local immediately, then tries cloud
    _errorSubscription = repo.watchErrors().listen((message) {
      final now = DateTime.now();
      if (message == _lastErrorMessage && now.difference(_lastErrorShownAt) < const Duration(seconds: 2)) return;
      _lastErrorMessage = message;
      _lastErrorShownAt = now;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 5)),
      );
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    repo.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await repo.refresh();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TaskMate')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: StreamBuilder<List<ToDo>>(
            stream: repo.watchData(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];

              final todos = items.where((e) => !e.completed && e.userId == 1).toList();
              final dones = items.where((e) => e.completed && e.userId == 1).toList();

              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isRefreshing) const LinearProgressIndicator(),

                      if (todos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text('Alle Aufgaben erledigt')),
                        )
                      else
                        ...List.generate(todos.length, (index) {
                          final todo = todos[index];
                          return Entry(
                            name: _label(todo),
                            isDone: false,
                            showDivider: index < todos.length - 1,
                            onChanged: (checked) => repo.toggle(todo.id, checked),
                            onDelete: () => repo.remove(todo.id),
                            onRename: (newName) => repo.rename(todo.id, newName),
                          );
                        }),

                      AddEntry(onAdd: (text) => repo.add(text)),

                      AppSpacing.lg.vSpace,

                      Row(
                        children: [
                          Checkbox(value: _showDone, onChanged: (v) => setState(() => _showDone = v ?? true)),
                          const Text('Zeige erledigte Einträge'),
                        ],
                      ),

                      if (_showDone) ...[
                        AppSpacing.lg.vSpace,
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text('Erledigte Einträge', style: Theme.of(context).textTheme.headlineMedium),
                        ),
                        if (dones.isEmpty)
                          const Text('Noch keine erledigten Aufgaben')
                        else
                          ...List.generate(dones.length, (index) {
                            final done = dones[index];
                            return Entry(
                              name: _label(done),
                              isDone: true,
                              showDivider: index < dones.length - 1,
                              onChanged: (checked) => repo.toggle(done.id, checked),
                              onDelete: () => repo.remove(done.id),
                              onRename: (newName) => repo.rename(done.id, newName),
                            );
                          }),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _label(ToDo t) => t.pending ? '${t.title}  • wird synchronisiert...' : t.title;
}
