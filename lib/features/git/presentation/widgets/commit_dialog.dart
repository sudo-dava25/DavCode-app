import 'package:flutter/material.dart';

/// Modal for entering a commit message ("Commit" requirement).
class CommitDialog extends StatefulWidget {
  const CommitDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(context: context, builder: (_) => const CommitDialog());
  }

  @override
  State<CommitDialog> createState() => _CommitDialogState();
}

class _CommitDialogState extends State<CommitDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Commit changes'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Commit message'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Commit'),
        ),
      ],
    );
  }
}
