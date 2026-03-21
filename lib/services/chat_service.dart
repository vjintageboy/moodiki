import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../models/appointment.dart';
import 'supabase_service.dart';

class ChatService {
  final SupabaseClient _supabase = SupabaseService.instance.client;

  Future<int> syncAppointmentChatRoomsForUser(String userId) async {
    if (userId.isEmpty) return 0;
    try {
      final appointments = await _supabase
          .from('appointments')
          .select('id, user_id, expert_id')
          .or('user_id.eq.$userId,expert_id.eq.$userId');

      if (appointments.isEmpty) return 0;

      var changedRooms = 0;
      for (final row in appointments) {
        final map = Map<String, dynamic>.from(row);
        final appointmentId = map['id']?.toString() ?? '';
        final appointmentUserId = map['user_id']?.toString() ?? '';
        final appointmentExpertId = map['expert_id']?.toString() ?? '';

        if (appointmentId.isEmpty ||
            appointmentUserId.isEmpty ||
            appointmentExpertId.isEmpty) {
          continue;
        }

        final roomId = await _ensureAppointmentRoomAndParticipants(
          appointmentId: appointmentId,
          userId: appointmentUserId,
          expertId: appointmentExpertId,
          allowCreateRoom: false,
        );

        if (roomId != null) changedRooms++;
      }

      return changedRooms;
    } catch (e) {
      if (_isRlsDenied(e)) {
        debugPrint(
          '⚠️ Sync skipped by RLS (chat_rooms insert/select policy). Existing rooms are still shown if accessible.',
        );
        return 0;
      }
      debugPrint('❌ Error syncing appointment chat rooms: $e');
      return 0;
    }
  }

