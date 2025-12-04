import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/chat_room.dart';
import '../../models/chat_message.dart';
import '../../models/appointment.dart';
import '../../services/chat_service.dart';
import '../../services/appointment_service.dart'; // To get appointment details

class ChatDetailPage extends StatefulWidget {
  final String roomId;
  final String expertName;
  final String expertId;
  final String? targetAvatarUrl; // Added for avatar display

  const ChatDetailPage({
    super.key,
    required this.roomId,
    required this.expertName,
    required this.expertId,
    this.targetAvatarUrl,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  // ... existing state ...
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AppointmentService _appointmentService = AppointmentService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Appointment? _appointment;
  bool _isLoadingAppointment = true;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  // ... _loadAppointment ...
  Future<void> _loadAppointment() async {
    try {
      final chatRoom = await _chatService.getChatRoom(widget.roomId);
      if (chatRoom != null) {
        final appointment = await _appointmentService.getAppointmentById(chatRoom.appointmentId);
        if (mounted) {
          setState(() {
            _appointment = appointment;
            _isLoadingAppointment = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingAppointment = false);
      }
    } catch (e) {
      print('Error loading appointment: $e');
      if (mounted) setState(() => _isLoadingAppointment = false);
    }
  }

  // ... _sendMessage ...
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    if (_appointment != null) {
      final isExpert = _currentUserId != _appointment!.userId;
      final canSend = _chatService.canSendMessage(_appointment!, isExpert);
      if (!canSend) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn chưa thể gửi tin nhắn vào lúc này.')),
        );
        return;
      }
    }

    _chatService.sendMessage(
      roomId: widget.roomId,
      senderId: _currentUserId,
      content: _messageController.text.trim(),
    );

    _messageController.clear();
  }

  // ... build ...
  @override
  Widget build(BuildContext context) {
    // ... existing permission logic ...
    bool canSend = false;
    bool canVideo = false;
    bool isPreSession = false;
    bool isCompleted = false;
    bool isExpert = false;

    if (_appointment != null) {
      isExpert = _currentUserId != _appointment!.userId;
      canSend = _chatService.canSendMessage(_appointment!, isExpert);
      canVideo = _chatService.canJoinVideoCall(_appointment!);
      
      isCompleted = _appointment!.status == AppointmentStatus.completed;
      isPreSession = _appointment!.status == AppointmentStatus.confirmed && 
                     DateTime.now().isBefore(_appointment!.appointmentDate);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expertName),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: canVideo ? Colors.blue : Colors.grey),
            onPressed: canVideo
                ? () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng gọi video sắp ra mắt')),
                    );
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cuộc gọi video chỉ mở 10 phút trước giờ hẹn.')),
                    );
                  },
          ),
          IconButton(
            icon: const Icon(Icons.emergency, color: Colors.red),
            onPressed: () => _showSOSDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_appointment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch hẹn: ${DateFormat('HH:mm - dd/MM/yyyy').format(_appointment!.appointmentDate)}',
                    style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getChatStream(widget.roomId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;
                    final isSystem = message.type == MessageType.system;

                    if (isSystem) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Avatar for incoming messages
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: widget.targetAvatarUrl != null && widget.targetAvatarUrl!.isNotEmpty
                                  ? NetworkImage(widget.targetAvatarUrl!)
                                  : null,
                              child: (widget.targetAvatarUrl == null || widget.targetAvatarUrl!.isEmpty)
                                  ? const Icon(Icons.person, size: 16, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Message Bubble
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('HH:mm').format(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Dynamic Footer
          if (canSend)
            _buildFullChatInput()
          else if (isPreSession && !isExpert)
            _buildRestrictedFooter()
          else if (!isExpert)
             Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: const Center(
                child: Text(
                  'Chat đã bị khóa.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
           else 
             // Expert view when chat is locked (e.g. cancelled)
             const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildFullChatInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Chat đầy đủ sẽ mở sau buổi tham vấn.",
              style: TextStyle(color: Colors.deepOrange, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _openShortQuestionForm,
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange.shade100,
              foregroundColor: Colors.deepOrange,
            ),
            child: const Text("Gửi câu hỏi"),
          )
        ],
      ),
    );
  }

  void _openShortQuestionForm() {
    final TextEditingController questionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi câu hỏi ngắn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bạn có thể gửi trước câu hỏi hoặc vấn đề cần tư vấn để chuyên gia chuẩn bị.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập câu hỏi của bạn...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.trim().isNotEmpty) {
                _chatService.sendMessage(
                  roomId: widget.roomId,
                  senderId: _currentUserId,
                  content: '[Câu hỏi trước buổi hẹn]: ${questionController.text.trim()}',
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi câu hỏi thành công!')),
                );
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Trợ giúp khẩn cấp'),
          ],
        ),
        content: const Text(
          'Nếu bạn hoặc ai đó đang gặp nguy hiểm, vui lòng gọi ngay cho các số điện thoại khẩn cấp (113, 115) hoặc đến cơ sở y tế gần nhất.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Implement call action here
              Navigator.pop(context);
            },
            child: const Text('Gọi 115', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
