import 'package:flutter/material.dart';
import 'package:task_mate/global_settings/spacing.dart';
import 'package:task_mate/widgets/add_entry.dart';
import 'package:task_mate/widgets/entry.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum DataSource { api, local }

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  GlobalKey<AnimatedListState> _todoKey = GlobalKey<AnimatedListState>();
  GlobalKey<AnimatedListState> _doneKey = GlobalKey<AnimatedListState>();

  bool _showDone = true;
  bool _isLoading = true;
  bool _hasError = false;

  final List<String> _todos = <String>[];
  final List<String> _dones = <String>[];

  DataSource _source = DataSource.api;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      //_isLoading is not set to true to avoid the loading screen on pull to refresh
      _hasError = false;
    });
    //await Future<void>.delayed(const Duration(seconds: 2));

    try {
      if (_source == DataSource.api) {
        await _loadEntriesFromApi();
      } else {
        await _loadEntriesFromLocal();
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEntriesFromApi() async {
    final url = Uri.parse(
      dotenv.env['DATA_URL'] ?? "",
    ); //The URL for the endpoint should not be hardcoded and then pushed to git. For this to work there needs to be a file called .env at the root of the project, with this content: DATA_URL=https://myPlaceholder.com
    final response = await http.get(url, headers: {'Accept': 'application/json', 'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Failed with status: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as List;
    _applyDecoded(decoded);
  }

  Future<void> _loadEntriesFromLocal() async {
    final decoded = [
      {"title": "Milch kaufen", "completed": false, "userId": 9},
      {"title": "Staubsaugen", "completed": true, "userId": 9},
      {"title": "Anderer User", "completed": false, "userId": 1},
    ];

    _applyDecoded(decoded);
  }

  void _applyDecoded(List decoded) {
    final todos = <String>[];
    final dones = <String>[];

    for (final entry in decoded) {
      if (entry["userId"] == 9) {
        (entry['completed'] ? dones : todos).add(entry['title']);
      }
    }

    setState(() {
      _todoKey = GlobalKey<AnimatedListState>();
      _doneKey = GlobalKey<AnimatedListState>();
      _todos
        ..clear()
        ..addAll(todos);
      _dones
        ..clear()
        ..addAll(dones);
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMate'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SegmentedButton<DataSource>(
              segments: const [
                ButtonSegment(value: DataSource.api, label: Text('Cloud Daten'), icon: Icon(Icons.cloud_outlined)),
                ButtonSegment(value: DataSource.local, label: Text('Lokale Daten'), icon: Icon(Icons.storage_outlined)),
              ],
              selected: {_source},
              onSelectionChanged: (sel) {
                setState(() => _source = sel.first);
                _loadEntries();
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _isLoading
              ? _buildLoading(context)
              : _hasError
              ? _buildError(context)
              : _buildSuccess(context),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [CircularProgressIndicator(), AppSpacing.md.vSpace, const Text('Einen Moment ...')],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Die Daten konnten nicht geladen werden'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _loadEntries();
            },
            child: const Text('Neu Laden'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _loadEntries,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
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
            AppSpacing.lg.vSpace,
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

            if (_showDone) ...[
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
    );
  }
}
