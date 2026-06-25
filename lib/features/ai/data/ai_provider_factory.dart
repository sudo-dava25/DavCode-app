import '../../../core/constants/app_constants.dart';
import '../../../core/services/secure_storage_service.dart';
import '../domain/entities/ai_model_config.dart';
import '../domain/repositories/ai_provider.dart';
import 'providers/openai_compatible_provider.dart';

/// Builds the right [AiProvider] for the user's current [AiModelConfig],
/// pulling the API key out of secure storage when one is needed.
class AiProviderFactory {
  final SecureStorageService _secureStorage;

  AiProviderFactory({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService.instance;

  Future<AiProvider> build(AiModelConfig config) async {
    switch (config.providerType) {
      case AiProviderType.openai:
        final key = await _secureStorage.read(AppConstants.keyOpenAiApiKey);
        return OpenAiCompatibleProvider(
          id: 'openai',
          displayName: 'OpenAI',
          baseUrl: 'https://api.openai.com/v1',
          defaultModel: config.model,
          apiKey: key,
        );

      case AiProviderType.local:
        // No API key required by default for most local servers
        // (Ollama/LM Studio); a key field is still supported for setups
        // that front their local server with auth.
        final key = await _secureStorage.read(AppConstants.keyCustomEndpointKey);
        return OpenAiCompatibleProvider(
          id: 'local',
          displayName: 'Local Model',
          baseUrl: config.customBaseUrl ?? AiModelConfig.defaultLocal.customBaseUrl!,
          defaultModel: config.model,
          apiKey: key,
        );

      case AiProviderType.custom:
        final key = await _secureStorage.read(AppConstants.keyCustomEndpointKey);
        return OpenAiCompatibleProvider(
          id: 'custom',
          displayName: 'Custom Endpoint',
          baseUrl: config.customBaseUrl ?? '',
          defaultModel: config.model,
          apiKey: key,
        );
    }
  }
}
