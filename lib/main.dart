import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:to_do_list/spacing.dart';
import 'package:to_do_list/theme.dart';

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
  bool showDoneEntries = true;

  final GlobalKey<AnimatedListState> _todoKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _doneKey = GlobalKey<AnimatedListState>();

  List<String>? todoEntries;
  List<String>? doneEntries;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final Map? data = {
      "todo": ["Einkaufen", "Wäsche" /* "Einkaufen", "Wäsche", "Einkaufen", "Wäsche", "Einkaufen", "Wäsche" */],
      "done": [
        "Putzen",
        "Bett richten" /* "Putzen", "Bett richten", "Putzen", "Bett richten", "Putzen", "Bett richten" */,
      ],
    };

    setState(() {
      todoEntries = data?["todo"] as List<String>? ?? [];
      doneEntries = data?["done"] as List<String>? ?? [];
    });
  }

  void _moveTodoToDone(int index) {
    final item = todoEntries!.removeAt(index);

    // animate removal from TODO list
    _todoKey.currentState!.removeItem(
      index,
      (context, anim) => _animatedTile(
        name: item,
        isDone: false,
        animation: anim,
        showDivider: index < (todoEntries!.length), // was not last before remove
        onChanged: (_) {},
      ),
      duration: const Duration(milliseconds: 220),
    );

    // insert into DONE with animation (after one microtask to avoid build re-entrancy)
    Future.microtask(() {
      final insertIndex = doneEntries!.length;
      doneEntries!.add(item);
      _doneKey.currentState!.insertItem(insertIndex, duration: const Duration(milliseconds: 280));
    });
  }

  void _moveDoneToTodo(int index) {
    final item = doneEntries!.removeAt(index);

    _doneKey.currentState!.removeItem(
      index,
      (context, anim) => _animatedTile(
        name: item,
        isDone: true,
        animation: anim,
        showDivider: index < (doneEntries!.length),
        onChanged: (_) {},
      ),
      duration: const Duration(milliseconds: 220),
    );

    Future.microtask(() {
      final insertIndex = todoEntries!.length;
      todoEntries!.add(item);
      _todoKey.currentState!.insertItem(insertIndex, duration: const Duration(milliseconds: 280));
    });
  }

  // -------------------- Animated tile builder --------------------
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
    final isLoading = todoEntries == null || doneEntries == null;

    return Scaffold(
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  AppSpacing.md.vSpace,
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

                    if (todoEntries!.isEmpty)
                      const Text("Alle Aufgaben erledigt")
                    else
                      AnimatedList(
                        key: _todoKey,
                        initialItemCount: todoEntries!.length,
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index, animation) {
                          final name = todoEntries![index];
                          return _animatedTile(
                            name: name,
                            isDone: false,
                            animation: animation,
                            showDivider: index < todoEntries!.length - 1,
                            onChanged: (checked) {
                              if (checked) _moveTodoToDone(index);
                            },
                          );
                        },
                      ),

                    AppSpacing.lg.vSpace,

                    // Toggle DONE visibility
                    Row(
                      children: [
                        Checkbox(value: showDoneEntries, onChanged: (v) => setState(() => showDoneEntries = v ?? true)),
                        const Text("Zeige erledigte Einträge"),
                      ],
                    ),

                    // ---------------- DONE LIST (AnimatedList) ----------------
                    if (showDoneEntries) ...[
                      AppSpacing.lg.vSpace,
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text("Erledigte Einträge", style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      if (doneEntries!.isEmpty)
                        const Text("Noch keine erledigten Aufgaben")
                      else
                        AnimatedList(
                          key: _doneKey,
                          initialItemCount: doneEntries!.length,
                          primary: false,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index, animation) {
                            final name = doneEntries![index];
                            return _animatedTile(
                              name: name,
                              isDone: true,
                              animation: animation,
                              showDivider: index < doneEntries!.length - 1,
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

// ---------------------------------------------------------------
// EntryRow passes onChanged outward (no state here)
// ---------------------------------------------------------------
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomCheckbox(value: isDone, onChanged: (v) => onChanged(v)),
              Expanded(
                child: Text(
                  name,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDone
                        ? Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline
                        : textTheme.bodyLarge?.color,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationThickness: 1.5,
                    decorationColor: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {}, // delete etc.
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).dividerTheme.color ?? Theme.of(context).colorScheme.outlineVariant,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------
// Your CustomCheckbox (unchanged)
// ---------------------------------------------------------------
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
              color: scheme.primary.withOpacity(_hovered ? 0.45 : 0.32),
              blurRadius: _hovered ? 16 : 12,
              spreadRadius: 0.5,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            if (_hovered)
              BoxShadow(
                color: outline.withOpacity(0.35),
                blurRadius: 10,
                spreadRadius: 0.2,
                offset: const Offset(0, 1),
              ),
          ];

    final borderSide = BorderSide(color: isChecked ? Colors.transparent : outline, width: 1.5);

    final decoration = BoxDecoration(
      color: isChecked ? null : bgUnchecked,
      gradient: isChecked
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary.withOpacity(0.95), scheme.primary.withOpacity(0.80)],
            )
          : null,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: Border.fromBorderSide(borderSide),
      boxShadow: glow,
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
            highlightColor: scheme.primary.withOpacity(0.10),
            splashColor: scheme.primary.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ScaleTransition(
                scale: _controller,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: widget.size,
                  height: widget.size,
                  decoration: decoration.copyWith(
                    boxShadow: [
                      ...glow,
                      if (_focused)
                        BoxShadow(color: scheme.primary.withOpacity(0.35), blurRadius: 14, spreadRadius: 1.2),
                    ],
                  ),
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
