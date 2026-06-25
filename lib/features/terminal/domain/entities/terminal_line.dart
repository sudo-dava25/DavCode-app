enum TerminalLineType { input, stdout, stderr, system }

class TerminalLine {
  final String text;
  final TerminalLineType type;
  final DateTime timestamp;

  TerminalLine({required this.text, required this.type, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}
