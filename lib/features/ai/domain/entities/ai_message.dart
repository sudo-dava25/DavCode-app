enum AiRole { system, user, assistant }

/// One message in an AI chat conversation ("AI chat" requirement) and the
/// unit fed to every AiProvider implementation.
class AiMessage {
  final AiRole role;
  final String content;
  final DateTime timestamp;

  AiMessage({required this.role, required this.content, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  Map<String, String> toJson() => {'role': role.name, 'content': content};
}
