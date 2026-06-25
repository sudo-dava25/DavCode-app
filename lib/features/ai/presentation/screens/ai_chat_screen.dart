import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/ai_model_config.dart';
import '../providers/ai_providers.dart';
import '../widgets/chat_bubble.dart';

/// "AI CODING ASSISTANT" → "AI chat": a free-form chat with whichever
/// provider (OpenAI / local model / custom endpoint) is currently active.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(aiChatProvider.notifier).send(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);
    final chatNotifier = ref.read(aiChatProvider.notifier);
    final config = ref.watch(aiModelConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        leading: Responsive.isDesktop(context)
            ? null
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => ref.read(homeScaffoldKeyProvider).currentState?.openDrawer(),
              ),
        actions: [
          PopupMenuButton<AiProviderType>(
            tooltip: 'Model',
            icon: const Icon(Icons.smart_toy_outlined),
            onSelected: (type) {
              final next = switch (type) {
                AiProviderType.openai => AiModelConfig.defaultOpenAi,
                AiProviderType.local => AiModelConfig.defaultLocal,
                AiProviderType.custom => config.copyWith(providerType: AiProviderType.custom),
              };
              ref.read(aiModelConfigProvider.notifier).state = next;
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: AiProviderType.openai, child: Text('OpenAI')),
              PopupMenuItem(value: AiProviderType.local, child: Text('Local Model')),
              PopupMenuItem(value: AiProviderType.custom, child: Text('Custom Endpoint')),
            ],
          ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: chatNotifier.clear),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Provider: ${config.providerType.name} · Model: ${config.model}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Ask me anything about your code',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => ChatBubble(message: messages[index]),
                  ),
          ),
          if (chatNotifier.isSending)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (chatNotifier.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(chatNotifier.error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ),
          SafeArea(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: 'Message the AI assistant…'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
