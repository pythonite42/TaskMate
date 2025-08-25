import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
