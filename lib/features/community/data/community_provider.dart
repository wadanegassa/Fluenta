import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/community.dart';
import '../../../shared/models/profile.dart';
import '../../auth/data/auth_provider.dart';

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  
  final response = await supabase.from('community_rooms').select().order('name');
  
  return response.map((r) => Room.fromJson(r)).toList();
});

final usersProvider = FutureProvider<List<Profile>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final myId = supabase.auth.currentUser?.id;
  if (myId == null) return [];
  
  final response = await supabase
      .from('profiles')
      .select()
      .neq('id', myId)
      .order('full_name');
      
  return (response as List).map((p) => Profile.fromJson(p)).toList();
});

class ChatParam {
  final String id;
  final bool isGroup;

  ChatParam({required this.id, required this.isGroup});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatParam &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isGroup == other.isGroup;

  @override
  int get hashCode => id.hashCode ^ isGroup.hashCode;
}

class ChatState {
  final List<Message> messages;
  final bool isLoading;

  ChatState({this.messages = const [], this.isLoading = false});

  ChatState copyWith({List<Message>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SupabaseClient _supabase;
  final ChatParam _param;
  RealtimeChannel? _channel;

  ChatNotifier(this._supabase, this._param) : super(ChatState()) {
    _loadMessages();
    _subscribe();
  }

  Future<void> _loadMessages() async {
    state = state.copyWith(isLoading: state.messages.isEmpty);
    try {
      if (_param.isGroup) {
        // Group Rooms Load
        final response = await _supabase
            .from('community_messages')
            .select('*, profiles(full_name, avatar_url)')
            .eq('room_id', _param.id)
            .order('created_at', ascending: true);

        final list = (response as List).map((m) => Message.fromJson(m)).toList();
        state = state.copyWith(messages: list, isLoading: false);
      } else {
        // Private DM Load
        final myId = _supabase.auth.currentUser!.id;
        final response = await _supabase
            .from('direct_messages')
            .select('*, sender:profiles!direct_messages_sender_id_fkey(full_name, avatar_url)')
            .or('and(sender_id.eq.$myId,receiver_id.eq.${_param.id}),and(sender_id.eq.${_param.id},receiver_id.eq.$myId)')
            .order('created_at', ascending: true);

        final list = (response as List).map((m) {
          final Map<String, dynamic> msgMap = Map<String, dynamic>.from(m);
          // Standardize JSON structure for unified Message parsing
          msgMap['profiles'] = m['sender'] ?? {'full_name': 'User', 'avatar_url': null};
          return Message.fromJson(msgMap);
        }).toList();

        state = state.copyWith(messages: list, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _subscribe() {
    final myId = _supabase.auth.currentUser!.id;

    if (_param.isGroup) {
      // Group subscription
      _channel = _supabase.channel('room:${_param.id}').onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'community_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'room_id',
          value: _param.id,
        ),
        callback: (payload) async {
          final senderId = payload.newRecord['sender_id'];
          final profileRes = await _supabase
              .from('profiles')
              .select('full_name, avatar_url')
              .eq('id', senderId)
              .maybeSingle();

          final Map<String, dynamic> msgMap = Map<String, dynamic>.from(payload.newRecord);
          msgMap['profiles'] = profileRes ?? {'full_name': 'User', 'avatar_url': null};

          final newMessage = Message.fromJson(msgMap);
          
          if (mounted) {
            if (!state.messages.any((m) => m.id == newMessage.id)) {
              state = state.copyWith(messages: [...state.messages, newMessage]);
            }
          }
        },
      );
    } else {
      // DM subscription: Listen to direct_messages insert events
      _channel = _supabase.channel('dm:${_param.id}').onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'direct_messages',
        callback: (payload) async {
          final senderId = payload.newRecord['sender_id'];
          final receiverId = payload.newRecord['receiver_id'];
          
          // Verify if message exchange belongs strictly to this active DM thread
          final isFromMeToThem = senderId == myId && receiverId == _param.id;
          final isFromThemToMe = senderId == _param.id && receiverId == myId;

          if (isFromMeToThem || isFromThemToMe) {
            final profileRes = await _supabase
                .from('profiles')
                .select('full_name, avatar_url')
                .eq('id', senderId)
                .maybeSingle();

            final Map<String, dynamic> msgMap = Map<String, dynamic>.from(payload.newRecord);
            msgMap['profiles'] = profileRes ?? {'full_name': 'User', 'avatar_url': null};

            final newMessage = Message.fromJson(msgMap);
            
            if (mounted) {
              if (!state.messages.any((m) => m.id == newMessage.id)) {
                state = state.copyWith(messages: [...state.messages, newMessage]);
              }
            }
          }
        },
      );
    }
    _channel?.subscribe();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    final userId = _supabase.auth.currentUser!.id;

    if (_param.isGroup) {
      await _supabase.from('community_messages').insert({
        'room_id': _param.id,
        'sender_id': userId,
        'content': content.trim(),
      });
    } else {
      await _supabase.from('direct_messages').insert({
        'sender_id': userId,
        'receiver_id': _param.id,
        'content': content.trim(),
      });
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, ChatParam>((ref, param) {
  final supabase = ref.watch(supabaseProvider);
  return ChatNotifier(supabase, param);
});
