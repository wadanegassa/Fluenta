import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/community_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  final bool isGroup;

  const ChatScreen({super.key, required this.roomId, this.isGroup = true});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    ref.read(chatProvider(ChatParam(id: widget.roomId, isGroup: widget.isGroup)).notifier).sendMessage(text);
    _messageController.clear();
    
    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatParam = ChatParam(id: widget.roomId, isGroup: widget.isGroup);
    final chatState = ref.watch(chatProvider(chatParam));
    
    // Extract room name from cached roomsProvider list (Group Chat)
    final roomsAsync = ref.watch(roomsProvider);
    final room = widget.isGroup
        ? roomsAsync.whenOrNull(
            data: (list) {
              try {
                return list.firstWhere((r) => r.id == widget.roomId);
              } catch (_) {
                return null;
              }
            },
          )
        : null;

    // Extract student profile from usersProvider list (Direct Message)
    final usersAsync = ref.watch(usersProvider);
    final peerUser = !widget.isGroup
        ? usersAsync.whenOrNull(
            data: (list) {
              try {
                return list.firstWhere((u) => u.id == widget.roomId);
              } catch (_) {
                return null;
              }
            },
          )
        : null;

    // Auto-scroll down on initial load or new message arrivals
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && chatState.messages.isNotEmpty) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppColors.primary),
        title: Row(
          children: [
            if (widget.isGroup) ...[
              if (room != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Text(room.icon ?? '💬', style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room?.name ?? "Group Chat",
                      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (room != null)
                      Text(
                        room.description ?? "Active study community",
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ] else ...[
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySurface,
                backgroundImage: peerUser?.avatarUrl != null
                    ? NetworkImage(peerUser!.avatarUrl!)
                    : null,
                child: peerUser?.avatarUrl == null
                    ? Text(
                        (peerUser?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      peerUser?.fullName ?? "Private Chat",
                      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Level: ${peerUser?.level.toUpperCase() ?? '...'}",
                      style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(chatState.messages),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isGroup ? Icons.forum_outlined : Icons.chat_bubble_outline,
              size: 56,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isGroup ? "No messages yet" : "Start your conversation",
              style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isGroup
                  ? "Be the first one to say hello to the group!"
                  : "Say hello! Share experiences, learn together, and succeed.",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<dynamic> messages) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.s20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final bool isMe = msg.senderId == currentUserId;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primarySurface,
                    backgroundImage: msg.senderAvatarUrl != null
                        ? NetworkImage(msg.senderAvatarUrl!)
                        : null,
                    child: msg.senderAvatarUrl == null
                        ? Text(
                            (msg.senderName ?? 'U').substring(0, 1).toUpperCase(),
                            style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                ],
                Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe && widget.isGroup)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          msg.senderName ?? 'Student',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 16),
                        ),
                        border: isMe ? null : Border.all(color: AppColors.border),
                        boxShadow: [
                          if (!isMe)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Text(
                        msg.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.textPrimary,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Type a message...",
                fillColor: AppColors.surfaceWarm,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 20,
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
