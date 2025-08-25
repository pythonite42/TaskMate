import 'package:flutter/material.dart';
import 'package:to_do_list/global_settings/spacing.dart';

class AddEntry extends StatefulWidget {
  const AddEntry({super.key, required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<AddEntry> createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Neue Aufgabe hinzufügen…', border: InputBorder.none),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
