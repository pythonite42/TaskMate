import 'package:flutter/material.dart';
import 'package:to_do_list/spacing.dart';
import 'package:to_do_list/widgets/custom_checkbox.dart';

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
