import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../ai/domain/entities/ai_model_config.dart';
import '../../../ai/presentation/providers/ai_providers.dart';

/// "SETTINGS → AI": API key management (stored encrypted via
/// SecureStorageService) + model/provider selection.
class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final config = ref.read(aiModelConfigProvider);
    _modelController.text = config.model;
    _baseUrlController.text = config.customBaseUrl ?? '';
    _loadStoredKey();
  }

  Future<void> _loadStoredKey() async {
    final config = ref.read(aiModelConfigProvider);
    final key = config.providerType == AiProviderType.openai
        ? AppConstants.keyOpenAiApiKey
        : AppConstants.keyCustomEndpointKey;
    final stored = await SecureStorageService.instance.read(key);
    if (stored != null) _apiKeyController.text = stored;
  }

  Future<void> _saveKey() async {
    final config = ref.read(aiModelConfigProvider);
    final key = config.providerType == AiProviderType.openai
        ? AppConstants.keyOpenAiApiKey
        : AppConstants.keyCustomEndpointKey;
    await SecureStorageService.instance.write(key, _apiKeyController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key saved securely')),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(aiModelConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Provider', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<AiProviderType>(
            segments: const [
              ButtonSegment(value: AiProviderType.openai, label: Text('OpenAI')),
              ButtonSegment(value: AiProviderType.local, label: Text('Local')),
              ButtonSegment(value: AiProviderType.custom, label: Text('Custom')),
            ],
            selected: {config.providerType},
            onSelectionChanged: (selection) {
              final type = selection.first;
              final next = switch (type) {
                AiProviderType.openai => AiModelConfig.defaultOpenAi,
                AiProviderType.local => AiModelConfig.defaultLocal,
                AiProviderType.custom => config.copyWith(providerType: AiProviderType.custom),
              };
              ref.read(aiModelConfigProvider.notifier).state = next;
              _modelController.text = next.model;
              _baseUrlController.text = next.customBaseUrl ?? '';
              _loadStoredKey();
            },
          ),
          const SizedBox(height: 20),
          const Text('Model', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(hintText: 'e.g. gpt-4o-mini, llama3, mistral'),
            onChanged: (v) => ref.read(aiModelConfigProvider.notifier).state = config.copyWith(model: v),
          ),
          if (config.providerType != AiProviderType.openai) ...[
            const SizedBox(height: 20),
            const Text('Base URL', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(hintText: 'http://127.0.0.1:11434/v1'),
              onChanged: (v) =>
                  ref.read(aiModelConfigProvider.notifier).state = config.copyWith(customBaseUrl: v),
            ),
          ],
          const SizedBox(height: 20),
          const Text('API Key', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            decoration: InputDecoration(
              hintText: 'sk-…',
              suffixIcon: IconButton(
                icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Stored encrypted on-device via Android Keystore. Never sent anywhere except '
            'directly to the provider you selected above.',
            style: TextStyle(fontSize: 11.5, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _saveKey, child: const Text('Save API Key')),
        ],
      ),
    );
  }
}
