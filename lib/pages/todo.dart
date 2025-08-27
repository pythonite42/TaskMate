import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/data/todo_model.dart';
import 'package:task_mate/data/todo_repository.dart';
import 'package:task_mate/data/user.dart';
import 'package:task_mate/global_settings/spacing.dart';
import 'package:task_mate/widgets/add_entry.dart';
import 'package:task_mate/widgets/custom_checkbox.dart';
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
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = mockUsers.last; // default to last so it is never empty
    _restoreUser().then((_) => repo.loadData()); // loads local immediately, then tries cloud
    _errorSubscription = repo.watchErrors().listen((message) {
      final now = DateTime.now();
      if (message == _lastErrorMessage && now.difference(_lastErrorShownAt) < const Duration(seconds: 2)) return;
      _lastErrorMessage = message;
      _lastErrorShownAt = now;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    repo.dispose();
    super.dispose();
  }

  Future<void> _restoreUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("current_user_id");
    if (id != null) {
      final foundUser = mockUsers.firstWhere((user) => user.id == id, orElse: () => _currentUser);
      setState(() => _currentUser = foundUser);
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("current_user_id", user.id);
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await repo.refresh();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: const Text('TaskMate'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _showUserSwitcher,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text(
                      _currentUser.initials,
                      style: TextStyle(fontSize: 16, color: theme.colorScheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: StreamBuilder<List<ToDo>>(
            stream: repo.watchData(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];

              final todos = items.where((entry) => !entry.completed && entry.userId == _currentUser.id).toList();
              final dones = items.where((entry) => entry.completed && entry.userId == _currentUser.id).toList();

              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isRefreshing) const LinearProgressIndicator(),
                      Row(
                        children: [
                          CustomCheckbox(
                            value: _showDone,
                            size: 20,
                            onChanged: (newValue) => setState(() => _showDone = newValue),
                          ),
                          const Text('Zeige erledigte Einträge'),
                        ],
                      ),
                      AppSpacing.sm.vSpace,

                      AddEntry(onAdd: (text) => repo.add(text, _currentUser.id)),

                      if (todos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text('Alle Aufgaben erledigt')),
                        )
                      else
                        ...List.generate(todos.length, (index) {
                          final todo = todos[index];
                          return Entry(
                            name: todo.title,
                            isDone: false,
                            isPending: todo.pending,
                            showDivider: index < todos.length - 1,
                            onChanged: (checked) => repo.toggle(todo.id, checked),
                            onDelete: () => repo.remove(todo.id),
                            onRename: (newName) => repo.rename(todo.id, newName),
                          );
                        }),

                      if (_showDone) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
                          child: Text('Erledigte Einträge', style: theme.textTheme.headlineMedium),
                        ),
                        if (dones.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            child: Center(child: const Text('Noch keine erledigten Aufgaben')),
                          )
                        else
                          ...List.generate(dones.length, (index) {
                            final done = dones[index];
                            return Entry(
                              name: done.title,
                              isDone: true,
                              isPending: done.pending,
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

  void _showUserSwitcher() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: mockUsers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final user = mockUsers[i];
            final selected = user.id == _currentUser.id;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(user.initials, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              ),
              title: Text(user.name),
              subtitle: Text('User-ID: ${user.id}'),
              trailing: selected ? const Icon(Icons.check_rounded) : null,
              onTap: () async {
                Navigator.pop(context);
                if (!selected) {
                  setState(() {
                    _currentUser = user;
                  });
                  await _saveUser(user);
                  await _refresh();
                }
              },
            );
          },
        );
      },
    );
  }
}
