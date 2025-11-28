import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import 'momo_service.dart';
import 'notification_service.dart';

class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MomoService _momoService = MomoService();
  final NotificationService _notificationService = NotificationService();

  // Create appointment
  Future<String?> createAppointment(Appointment appointment) async {
    try {
      // ✅ Check for expert time conflicts
      final hasExpertConflict = await _checkExpertTimeConflict(
        appointment.expertId,
        appointment.appointmentDate,
        appointment.durationMinutes,
      );

      if (hasExpertConflict) {
        throw Exception('This expert is not available at the selected time. Please choose another time slot.');
      }

      // ✅ Check for user time conflicts
      final hasUserConflict = await _checkUserTimeConflict(
        appointment.userId,
        appointment.appointmentDate,
        appointment.durationMinutes,
      );

      if (hasUserConflict) {
        throw Exception('You already have an appointment at this time. Please choose another time slot.');
      }

      final docRef = _db.collection('appointments').doc();
      final newAppointment = appointment.copyWith(
        appointmentId: docRef.id,
      );

      await docRef.set(newAppointment.toMap());
      return docRef.id;
    } catch (e) {
      print('❌ Error creating appointment: $e');
      rethrow; // Re-throw to show error message to user
    }
  }

  // Update payment ID after successful payment
  Future<void> updateAppointmentPaymentId(
    String appointmentId,
    String paymentId,
    String paymentTransId,
  ) async {
    try {
      if (appointmentId.isEmpty) {
        print('❌ Cannot update payment: appointmentId is empty');
        return;
      }

      await _db.collection('appointments').doc(appointmentId).update({
        'paymentId': paymentId,
        'paymentTransId': paymentTransId,
      });
    } catch (e) {
      print('❌ Error updating payment ID: $e');
      rethrow;
    }
  }

  // ✅ Check if time slot conflicts with expert's existing appointments
  Future<bool> _checkExpertTimeConflict(
    String expertId,
    DateTime appointmentDate,
    int durationMinutes,
  ) async {
    return _checkTimeConflict(
      'expertId',
      expertId,
      appointmentDate,
      durationMinutes,
    );
  }

  // ✅ Check if time slot conflicts with user's existing appointments
  Future<bool> _checkUserTimeConflict(
    String userId,
    DateTime appointmentDate,
    int durationMinutes,
  ) async {
    return _checkTimeConflict(
      'userId',
      userId,
      appointmentDate,
      durationMinutes,
    );
  }

  // ✅ Generic time conflict checker
  Future<bool> _checkTimeConflict(
    String fieldName,
    String fieldValue,
    DateTime appointmentDate,
    int durationMinutes,
  ) async {
    try {
      final appointmentStart = appointmentDate;
      final appointmentEnd = appointmentDate.add(Duration(minutes: durationMinutes));

      // Get all confirmed appointments for this field on the same day
      final startOfDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );
      final endOfDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        23,
        59,
        59,
      );

      final snapshot = await _db
          .collection('appointments')
          .where(fieldName, isEqualTo: fieldValue)
          .where('status', isEqualTo: AppointmentStatus.confirmed.name)
          .get();

      // Check for overlaps
      for (final doc in snapshot.docs) {
        final existingAppt = Appointment.fromSnapshot(doc);
        
        // Skip if not on the same day
        if (existingAppt.appointmentDate.isBefore(startOfDay) ||
            existingAppt.appointmentDate.isAfter(endOfDay)) {
          continue;
        }

        final existingStart = existingAppt.appointmentDate;
        final existingEnd = existingAppt.appointmentDate.add(
          Duration(minutes: existingAppt.durationMinutes),
        );

        // Check if times overlap
        // Overlap happens if:
        // - New appointment starts before existing ends AND
        // - New appointment ends after existing starts
        final overlaps = appointmentStart.isBefore(existingEnd) &&
                        appointmentEnd.isAfter(existingStart);

        if (overlaps) {
          return true; // Conflict found
        }
      }

      return false; // No conflict
    } catch (e) {
      print('❌ Error checking time conflict: $e');
      return false; // Assume no conflict if error
    }
  }

  // Get user appointments
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      final snapshot = await _db
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromSnapshot(doc))
          .toList();
      
      // Sort trong code thay vì Firestore
      appointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      
      return appointments;
    } catch (e) {
      print('❌ Error getting appointments: $e');
      return [];
    }
  }

  // Stream user appointments (real-time)
  Stream<List<Appointment>> streamUserAppointments(String userId) {
    return _db
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final appointments = snapshot.docs
              .map((doc) => Appointment.fromSnapshot(doc))
              .toList();
          
          // Sort trong code thay vì Firestore
          appointments.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
          
          return appointments;
        });
  }

  // Cancel appointment (user)
  Future<RefundStatus> cancelAppointment(String appointmentId) async {
    try {
      if (appointmentId.isEmpty) {
         throw Exception('Appointment ID is empty');
      }

      final docRef = _db.collection('appointments').doc(appointmentId);
      final doc = await docRef.get();
      if (!doc.exists) throw Exception('Appointment not found');

      final appointment = Appointment.fromSnapshot(doc);

      // Determine refund status
      RefundStatus refundStatus = RefundStatus.none;
      
      // Check if we have payment info, or at least paymentId to query transId
      String? paymentId = appointment.paymentId;
      String? transId = appointment.paymentTransId;

      print('ℹ️ Cancelling Appointment: ${appointment.appointmentId}');
      print('   - Payment ID: $paymentId');
      print('   - Trans ID: $transId');

      if (paymentId != null) {
        // Handle Mock Payments
        if (paymentId.startsWith('MOCK_')) {
          refundStatus = RefundStatus.success;
          print('✅ [MOCK REFUND] Refund Successful for Appointment: ${appointment.appointmentId}');
          
          await _notificationService.sendNotification(
            userId: appointment.userId,
            title: 'Refund Successful',
            message: 'Your appointment with ${appointment.expertName} has been cancelled and refunded successfully (Mock).',
            type: 'refund',
          );
        } 
        // Handle Real MoMo Payments
        else {
          // If transId is missing or invalid (0), try to fetch/check it
          if (transId == null || transId == '0') {
            try {
              final queryRes = await _momoService.checkStatus(paymentId);
              if (queryRes != null && queryRes['resultCode'] == 0) {
                final fetchedTransId = queryRes['transId'];
                // Only update if we get a valid positive transId
                if (fetchedTransId != null && fetchedTransId is num && fetchedTransId > 0) {
                   transId = fetchedTransId.toString();
                   await docRef.update({'paymentTransId': transId});
                   print('✅ Fetched valid Trans ID: $transId');
                } else {
                   print('⚠️ Query success but Trans ID is invalid/pending: $fetchedTransId');
                }
              }
            } catch (e) {
              print("Error fetching missing transId: $e");
            }
          }

          // Only proceed with refund if we have a valid transId (not null, not '0')
          if (transId != null && transId != '0') {
            // Call refund API
            final refundRes = await _momoService.refundPayment(
              orderId: paymentId,
              amount: appointment.price,
              transId: transId,
            );

            if (refundRes != null && refundRes['resultCode'] == 0) {
              refundStatus = RefundStatus.success;
              print('✅ [MOMO REFUND] Refund Successful for Appointment: ${appointment.appointmentId}');
              print('   - Trans ID: $transId');

              // Refund success notification
              await _notificationService.sendNotification(
                userId: appointment.userId,
                title: 'Refund Successful',
                message: 'Your appointment with ${appointment.expertName} has been cancelled and refunded successfully.',
                type: 'refund',
              );
            } else {
              refundStatus = RefundStatus.failed;
              print('❌ [REFUND FAILED] MoMo Refund Failed for Appointment: ${appointment.appointmentId}');
              print('   - Error: ${refundRes?['message']}');

              // Refund failed notification
              await _notificationService.sendNotification(
                userId: appointment.userId,
                title: 'Refund Failed',
                message: 'Your appointment was cancelled but refund failed. Please contact support.',
                type: 'refund_error',
              );
            }
          } else {
             // Payment ID exists but Trans ID is invalid (0 or null) -> Transaction not confirmed/captured
             print('⚠️ [REFUND SKIP] Payment ID exists but Trans ID is invalid (0 or null). Transaction likely not completed/captured.');
             
             // Notify cancellation but mention check status
             await _notificationService.sendNotification(
              userId: appointment.userId,
              title: 'Appointment Cancelled',
              message: 'Your appointment with ${appointment.expertName} has been cancelled.',
              type: 'cancellation',
            );
          }
        }
      } else {
        // No payment info found - just cancel
        print('ℹ️ [CANCEL] Appointment cancelled without refund (No payment info).');
        await _notificationService.sendNotification(
          userId: appointment.userId,
          title: 'Appointment Cancelled',
          message: 'Your appointment with ${appointment.expertName} has been cancelled.',
          type: 'cancellation',
        );
      }

      await docRef.update({
        'status': AppointmentStatus.cancelled.name,
        'cancelledAt': Timestamp.now(),
        'cancelledBy': 'user',
        'refundStatus': refundStatus.name,
      });

      return refundStatus;
    } catch (e) {
      print('❌ Error cancelling appointment: $e');
      rethrow;
    }
  }

  // Cancel appointment with reason (expert/admin)
  Future<void> cancelAppointmentWithReason(
    String appointmentId,
    String reason,
  ) async {
    try {
      if (appointmentId.isEmpty) {
         throw Exception('Appointment ID is empty');
      }

      final docRef = _db.collection('appointments').doc(appointmentId);
      final doc = await docRef.get();
      if (!doc.exists) throw Exception('Appointment not found');

      final appointment = Appointment.fromSnapshot(doc);

      // Determine refund status
      RefundStatus refundStatus = RefundStatus.none;
      
      String? paymentId = appointment.paymentId;
      String? transId = appointment.paymentTransId;

      print('ℹ️ Expert Cancelling Appointment: ${appointment.appointmentId}');

      if (paymentId != null) {
        // Handle Mock
        if (paymentId.startsWith('MOCK_')) {
           refundStatus = RefundStatus.success;
           await _notificationService.sendNotification(
              userId: appointment.userId,
              title: 'Appointment Cancelled & Refunded',
              message: 'Expert ${appointment.expertName} cancelled the appointment. Reason: $reason. Refund has been processed (Mock).',
              type: 'refund',
            );
        }
        else {
           // Real MoMo
           if (transId == null || transId == '0') {
            try {
              final queryRes = await _momoService.checkStatus(paymentId);
              if (queryRes != null && queryRes['resultCode'] == 0) {
                 final fetchedTransId = queryRes['transId'];
                 if (fetchedTransId != null && fetchedTransId is num && fetchedTransId > 0) {
                   transId = fetchedTransId.toString();
                   await docRef.update({'paymentTransId': transId});
                 }
              }
            } catch (e) {
              print("Error fetching missing transId: $e");
            }
          }

          if (transId != null && transId != '0') {
            // Call refund API
            final refundRes = await _momoService.refundPayment(
              orderId: paymentId,
              amount: appointment.price,
              transId: transId,
            );

            if (refundRes != null && refundRes['resultCode'] == 0) {
               refundStatus = RefundStatus.success;
               print('✅ [MOMO REFUND] Expert Cancel - Refund Success');
               
              await _notificationService.sendNotification(
                userId: appointment.userId,
                title: 'Appointment Cancelled & Refunded',
                message: 'Expert ${appointment.expertName} cancelled the appointment. Reason: $reason. Refund has been processed.',
                type: 'refund',
              );
            } else {
               refundStatus = RefundStatus.failed;
               print('❌ [REFUND FAILED] Expert Cancel - Refund Failed');
               
               await _notificationService.sendNotification(
                userId: appointment.userId,
                title: 'Refund Failed',
                message: 'Expert cancelled the appointment but refund failed. Please contact support.',
                type: 'refund_error',
              );
            }
          } else {
             // No valid transId
             await _notificationService.sendNotification(
                userId: appointment.userId,
                title: 'Appointment Cancelled',
                message: 'Expert ${appointment.expertName} cancelled the appointment. Reason: $reason.',
                type: 'cancellation',
              );
          }
        }
      } else {
        // No payment
        await _notificationService.sendNotification(
            userId: appointment.userId,
            title: 'Appointment Cancelled',
            message: 'Expert ${appointment.expertName} cancelled the appointment. Reason: $reason.',
            type: 'cancellation',
          );
      }

      await docRef.update({
        'status': AppointmentStatus.cancelled.name,
        'cancelledAt': Timestamp.now(),
        'cancellationReason': reason,
        'cancelledBy': 'expert',
        'refundStatus': refundStatus.name,
      });
    } catch (e) {
      print('❌ Error cancelling appointment: $e');
      rethrow;
    }
  }

  // Get booked time slots for expert on specific date
  Future<List<String>> getBookedTimeSlots(
    String expertId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Simplified query - chỉ filter theo expertId
      final snapshot = await _db
          .collection('appointments')
          .where('expertId', isEqualTo: expertId)
          .get();

      // Filter trong code thay vì Firestore
      final bookedSlots = snapshot.docs
          .map((doc) => Appointment.fromSnapshot(doc))
          .where((apt) {
            // Filter: status = confirmed
            if (apt.status != AppointmentStatus.confirmed) return false;
            
            // Filter: date trong khoảng startOfDay -> endOfDay
            return apt.appointmentDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                   apt.appointmentDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
          })
          .map((apt) => _formatTimeSlot(apt.appointmentDate))
          .toList();

      return bookedSlots;
    } catch (e) {
      print('❌ Error getting booked slots: $e');
      return [];
    }
  }

  String _formatTimeSlot(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Generate available time slots
  List<String> generateTimeSlots({
    required String startTime,
    required String endTime,
    required int intervalMinutes,
  }) {
    final slots = <String>[];
    
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    
    DateTime current = start;
    while (current.isBefore(end)) {
      final hour = current.hour.toString().padLeft(2, '0');
      final minute = current.minute.toString().padLeft(2, '0');
      slots.add('$hour:$minute');
      current = current.add(Duration(minutes: intervalMinutes));
    }
    
    return slots;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
