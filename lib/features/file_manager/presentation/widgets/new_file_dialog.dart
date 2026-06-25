import 'package:flutter/material.dart';

/// Reusable dialog for "Create file" / "Create folder" / "Rename".
class NameInputDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String confirmLabel;

  const NameInputDialog({
    super.key,
    required this.title,
    this.initialValue = '',
    this.confirmLabel = 'Create',
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String initialValue = '',
    String confirmLabel = 'Create',
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => NameInputDialog(
        title: title,
        initialValue: initialValue,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  State<NameInputDialog> createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Name'),
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
