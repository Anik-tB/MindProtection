import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/ai_coach_notifier.dart';
import '../../data/models/ai_message_model.dart';

class AiCoachChatView extends ConsumerStatefulWidget {
  const AiCoachChatView({super.key});

  @override
  ConsumerState<AiCoachChatView> createState() => _AiCoachChatViewState();
}

class _AiCoachChatViewState extends ConsumerState<AiCoachChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = const [
    '🧠 Analyze My Week',
    '🧘 CBT Urge Support',
    '📵 Digital Detox Tips',
    '📊 Status Report',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    ref.read(aiCoachProvider.notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _sendQuickPrompt(String promptText) {
    HapticFeedback.mediumImpact();
    final cleanPrompt = promptText.replaceFirst(RegExp(r'^[\u2000-\u3000\u2700-\u27BF\uE000-\uF8FF\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u26FF] '), '');
    ref.read(aiCoachProvider.notifier).sendMessage(cleanPrompt);
    _scrollToBottom();
  }

  void _showApiKeyDialog() {
    final keyController = TextEditingController();
    
    SharedPreferences.getInstance().then((prefs) {
      keyController.text = prefs.getString('gemini_api_key') ?? '';
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const LiquidIconBadge(
              icon: Icons.key_rounded,
              color: AppTheme.primary,
              size: 40,
              iconSize: 18,
            ),
            const SizedBox(width: 10),
            Text('API Configuration', style: Theme.of(ctx).textTheme.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add a Gemini API Key to enable generative AI responses. If left blank, the coach runs on a high-fidelity local wellbeing engine.',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIzaSy...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = keyController.text.trim();
              final prefs = await SharedPreferences.getInstance();
              if (val.isEmpty) {
                await prefs.remove('gemini_api_key');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API Key cleared. Reverting to local wellbeing engine.'),
                      backgroundColor: AppTheme.info,
                    ),
                  );
                }
              } else {
                await prefs.setString('gemini_api_key', val);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gemini API Key saved! Generative AI active.'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                }
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiCoachProvider);

    // Auto-scroll on initial load or new messages
    ref.listen<AiCoachState>(aiCoachProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length || next.isSending) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderAccent),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Coach Space',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Your Mind & Focus Guardian',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Reset Chat & Configure Key
                    IconButton(
                      icon: const Icon(Icons.key_rounded, color: AppTheme.primary, size: 20),
                      onPressed: _showApiKeyDialog,
                      tooltip: 'Configure Gemini API Key',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.error, size: 20),
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        ref.read(aiCoachProvider.notifier).clearHistory();
                      },
                      tooltip: 'Clear Chat History',
                    ),
                  ],
                ),
              ),

              // Chat Messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  itemCount: chatState.messages.length + (chatState.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatState.messages.length) {
                      return const _TypingIndicatorBubble();
                    }

                    final message = chatState.messages[index];
                    return _MessageBubble(message: message);
                  },
                ),
              ),

              // Quick Action Chips (Only shown when not busy generating response)
              if (!chatState.isSending)
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _quickPrompts.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ChoiceChip(
                        label: Text(_quickPrompts[index]),
                        selected: false,
                        onSelected: (_) => _sendQuickPrompt(_quickPrompts[index]),
                        backgroundColor: AppTheme.surfaceRaised.withValues(alpha: 0.8),
                        labelStyle: GoogleFonts.inter(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.28)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      );
                    },
                  ),
                ),

              // Input box panel
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: LiquidGlassPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  radius: 20,
                  shadows: const [],
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Talk to your Coach...',
                            hintStyle: TextStyle(color: AppTheme.textHint.withValues(alpha: 0.65)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send Button
                      GestureDetector(
                        onTap: chatState.isSending ? null : _sendMessage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: chatState.isSending ? null : AppTheme.primaryGradient,
                            color: chatState.isSending ? AppTheme.border : null,
                            shape: BoxShape.circle,
                            boxShadow: chatState.isSending ? null : AppTheme.primaryGlow,
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: chatState.isSending ? AppTheme.textSecondary : AppTheme.onPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AiMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final leadingPadding = isUser ? 50.0 : 0.0;
    final trailingPadding = isUser ? 0.0 : 50.0;

    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(bottom: 12, left: leadingPadding, right: trailingPadding),
      child: LiquidGlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        radius: 18,
        shadows: const [],
        tint: isUser ? AppTheme.primary.withValues(alpha: 0.12) : null,
        borderColor: isUser ? AppTheme.primary.withValues(alpha: 0.32) : AppTheme.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormattedText(message.content),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person_outline_rounded : Icons.security_rounded,
                  size: 11,
                  color: isUser ? AppTheme.primary : AppTheme.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Parses text to support bold **markdown** formats inside the app without extra package
  Widget _buildFormattedText(String content) {
    final List<TextSpan> spans = [];
    final pattern = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final match in pattern.allMatches(content)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: content.substring(start, match.start),
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13, height: 1.45),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: GoogleFonts.inter(
          color: AppTheme.primaryLight.withValues(alpha: 1.0) == AppTheme.primaryLight ? AppTheme.primary : AppTheme.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          height: 1.45,
        ),
      ));
      start = match.end;
    }

    if (start < content.length) {
      spans.add(TextSpan(
        text: content.substring(start),
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13, height: 1.45),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}

class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 12, right: 100),
      child: LiquidGlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        radius: 18,
        shadows: const [],
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final double delay = index * 0.2;
                final double animValue = ((_controller.value + delay) % 1.0);
                final double opacity = animValue < 0.5 ? 0.3 + animValue : 1.3 - animValue;

                return Opacity(
                  opacity: opacity.clamp(0.2, 1.0),
                  child: Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
