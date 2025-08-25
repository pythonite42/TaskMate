import 'package:flutter/material.dart';
import 'package:to_do_list/spacing.dart';
import 'package:to_do_list/theme.dart';
import 'package:flutter/services.dart';

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
      "todo": ["Einkaufen", "Wäsche" /*  "Einkaufen", "Wäsche", "Einkaufen", "Wäsche", "Einkaufen", "Wäsche" */],
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
                        EntryRow(
                          name: todoEntries![i],
                          isDone: false,
                          showDivider: i < todoEntries!.length - 1,
                          onChanged: (checked) {
                            if (checked) {
                              setState(() {
                                final item = todoEntries!.removeAt(i);
                                doneEntries!.add(item);
                              });
                            }
                          },
                        ),
                    AppSpacing.md.vSpace,
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
                              EntryRow(
                                name: doneEntries![i],
                                isDone: true,
                                showDivider: i < doneEntries!.length - 1,
                                onChanged: (checked) {
                                  if (!checked) {
                                    setState(() {
                                      final item = doneEntries!.removeAt(i);
                                      todoEntries!.add(item);
                                    });
                                  }
                                },
                              ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Checkbox(value: isDone, shape: CircleBorder(), onChanged: (newValue) {}),
              CustomCheckbox(value: isDone, onChanged: onChanged),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDone ? Theme.of(context).dividerColor : Theme.of(context).textTheme.bodyLarge?.color,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationThickness: 1,
                    decorationColor: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.delete, color: Theme.of(context).dividerColor),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor),
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
  final double size; // 24–28 works great
  final double borderRadius; // rounded corner checkbox
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

    // Colors
    final outline = scheme.outlineVariant;
    final bgUnchecked = Theme.of(context).colorScheme.surface;
    final checkColor = scheme.onPrimary;

    // Subtle glow when checked / hovered
    final List<BoxShadow> glow = isChecked
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
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
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
              // Keep touch target ~48x48 while visual box is smaller
              padding: const EdgeInsets.all(10),
              child: ScaleTransition(
                scale: _controller,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: widget.size,
                  height: widget.size,
                  decoration: decoration.copyWith(
                    // subtle focus ring
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
                          : Icon(
                              Icons.check_rounded,
                              key: const ValueKey('unchecked'),
                              size: widget.size * 0.72,
                              color: Colors.transparent,
                            ),
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
