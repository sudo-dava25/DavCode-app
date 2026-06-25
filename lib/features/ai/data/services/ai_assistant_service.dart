import '../../domain/entities/ai_message.dart';
import '../../domain/repositories/ai_provider.dart';

/// Turns the high-level "AI CODING ASSISTANT" features (autocomplete,
/// explain, generate, find bugs, refactor) into well-shaped prompts sent
/// through whichever [AiProvider] is currently active — keeping prompt
/// engineering in one place instead of scattered across UI widgets.
class AiAssistantService {
  final AiProvider provider;

  AiAssistantService(this.provider);

  Future<String> explainCode(String code, {String language = ''}) {
    return provider.chat([
      AiMessage(
        role: AiRole.system,
        content: 'You are a concise senior software engineer explaining code to a mobile developer. '
            'Explain clearly, point out non-obvious behavior, and keep it focused.',
      ),
      AiMessage(role: AiRole.user, content: 'Explain this $language code:\n\n```$language\n$code\n```'),
    ]);
  }

  Future<String> generateCode(String instruction, {String language = ''}) {
    return provider.chat([
      AiMessage(
        role: AiRole.system,
        content: 'You are a code generation assistant. Respond with idiomatic, working $language code '
            'in a single code block, with minimal extra commentary.',
      ),
      AiMessage(role: AiRole.user, content: instruction),
    ]);
  }

  Future<String> findBugs(String code, {String language = ''}) {
    return provider.chat([
      AiMessage(
        role: AiRole.system,
        content: 'You are a meticulous code reviewer. List concrete bugs, edge cases, and risky '
            'assumptions in the given $language code. Be specific about line/section.',
      ),
      AiMessage(role: AiRole.user, content: '```$language\n$code\n```'),
    ]);
  }

  Future<String> refactorCode(String code, {String language = '', String? goal}) {
    return provider.chat([
      AiMessage(
        role: AiRole.system,
        content: 'You are a refactoring assistant. Improve readability, structure, and performance '
            'of the given $language code without changing its behavior. '
            'Return the refactored code in a single code block, followed by a short bullet list of '
            'what changed.',
      ),
      AiMessage(
        role: AiRole.user,
        content: '${goal != null ? "Goal: $goal\n\n" : ""}```$language\n$code\n```',
      ),
    ]);
  }

  /// Lightweight inline completion: given the text immediately before the
  /// cursor, suggest a short continuation ("AI autocomplete" / "Code
  /// suggestion"). Kept deliberately short (low max-effort prompt) since
  /// this is meant to run frequently while typing.
  Future<String> autocomplete(String precedingCode, {String language = ''}) {
    return provider.chat([
      AiMessage(
        role: AiRole.system,
        content: 'Complete the following $language code. Respond with ONLY the continuation '
            '(no explanation, no repeating the input, no markdown fences), limited to a few lines.',
      ),
      AiMessage(role: AiRole.user, content: precedingCode),
    ]);
  }

  Future<String> chat(List<AiMessage> conversation) => provider.chat(conversation);
}
