import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/savvy_colors.dart';
import 'package:savvy/features/ai_advisor/data/gemini_service.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AiAdvisorScreen extends ConsumerStatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  ConsumerState<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends ConsumerState<AiAdvisorScreen> {
  late final GeminiService _geminiService;
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  static const List<String> _quickQuestions = [
    'Bu ay nereye fazla harcadım?',
    'Tasarruf oranım nasıl?',
    '6 ay sonra ne kadar biriktirebilirim?',
    'Giderlerimi nasıl azaltabilirim?',
  ];

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    HapticFeedback.lightImpact();
    _inputController.clear();

    final summaries = ref.read(allMonthSummariesProvider);
    final context = GeminiService.buildContext(summaries);

    setState(() {
      _messages.add(_ChatMessage(
        text: trimmed,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await _geminiService.sendMessage(trimmed, context);

    setState(() {
      _isLoading = false;
      _messages.add(_ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      appBar: _buildAppBar(context, c),
      body: _geminiService.isConfigured
          ? _buildChatBody(context, c)
          : _buildUnconfiguredBody(context, c),
    );
  }

  AppBar _buildAppBar(BuildContext context, SavvyColors c) {
    return AppBar(
      backgroundColor: c.surfaceCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(LucideIcons.arrowLeft, size: 20, color: c.textPrimary),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A56DB), Color(0xFF7E3AF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.chip,
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'AI Danışman',
            style: AppTypography.headlineSmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: c.borderDefault.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ─── Unconfigured State ──────────────────────────────────────────────────────

  Widget _buildUnconfiguredBody(BuildContext context, SavvyColors c) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenH,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: AppRadius.cardLg,
            border: Border.all(
              color: c.borderDefault.withValues(alpha: 0.3),
            ),
            boxShadow: AppShadow.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.brandPrimary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.card,
                ),
                child: Icon(
                  LucideIcons.key,
                  size: 28,
                  color: c.brandPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Gemini API anahtarı gerekli',
                style: AppTypography.headlineSmall.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'AI danışmanını kullanmak için Gemini API anahtarı gereklidir.',
                style: AppTypography.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: c.surfaceBackground,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: c.borderDefault.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nasıl etkinleştirilir:',
                      style: AppTypography.labelLarge.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SelectableText(
                      'flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY',
                      style: AppTypography.bodySmall.copyWith(
                        color: c.brandPrimary,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Chat Body ───────────────────────────────────────────────────────────────

  Widget _buildChatBody(BuildContext context, SavvyColors c) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState(context, c)
              : _buildMessageList(context, c),
        ),
        _buildInputBar(context, c),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, SavvyColors c) {
    return SingleChildScrollView(
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF7E3AF2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.card,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A56DB).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Center(
            child: Text(
              'Finansal Danışmanınız',
              style: AppTypography.headlineSmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              'Finansal verilerinizi analiz ederek\nkişisel tavsiyeler verebilirim.',
              style: AppTypography.bodyMedium.copyWith(
                color: c.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl2),
          Text(
            'Hızlı Sorular',
            style: AppTypography.titleSmall.copyWith(
              color: c.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _quickQuestions.map((q) => _QuickChip(
              label: q,
              onTap: () => _sendMessage(q),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, SavvyColors c) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.base,
      ),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _TypingIndicator(c: c);
        }
        final msg = _messages[index];
        return _MessageBubble(message: msg, c: c);
      },
    );
  }

  Widget _buildInputBar(BuildContext context, SavvyColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        border: Border(
          top: BorderSide(
            color: c.borderDefault.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: AppShadow.overlay,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: c.surfaceBackground,
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: c.borderDefault.withValues(alpha: 0.4),
                ),
              ),
              child: TextField(
                controller: _inputController,
                enabled: !_isLoading,
                style: AppTypography.bodyMedium.copyWith(
                  color: c.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Bir soru sorun...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: c.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md,
                  ),
                ),
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
                maxLines: null,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _SendButton(
            isLoading: _isLoading,
            onTap: () => _sendMessage(_inputController.text),
            c: c,
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final SavvyColors c;

  const _MessageBubble({required this.message, required this.c});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF7E3AF2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.chip,
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? c.brandPrimary
                    : c.surfaceCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isUser ? AppRadius.lg : AppRadius.xs),
                  bottomRight: Radius.circular(isUser ? AppRadius.xs : AppRadius.lg),
                ),
                boxShadow: AppShadow.xs,
                border: isUser
                    ? null
                    : Border.all(
                        color: c.borderDefault.withValues(alpha: 0.3),
                      ),
              ),
              child: SelectableText(
                message.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: isUser ? Colors.white : c.textPrimary,
                  height: 1.55,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: AppSpacing.xl2),
          if (!isUser) const SizedBox(width: AppSpacing.xl2),
        ],
      ),
    );
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  final SavvyColors c;

  const _TypingIndicator({required this.c});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true),
    );
    _animations = List.generate(
      3,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controllers[i],
          curve: Curves.easeInOut,
        ),
      ),
    );
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A56DB), Color(0xFF7E3AF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.chip,
            ),
            child: const Icon(
              LucideIcons.sparkles,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: widget.c.surfaceCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(AppRadius.xs),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
              boxShadow: AppShadow.xs,
              border: Border.all(
                color: widget.c.borderDefault.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (context, _) {
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      child: Transform.translate(
                        offset: Offset(0, -4 * _animations[i].value),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.c.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Chip ───────────────────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: c.brandPrimary.withValues(alpha: 0.07),
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: c.brandPrimary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: c.brandPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Send Button ──────────────────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final SavvyColors c;

  const _SendButton({
    required this.isLoading,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isLoading ? c.surfaceBackground : null,
          borderRadius: AppRadius.chip,
          boxShadow: isLoading ? null : AppShadow.sm,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.brandPrimary,
                  ),
                ),
              )
            : const Icon(
                LucideIcons.send,
                size: 18,
                color: Colors.white,
              ),
      ),
    );
  }
}
