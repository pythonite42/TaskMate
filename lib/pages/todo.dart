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

  @override
  void initState() {
    super.initState();
    repo.bootstrap(); // loads local immediately, then tries cloud
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
            stream: repo.watch(),
            builder: (context, snap) {
              final items = snap.data ?? [];

              final todos = items.where((e) => !e.completed && e.userId == 9).toList();
              final dones = items.where((e) => e.completed && e.userId == 9).toList();

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
                          final t = todos[index];
                          return Entry(
                            name: _label(t),
                            isDone: false,
                            showDivider: index < todos.length - 1,
                            onChanged: (checked) => repo.toggle(t.id, checked),
                            onDelete: () => repo.remove(t.id),
                            onRename: (newName) => repo.rename(t.id, newName),
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
                            final t = dones[index];
                            return Entry(
                              name: _label(t),
                              isDone: true,
                              showDivider: index < dones.length - 1,
                              onChanged: (checked) => repo.toggle(t.id, checked),
                              onDelete: () => repo.remove(t.id),
                              onRename: (newName) => repo.rename(t.id, newName),
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

  String _label(ToDo t) => t.pending ? '${t.title}  • syncing…' : t.title;
}
