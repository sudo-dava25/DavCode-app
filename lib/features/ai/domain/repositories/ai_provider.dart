import '../entities/ai_message.dart';

/// "Buat sistem AI provider abstraction" — every backend (OpenAI, a local
/// model server, or any custom endpoint) implements this one interface,
/// so the AI assistant feature never depends on a specific vendor's API
/// shape directly.
abstract class AiProvider {
  String get id;
  String get displayName;

  /// Sends the full conversation and returns the assistant's reply.
  /// Implementations should throw [AiProviderException] with a clear,
  /// user-facing message on failure (missing key, network error, etc).
  Future<String> chat(List<AiMessage> messages, {String? model});
}

class AiProviderException implements Exception {
  final String message;
  AiProviderException(this.message);
  @override
  String toString() => message;
}
