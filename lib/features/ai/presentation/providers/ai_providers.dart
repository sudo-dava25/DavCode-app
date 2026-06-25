import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ai_provider_factory.dart';
import '../../data/services/ai_assistant_service.dart';
import '../../domain/entities/ai_message.dart';
import '../../domain/entities/ai_model_config.dart';

final aiProviderFactoryProvider = Provider<AiProviderFactory>((ref) => AiProviderFactory());

/// The user's currently selected AI provider/model ("Model selection").
final aiModelConfigProvider = StateProvider<AiModelConfig>((ref) => AiModelConfig.defaultOpenAi);

/// AI chat conversation state + send action ("AI chat" requirement).
class AiChatNotifier extends StateNotifier<List<AiMessage>> {
  AiChatNotifier(this._ref) : super([]);

  final Ref _ref;
  bool isSending = false;
  String? error;

  Future<void> send(String userText) async {
    state = [...state, AiMessage(role: AiRole.user, content: userText)];
    isSending = true;
    error = null;
    state = [...state];

    try {
      final config = _ref.read(aiModelConfigProvider);
      final provider = await _ref.read(aiProviderFactoryProvider).build(config);
      final service = AiAssistantService(provider);
      final reply = await service.chat(state);
      state = [...state, AiMessage(role: AiRole.assistant, content: reply)];
    } catch (e) {
      error = e.toString();
    } finally {
      isSending = false;
      state = [...state];
    }
  }

  void clear() {
    state = [];
    error = null;
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, List<AiMessage>>((ref) {
  return AiChatNotifier(ref);
});

/// One-shot helper for the editor's quick actions (Explain / Generate /
/// Find bugs / Refactor) — returns the AI's response directly without
/// touching the persistent chat history above.
final aiQuickActionProvider = Provider<Future<String> Function({
  required String action,
  required String code,
  required String language,
})>((ref) {
  return ({required action, required code, required language}) async {
    final config = ref.read(aiModelConfigProvider);
    final provider = await ref.read(aiProviderFactoryProvider).build(config);
    final service = AiAssistantService(provider);
    switch (action) {
      case 'explain':
        return service.explainCode(code, language: language);
      case 'generate':
        return service.generateCode(code, language: language);
      case 'findBugs':
        return service.findBugs(code, language: language);
      case 'refactor':
        return service.refactorCode(code, language: language);
      default:
        throw ArgumentError('Unknown AI quick action: $action');
    }
  };
});
