enum AiProviderType { openai, local, custom }

/// User-configurable AI settings ("API key management" / "Model
/// selection" requirements). The API key itself is NOT stored here — it
/// lives in SecureStorageService — this class only holds non-sensitive
/// configuration.
class AiModelConfig {
  final AiProviderType providerType;
  final String model;
  final String? customBaseUrl;

  const AiModelConfig({
    required this.providerType,
    required this.model,
    this.customBaseUrl,
  });

  static const defaultOpenAi = AiModelConfig(providerType: AiProviderType.openai, model: 'gpt-4o-mini');
  static const defaultLocal = AiModelConfig(
    providerType: AiProviderType.local,
    model: 'llama3',
    customBaseUrl: 'http://127.0.0.1:11434/v1',
  );

  AiModelConfig copyWith({AiProviderType? providerType, String? model, String? customBaseUrl}) {
    return AiModelConfig(
      providerType: providerType ?? this.providerType,
      model: model ?? this.model,
      customBaseUrl: customBaseUrl ?? this.customBaseUrl,
    );
  }
}
