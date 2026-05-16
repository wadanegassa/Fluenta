class Message {
  final String id;
  final String content;
  final String senderId;
  final String? senderName;
  final String? senderAvatarUrl;
  final DateTime createdAt;
  final String? roomId;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    this.senderName,
    this.senderAvatarUrl,
    required this.createdAt,
    this.roomId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderAvatarUrl: json['sender_avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      roomId: json['room_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar_url': senderAvatarUrl,
      'created_at': createdAt.toIso8601String(),
      'room_id': roomId,
    };
  }
}

class Room {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final int memberCount;

  Room({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.memberCount,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      memberCount: json['member_count'] ?? 0,
    );
  }
}
