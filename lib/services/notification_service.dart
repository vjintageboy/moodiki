import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'general', // general, refund, appointment, etc.
  }) async {
    try {
      await _db.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // Stream notifications for a user
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }
}
