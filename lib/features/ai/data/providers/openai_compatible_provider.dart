import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/ai_message.dart';
import '../../domain/repositories/ai_provider.dart';

/// Base class for any backend that speaks the OpenAI Chat Completions
/// wire format (`POST {baseUrl}/chat/completions`). OpenAI itself, most
/// local model servers (Ollama, LM Studio, vLLM, text-generation-webui),
/// and most "custom endpoint" deployments all speak this same shape —
/// which is exactly why this one class backs three different providers.
class OpenAiCompatibleProvider implements AiProvider {
  final String baseUrl;
  final String? apiKey;
  final String defaultModel;
  @override
  final String id;
  @override
  final String displayName;

  OpenAiCompatibleProvider({
    required this.id,
    required this.displayName,
    required this.baseUrl,
    required this.defaultModel,
    this.apiKey,
  });

  @override
  Future<String> chat(List<AiMessage> messages, {String? model}) async {
    final uri = Uri.parse('$baseUrl/chat/completions');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (apiKey != null && apiKey!.isNotEmpty) 'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': model ?? defaultModel,
              'messages': messages.map((m) => m.toJson()).toList(),
              'temperature': 0.3,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw AiProviderException(
          '$displayName returned ${response.statusCode}: ${_shortBody(response.body)}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw AiProviderException('$displayName returned no choices.');
      }
      final content = choices.first['message']?['content'] as String?;
      return content?.trim() ?? '';
    } on AiProviderException {
      rethrow;
    } catch (e) {
      throw AiProviderException('Could not reach $displayName at $baseUrl: $e');
    }
  }

  String _shortBody(String body) => body.length > 200 ? '${body.substring(0, 200)}…' : body;
}
