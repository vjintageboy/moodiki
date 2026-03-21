enum MessageType { text, image, file, system }

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isPinned;
  final String? attachmentUrl;
  final String? attachmentName;
  final int? attachmentSizeBytes;
  final DateTime? readAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isPinned = false,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSizeBytes,
    this.readAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'type': type.name,
      'created_at': timestamp.toIso8601String(),
      'is_pinned': isPinned,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'attachment_size_bytes': attachmentSizeBytes,
      'read_at': readAt?.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id']?.toString() ?? '',
      roomId: map['room_id']?.toString() ?? '',
      senderId: map['sender_id']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: _parseDateTime(map['created_at']),
      isPinned: map['is_pinned'] == true,
      attachmentUrl: map['attachment_url']?.toString(),
      attachmentName: map['attachment_name']?.toString(),
      attachmentSizeBytes: map['attachment_size_bytes'] is int
          ? map['attachment_size_bytes'] as int
          : int.tryParse(map['attachment_size_bytes']?.toString() ?? ''),
      readAt: _parseNullableDateTime(map['read_at']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
