import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AiTutorChat extends StatefulWidget {
  final String level;
  final String lessonTopic;

  const AiTutorChat({
    super.key,
    required this.level,
    required this.lessonTopic,
  });

  @override
  State<AiTutorChat> createState() => _AiTutorChatState();
}

class _AiTutorChatState extends State<AiTutorChat> {
  final List<Map<String, String>> _messages = [];
  final _controller = TextEditingController();
  bool _isTyping = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'content': "Hi! I'm Lex, your AI Tutor. I'm here to guide you through this lesson on '${widget.lessonTopic}'. I won't give you the answers directly, but I'll point you in the right direction so you can learn for yourself! How can I help?",
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'ai-tutor-chat',
        body: {
          'level': widget.level,
          'lessonTopic': widget.lessonTopic,
          'messages': _messages,
        },
      );

      final reply = response.data['reply'];

      setState(() {
        _messages.add({'role': 'assistant', 'content': reply});
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final m = _messages[index];
              final isMe = m['role'] == 'user';

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : AppColors.surfaceWarm,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                    ),
                  ),
                  child: Text(
                    m['content']!,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isTyping)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Lex is typing...", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppColors.textTertiary)),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask anything...",
                    filled: true,
                    fillColor: AppColors.surfaceWarm,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