  // Create or get existing appointment chat room
  Future<String> createOrGetChatRoom({
    required String appointmentId,
    required String userId,
    required String expertId,
  }) async {
    try {
      final existingRoom = await _supabase
          .from('chat_rooms')
          .select('id')
          .eq('appointment_id', appointmentId)
          .maybeSingle();

      String roomId;
      if (existingRoom != null) {
        roomId = existingRoom['id'].toString();
      } else {
        final inserted = await _supabase
            .from('chat_rooms')
            .insert({
              'appointment_id': appointmentId,
              'status': ChatRoomStatus.active.name,
              'room_type': 'appointment',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .select('id')
            .single();
        roomId = inserted['id'].toString();
      }

      await _upsertParticipant(roomId, userId);
      await _upsertParticipant(roomId, expertId);

      final hasSystemMessage = await _hasSystemMessage(roomId);
      if (!hasSystemMessage) {
        await sendMessage(
          roomId: roomId,
          senderId: userId,
          content:
              'System: Bạn đã được kết nối với Expert cho buổi tư vấn. Hãy bắt đầu trò chuyện nếu bạn muốn trao đổi trước buổi hẹn.',
          type: MessageType.system,
        );
      }

      return roomId;
    } catch (e) {
      debugPrint('❌ Error creating/getting chat room: $e');
      rethrow;
    }
  }

  Future<String> createOrGetDirectChatRoom({
    required String userA,
    required String userB,
  }) async {
    try {
      final participants = [userA, userB]..sort();
      final directKey = '${participants.first}:${participants.last}';

      final existingRoom = await _supabase
          .from('chat_rooms')
          .select('id')
          .eq('direct_key', directKey)
          .maybeSingle();

      if (existingRoom != null) {
        return existingRoom['id'].toString();
      }

      final inserted = await _supabase
          .from('chat_rooms')
          .insert({
            'status': ChatRoomStatus.active.name,
            'room_type': 'direct',
            'direct_key': directKey,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      final roomId = inserted['id'].toString();
      await _upsertParticipant(roomId, userA);
      await _upsertParticipant(roomId, userB);
      return roomId;
    } catch (e) {
      debugPrint('❌ Error creating/getting direct chat room: $e');
      rethrow;
    }
  }

  Future<bool> _hasSystemMessage(String roomId) async {
    final rows = await _supabase
        .from('messages')
        .select('id')
        .eq('room_id', roomId)
        .eq('type', MessageType.system.name)
        .limit(1);
    return rows.isNotEmpty;
  }

  // Wrapper for backward compatibility
  Future<String> createChatRoom({
    required String appointmentId,
    required String userId,
    required String expertId,
  }) async {
    return createOrGetChatRoom(
      appointmentId: appointmentId,
      userId: userId,
      expertId: expertId,
    );
  }

  // Send a message
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSizeBytes,
  }) async {
    try {
      await _supabase.from('messages').insert({
        'room_id': roomId,
        'sender_id': senderId,
        'content': content,
        'type': type.name,
        'attachment_url': attachmentUrl,
        'attachment_name': attachmentName,
        'attachment_size_bytes': attachmentSizeBytes,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Safety update for installations where DB trigger is not applied yet.
      await _supabase
          .from('chat_rooms')
          .update({
            'last_message': type == MessageType.text
                ? content
                : (type == MessageType.image ? '[image]' : '[${type.name}]'),
            'last_message_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', roomId);
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      rethrow;
    }
  }

  Future<void> sendImageMessage({
    required String roomId,
    required String senderId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = 'chat/$roomId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _supabase.storage.from('chat-attachments').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: false),
    );
    final url = _supabase.storage.from('chat-attachments').getPublicUrl(path);
    await sendMessage(
      roomId: roomId,
      senderId: senderId,
      content: url,
      type: MessageType.image,
      attachmentUrl: url,
      attachmentName: fileName,
      attachmentSizeBytes: bytes.length,
    );
  }

  // Get chat stream (newest first)
  Stream<List<ChatMessage>> getChatStream(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((m) => ChatMessage.fromMap(m)).toList());
  }

  // Get user's chat rooms
  Stream<List<ChatRoom>> getUserChats(String userId) {
    if (userId.isEmpty) {
      return Stream.value(const <ChatRoom>[]);
    }

    return _supabase
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .asyncMap((rooms) async {
          if (rooms.isEmpty) return <ChatRoom>[];
          final roomIds = rooms.map((r) => r['id'].toString()).toList();

          final ownParticipantRows = await _supabase
              .from('chat_participants')
              .select('room_id, unread_count')
              .eq('user_id', userId)
              .inFilter('room_id', roomIds);

          if (ownParticipantRows.isEmpty) {
            return <ChatRoom>[];
          }

          final ownByRoom = <String, int>{};
          for (final row in ownParticipantRows) {
            final map = Map<String, dynamic>.from(row);
            final roomId = map['room_id']?.toString() ?? '';
            if (roomId.isEmpty) continue;
            ownByRoom[roomId] = map['unread_count'] is int
                ? map['unread_count'] as int
                : int.tryParse(map['unread_count']?.toString() ?? '') ?? 0;
          }

          final visibleRoomIds = ownByRoom.keys.toSet();
          if (visibleRoomIds.isEmpty) {
            return <ChatRoom>[];
          }

          final participantsByRoom = <String, List<String>>{};
          try {
            final participantRows = await _supabase
                .from('chat_participants')
                .select('room_id, user_id')
                .inFilter('room_id', visibleRoomIds.toList());

            for (final row in participantRows) {
              final map = Map<String, dynamic>.from(row);
              final roomId = map['room_id']?.toString() ?? '';
              final participantId = map['user_id']?.toString() ?? '';
              if (roomId.isEmpty || participantId.isEmpty) continue;
              participantsByRoom.putIfAbsent(roomId, () => []).add(participantId);
            }
          } catch (e) {
            debugPrint('⚠️ Could not fetch all room participants (RLS likely): $e');
          }

          final visibleRooms = <ChatRoom>[];
          for (final room in rooms) {
            final roomMap = Map<String, dynamic>.from(room);
            final roomId = roomMap['id'].toString();
            if (!visibleRoomIds.contains(roomId)) continue;
            final participants = participantsByRoom[roomId] ?? [userId];

            visibleRooms.add(
              ChatRoom.fromMap({
                ...roomMap,
                'participants': participants,
                'unread_count': ownByRoom[roomId] ?? 0,
              }),
            );
          }
          return visibleRooms;
        });
  }

  // Get chat room by ID
  Future<ChatRoom?> getChatRoom(String roomId) async {
    try {
      final room = await _supabase
          .from('chat_rooms')
          .select()
          .eq('id', roomId)
          .maybeSingle();
      if (room == null) return null;

      final participantsRes = await _supabase
          .from('chat_participants')
          .select('user_id')
          .eq('room_id', roomId);
      final participants = participantsRes
          .map((row) => row['user_id'].toString())
          .toList();

      return ChatRoom.fromMap({
        ...room,
        'participants': participants,
      });
    } catch (e) {
      debugPrint('❌ Error getting chat room: $e');
      return null;
    }
  }

  Future<void> markRoomAsRead({
    required String roomId,
    required String userId,
  }) async {
    try {
      await _supabase.rpc('chat_mark_room_read', params: {
        'p_room_id': roomId,
        'p_user_id': userId,
      });
    } catch (_) {
      // Fallback if RPC not deployed yet.
      try {
        await _supabase
            .from('chat_participants')
            .update({
              'unread_count': 0,
              'last_read_at': DateTime.now().toIso8601String(),
            })
            .eq('room_id', roomId)
            .eq('user_id', userId);
      } catch (e) {
        debugPrint('❌ Error marking room read: $e');
      }
    }
  }

  Stream<bool> streamTyping({
    required String roomId,
    required String watcherUserId,
  }) async* {
    // Typing feature is temporarily disabled.
    yield false;
  }

  Future<void> setTyping({
    required String roomId,
    required String userId,
    required bool isTyping,
  }) async {
    // Typing feature is temporarily disabled.
    return;
  }

  Future<void> _upsertParticipant(String roomId, String userId) async {
    if (roomId.isEmpty || userId.isEmpty) {
      return;
    }
    await _supabase.from('chat_participants').upsert({
      'room_id': roomId,
      'user_id': userId,
    });
  }

  Future<String?> _ensureAppointmentRoomAndParticipants({
    required String appointmentId,
    required String userId,
    required String expertId,
    bool allowCreateRoom = true,
  }) async {
    try {
      final existingRoom = await _supabase
          .from('chat_rooms')
          .select('id')
          .eq('appointment_id', appointmentId)
          .maybeSingle();

      String? roomId;
      if (existingRoom != null) {
        roomId = existingRoom['id'].toString();
      } else {
        if (!allowCreateRoom) {
          return null;
        }

        final inserted = await _supabase
            .from('chat_rooms')
            .insert({
              'appointment_id': appointmentId,
              'status': ChatRoomStatus.active.name,
              'room_type': 'appointment',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .select('id')
            .single();
        roomId = inserted['id'].toString();
      }

      await _upsertParticipant(roomId, userId);
      await _upsertParticipant(roomId, expertId);

      final participantRows = await _supabase
          .from('chat_participants')
          .select('user_id')
          .eq('room_id', roomId)
          .inFilter('user_id', [userId, expertId]);

      if (participantRows.length < 2) {
        debugPrint(
          '⚠️ Participant sync incomplete for room $roomId (appointment $appointmentId). Retrying...',
        );
        await _upsertParticipant(roomId, userId);
        await _upsertParticipant(roomId, expertId);
      }

      return roomId;
    } catch (e) {
      if (_isRlsDenied(e)) {
        debugPrint(
          '⚠️ RLS denied room sync for appointment $appointmentId. Skipping client-side room creation.',
        );
        return null;
      }
      debugPrint('❌ Error ensuring appointment room participants: $e');
      return null;
    }
  }

  bool _isRlsDenied(Object error) {
    return error is PostgrestException && error.code == '42501';
  }

  // Check if user can send message based on appointment status and time
  bool canSendMessage(Appointment appointment, bool isExpert) {
    // If cancelled → No chat
    if (appointment.status == AppointmentStatus.cancelled) {
      return false;
    }

    // After consultation → unlimited chat
    if (appointment.status == AppointmentStatus.completed) {
      return true;
    }

    // Confirmed (before/during appointment)
    if (appointment.status == AppointmentStatus.confirmed) {
      final now = DateTime.now();
      final start = appointment.appointmentDate;
      final end = start.add(Duration(minutes: appointment.durationMinutes));

      // During appointment
      if (now.isAfter(start) && now.isBefore(end)) {
        return true;
      }

      // Pre-appointment → allowed (UI sẽ hạn chế user nếu cần)
      if (now.isBefore(start)) {
        return true;
      }

      // After appointment but not updated
      if (now.isAfter(end)) {
        return true;
      }
    }

    return false;
  }

  // Check video call permission
  bool canJoinVideoCall(Appointment appointment) {
    if (appointment.status != AppointmentStatus.confirmed) return false;

    final now = DateTime.now();
    final start = appointment.appointmentDate;
    final end = start.add(Duration(minutes: appointment.durationMinutes));

    // Join allowed 10 minutes before start
    final allowedStart = start.subtract(const Duration(minutes: 10));

    return now.isAfter(allowedStart) && now.isBefore(end);
  }
}
