import 'package:flutter/material.dart';
import 'package:to_do_list/global_settings/spacing.dart';
import 'package:to_do_list/widgets/add_entry.dart';
import 'package:to_do_list/widgets/entry.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final _todoKey = GlobalKey<AnimatedListState>();
  final _doneKey = GlobalKey<AnimatedListState>();

  bool _showDone = true;
  bool _isLoading = true;
  bool _hasError = false;

  final List<String> _todos = <String>[];
  final List<String> _dones = <String>[];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    //await Future<void>.delayed(const Duration(seconds: 2));

    final url = Uri.parse(
      dotenv.env['DATA_URL'] ?? "",
    ); //The URL for the endpoint should not be hardcoded and then pushed to git. For this to work there needs to be a file called .env at the root of the project, with this content: DATA_URL=https://myPlaceholder.com

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json', 'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List;
        final todos = <String>[];
        final dones = <String>[];

        for (final entry in decoded) {
            (entry['completed'] ? dones : todos).add(entry['title']);
        }
        setState(() {
          _todos
            ..clear()
            ..addAll(todos);
          _dones
            ..clear()
            ..addAll(dones);
          _isLoading = false;
          _hasError = false;
        });
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _moveTodoToDone(int index) {
    final item = _todos.removeAt(index);

    _todoKey.currentState!.removeItem(
      index,
      (context, anim) => _animatedTile(
        name: item,
        isDone: false,
        animation: anim,
        showDivider: index < _todos.length,
        onChanged: (_) {},
        onDelete: () {},
        onRename: (_) {},
      ),
      duration: const Duration(milliseconds: 220),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final insertIndex = _dones.length;
      _dones.add(item);
      _doneKey.currentState!.insertItem(insertIndex, duration: const Duration(milliseconds: 280));
    });
  }

  void _moveDoneToTodo(int index) {
    final item = _dones.removeAt(index);

    _doneKey.currentState!.removeItem(
      index,
      (context, anim) => _animatedTile(
        name: item,
        isDone: true,
        animation: anim,
        showDivider: index < _dones.length,
        onChanged: (_) {},
        onDelete: () {},
        onRename: (_) {},
      ),
      duration: const Duration(milliseconds: 220),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final insertIndex = _todos.length;
      _todos.add(item);
      _todoKey.currentState!.insertItem(insertIndex, duration: const Duration(milliseconds: 280));
    });
  }

  void _removeTodo(int index) {
    final removed = _todos.removeAt(index);
    _todoKey.currentState!.removeItem(
      index,
      (context, anim) => _animatedTile(
        name: removed,
        isDone: false,
        animation: anim,
        showDivider: index < _todos.length,
        onChanged: (_) {},
        onDelete: () {},
        onRename: (_) {},
      ),
      duration: const Duration(milliseconds: 220),
    );
    setState(() {});
  }

  void _removeDone(int index) {
    final removed = _dones.removeAt(index);
    _doneKey.currentState!.removeItem(
      index,
      (context, anim) => _animatedTile(
        name: removed,
        isDone: true,
        animation: anim,
        showDivider: index < _dones.length,
        onChanged: (_) {},
        onDelete: () {},
        onRename: (_) {},
      ),
      duration: const Duration(milliseconds: 220),
    );
    setState(() {});
  }

  Widget _animatedTile({
    required String name,
    required bool isDone,
    required Animation<double> animation,
    required bool showDivider,
    required ValueChanged<bool> onChanged,
    required VoidCallback onDelete,
    required ValueChanged<String> onRename,
  }) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: Entry(
          name: name,
          isDone: isDone,
          showDivider: showDivider,
          onChanged: onChanged,
          onDelete: onDelete,
          onRename: onRename,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              AppSpacing.md.vSpace,
              const Text('Einen Moment ...'),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text('Deine To-Do Liste', style: textTheme.headlineLarge),
              ),

              if (_hasError)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Die Daten konnten nicht geladen werden'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: ElevatedButton(onPressed: _loadEntries, child: const Text("Neu Laden")),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_todos.isEmpty)
                          const Text('Alle Aufgaben erledigt')
                        else
                          AnimatedList(
                            key: _todoKey,
                            initialItemCount: _todos.length,
                            primary: false,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index, animation) {
                              final name = _todos[index];
                              return _animatedTile(
                                name: name,
                                isDone: false,
                                animation: animation,
                                showDivider: index < _todos.length - 1,
                                onChanged: (checked) {
                                  if (checked) _moveTodoToDone(index);
                                },
                                onDelete: () => _removeTodo(index),
                                onRename: (newName) {
                                  setState(() => _todos[index] = newName);
                                },
                              );
                            },
                          ),
                        AddEntry(
                          onAdd: (text) {
                            final insertIndex = _todos.length;
                            _todos.add(text);
                            _todoKey.currentState!.insertItem(insertIndex, duration: const Duration(milliseconds: 280));
                            setState(() {});
                          },
                        ),
                        AppSpacing.lg.vSpace,

                        Row(
                          children: [
                                              Checkbox(
                    value: _showDone,
                    //TODO fillColor: WidgetStateProperty.all(theme.colorScheme.surface),
                    onChanged: (newValue) => setState(() => _showDone = newValue ?? true),
),
                            const Text('Zeige erledigte Einträge'),
                          ],
                  ),

                        if (_showDone) ...[
                          AppSpacing.lg.vSpace,
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text('Erledigte Einträge', style: textTheme.headlineMedium),
                          ),
                          if (_dones.isEmpty)
                            const Text('Noch keine erledigten Aufgaben')
                          else
                            AnimatedList(
                              key: _doneKey,
                              initialItemCount: _dones.length,
                              primary: false,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index, animation) {
                                final name = _dones[index];
                                return _animatedTile(
                                  name: name,
                                  isDone: true,
                                  animation: animation,
                                  showDivider: index < _dones.length - 1,
                                  onChanged: (checked) {
                                    if (!checked) _moveDoneToTodo(index);
                                  },
                                  onDelete: () => _removeDone(index),
                                  onRename: (newName) {
                                    setState(() => _dones[index] = newName);
                                  },
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
