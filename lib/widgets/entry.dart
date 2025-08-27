import 'package:flutter/material.dart';
import 'package:task_mate/global_settings/spacing.dart';
import 'package:task_mate/widgets/custom_checkbox.dart';

class Entry extends StatefulWidget {
  const Entry({
    super.key,
    required this.name,
    required this.isDone,
    required this.isPending,
    this.showDivider = false,
    required this.onChanged,
    required this.onDelete,
    required this.onRename,
  });

  final String name;
  final bool isDone;
  final bool isPending;
  final bool showDivider;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;
  final ValueChanged<String> onRename;

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  bool _editing = false;
  late final TextEditingController _controller = TextEditingController(text: widget.name);
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _controller.text = widget.name; // refresh if parent changed it
    });
    // autofocus after frame to avoid focus issues in lists
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _cancelEditing() {
    setState(() => _editing = false);
    _focusNode.unfocus();
  }

  void _saveEditing() {
    final value = _controller.text.trim();
    if (value.isEmpty || value == widget.name) {
      _cancelEditing();
      return;
    }
    widget.onRename(value);
    setState(() => _editing = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final dividerColor = theme.dividerTheme.color;

    final textStyle = textTheme.bodyLarge?.copyWith(
      color: widget.isDone ? dividerColor : textTheme.bodyLarge?.color,
      decoration: widget.isDone && !_editing ? TextDecoration.lineThrough : null,
      decorationThickness: 1,
      decorationColor: dividerColor,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomCheckbox(value: widget.isDone, onChanged: widget.onChanged),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isPending) ...[
                      Text("Wird synchronisiert...", style: theme.textTheme.labelSmall),
                      AppSpacing.xs.vSpace,
                    ],
                    _editing
                        ? TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: _saveEditing,
                            onSubmitted: (_) => _saveEditing(),
                            style: textStyle,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          )
                        : GestureDetector(
                            onTap: _startEditing,
                            onLongPress: _startEditing,
                            child: Text(widget.name, style: textStyle),
                          ),
                  ],
                ),
              ),

              if (_editing) ...[
                IconButton(
                  tooltip: 'Speichern',
                  onPressed: _saveEditing,
                  icon: const Icon(Icons.check_rounded),
                  color: theme.colorScheme.primary,
                ),
                IconButton(
                  tooltip: 'Abbrechen',
                  onPressed: _cancelEditing,
                  icon: const Icon(Icons.close_rounded),
                  color: dividerColor,
                ),
              ] else
                IconButton(
                  tooltip: 'Löschen',
                  onPressed: widget.onDelete,
                  icon: Icon(Icons.delete, color: dividerColor),
                ),
            ],
          ),
        ),
        if (widget.showDivider) Divider(),
      ],
    );
  }
}
