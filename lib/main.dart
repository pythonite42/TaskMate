import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_list/spacing.dart';
import 'package:to_do_list/theme.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _todoKey = GlobalKey<AnimatedListState>();
  final _doneKey = GlobalKey<AnimatedListState>();

  bool _showDone = true;
  bool _isLoading = true;

  final List<String> _todos = <String>[];
  final List<String> _dones = <String>[];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    const data = {
      'todo': ['Einkaufen', 'Wäsche', 'Einkaufen', 'Wäsche', 'Einkaufen', 'Wäsche', 'Einkaufen', 'Wäsche'],
      'done': ['Putzen', 'Bett richten', 'Putzen', 'Bett richten', 'Putzen', 'Bett richten', 'Putzen', 'Bett richten'],
    };

    setState(() {
      _todos
        ..clear()
        ..addAll(data['todo'] ?? []);
      _dones
        ..clear()
        ..addAll(data['done'] ?? []);
      _isLoading = false;
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
      ),
      duration: const Duration(milliseconds: 220),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final insertIndex = _todos.length;
      _todos.add(item);
      _todoKey.currentState!.insertItem(insertIndex, duration: const Duration(milliseconds: 280));
    });
  }

  Widget _animatedTile({
    required String name,
    required bool isDone,
    required Animation<double> animation,
    required bool showDivider,
    required ValueChanged<bool> onChanged,
  }) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: EntryRow(name: name, isDone: isDone, showDivider: showDivider, onChanged: onChanged),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text('Deine To-Do Liste', style: textTheme.headlineLarge),
              ),

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
                    );
                  },
                ),

              AppSpacing.lg.vSpace,

              Row(
                children: [
                  Checkbox(value: _showDone, onChanged: (newValue) => setState(() => _showDone = newValue ?? true)),
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
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EntryRow extends StatelessWidget {
  const EntryRow({
    super.key,
    required this.name,
    required this.isDone,
    this.showDivider = false,
    required this.onChanged,
  });

  final String name;
  final bool isDone;
  final bool showDivider;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final dividerColor = theme.dividerColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomCheckbox(value: isDone, onChanged: onChanged),
              Expanded(
                child: Text(
                  name,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDone ? dividerColor : textTheme.bodyLarge?.color,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationThickness: 1,
                    decorationColor: dividerColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.delete, color: dividerColor),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 0.5, color: dividerColor),
      ],
    );
  }
}

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
    this.borderRadius = 8,
    this.semanticLabel,
    this.enableHaptics = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final double borderRadius;
  final String? semanticLabel;
  final bool enableHaptics;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0.95,
    upperBound: 1.0,
    value: 1.0,
  );

  bool _hovered = false;
  bool _focused = false;

  void _toggle() {
    widget.onChanged(!widget.value);
    if (widget.enableHaptics) HapticFeedback.selectionClick();
    _controller.forward(from: 0.95);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isChecked = widget.value;

    final outline = scheme.outlineVariant;
    final bgUnchecked = scheme.surface;
    final checkColor = scheme.onPrimary;

    final glow = isChecked
        ? [
            BoxShadow(
              color: scheme.primary.withAlpha(_hovered ? 115 : 82),
              blurRadius: _hovered ? 16 : 12,
              spreadRadius: 0.5,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            if (_hovered)
              BoxShadow(color: outline.withAlpha(90), blurRadius: 10, spreadRadius: 0.2, offset: const Offset(0, 1)),
          ];

    final borderSide = BorderSide(color: isChecked ? Colors.transparent : outline, width: 1.5);

    final decoration = BoxDecoration(
      color: isChecked ? null : bgUnchecked,
      gradient: isChecked
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary.withAlpha(242), scheme.primary.withAlpha(204)],
            )
          : null,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: Border.fromBorderSide(borderSide),
      boxShadow: [
        ...glow,
        if (_focused) BoxShadow(color: scheme.primary.withAlpha(90), blurRadius: 14, spreadRadius: 1.2),
      ],
    );

    return FocusableActionDetector(
      onShowFocusHighlight: (f) => setState(() => _focused = f),
      onShowHoverHighlight: (h) => setState(() => _hovered = h),
      mouseCursor: SystemMouseCursors.click,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<Intent>(
          onInvoke: (intent) {
            _toggle();
            return null;
          },
        ),
      },
      child: Semantics(
        label: widget.semanticLabel ?? 'checkbox',
        checked: isChecked,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(widget.borderRadius + 4),
            splashFactory: InkRipple.splashFactory,
            highlightColor: scheme.primary.withAlpha(25),
            splashColor: scheme.primary.withAlpha(38),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ScaleTransition(
                scale: _controller,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: widget.size,
                  height: widget.size,
                  decoration: decoration,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: Tween(begin: 0.7, end: 1.0).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: isChecked
                          ? Icon(
                              Icons.check_rounded,
                              key: const ValueKey('checked'),
                              size: widget.size * 0.72,
                              color: checkColor,
                            )
                          : const SizedBox.shrink(key: ValueKey('unchecked')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
