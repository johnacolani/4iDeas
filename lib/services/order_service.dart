import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save order to Firestore
  Future<void> saveOrder({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    String? clientCompany,
    required String appName,
    String? appType,
    String? appDescription,
    String? appFeatures,
    String? budget,
    String? timeline,
    String? priority,
    String? designStyle,
    String? designComplexity,
    Set<String>? selectedPlatforms,
    String? colorScheme,
    String? designInspiration,
    String? brandGuidelines,
    String? additionalNotes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to save orders');
      }

      final orderData = {
        'userId': user.uid,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientPhone': clientPhone ?? '',
        'clientCompany': clientCompany ?? '',
        'appName': appName,
        'appType': appType ?? 'Not specified',
        'appDescription': appDescription ?? '',
        'appFeatures': appFeatures ?? '',
        'budget': budget ?? '',
        'timeline': timeline ?? '',
        'priority': priority ?? 'Not specified',
        'designStyle': designStyle ?? '',
        'designComplexity': designComplexity ?? '',
        'selectedPlatforms': selectedPlatforms?.toList() ?? [],
        'colorScheme': colorScheme ?? '',
        'designInspiration': designInspiration ?? '',
        'brandGuidelines': brandGuidelines ?? '',
        'additionalNotes': additionalNotes ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      await _firestore.collection('orders').add(orderData);
    } catch (e) {
      throw Exception('Failed to save order: $e');
    }
  }

  // Get orders for current user
  Stream<List<Map<String, dynamic>>> getUserOrders() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          // Convert Timestamp to DateTime string for display
          if (data['createdAt'] != null) {
            final timestamp = data['createdAt'] as Timestamp;
            data['createdAt'] = timestamp.toDate().toString();
          }
          return data;
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Get orders for current user (one-time fetch)
  Future<List<Map<String, dynamic>>> getUserOrdersOnce() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('OrderService: No authenticated user');
        return [];
      }

      debugPrint('OrderService: Fetching orders for user: ${user.uid}');

      // Try with orderBy first, if it fails (needs index), fall back to simple query
      QuerySnapshot snapshot;
      try {
        snapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If orderBy fails (likely needs index), try without orderBy
        debugPrint('OrderService: orderBy failed, trying without: $e');
        snapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .get();
      }

      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        // Convert Timestamp to DateTime string for display
        if (data['createdAt'] != null) {
          final timestamp = data['createdAt'] as Timestamp;
          data['createdAt'] = timestamp.toDate().toString();
        }
        return data;
      }).toList();

      // Sort manually if we didn't use orderBy
      if (orders.length > 1) {
        orders.sort((a, b) {
          final aTime = a['createdAt']?.toString() ?? '';
          final bTime = b['createdAt']?.toString() ?? '';
          return bTime.compareTo(aTime); // Descending
        });
      }

      debugPrint('OrderService: Found ${orders.length} orders');
      return orders;
    } catch (e, stackTrace) {
      debugPrint('OrderService: Error fetching orders: $e');
      debugPrint('OrderService: Stack trace: $stackTrace');
      rethrow; // Re-throw so the UI can handle it
    }
  }

  // Get all orders (admin only)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      debugPrint('OrderService: Fetching all orders (admin)');

      QuerySnapshot snapshot;
      try {
        snapshot = await _firestore
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If orderBy fails, try without orderBy
        debugPrint('OrderService: orderBy failed, trying without: $e');
        snapshot = await _firestore.collection('orders').get();
      }

      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        // Convert Timestamp to DateTime string for display
        if (data['createdAt'] != null) {
          final timestamp = data['createdAt'] as Timestamp;
          data['createdAt'] = timestamp.toDate().toString();
        }
        return data;
      }).toList();

      // Sort manually if we didn't use orderBy
      if (orders.length > 1) {
        orders.sort((a, b) {
          final aTime = a['createdAt']?.toString() ?? '';
          final bTime = b['createdAt']?.toString() ?? '';
          return bTime.compareTo(aTime); // Descending
        });
      }

      debugPrint('OrderService: Found ${orders.length} total orders');
      return orders;
    } catch (e, stackTrace) {
      debugPrint('OrderService: Error fetching all orders: $e');
      debugPrint('OrderService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Add admin response to an order
  Future<void> addAdminResponse({
    required String orderId,
    required String response,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User must be authenticated');
      }

      await _firestore.collection('orders').doc(orderId).update({
        'adminResponse': response,
        'adminResponseDate': FieldValue.serverTimestamp(),
        'adminEmail': user.email,
        'status': 'responded',
      });

      debugPrint('OrderService: Admin response added to order $orderId');
    } catch (e) {
      debugPrint('OrderService: Error adding admin response: $e');
      throw Exception('Failed to add response: $e');
    }
  }

  // Add client response to an order
  Future<void> addClientResponse({
    required String orderId,
    required String response,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      await _firestore.collection('orders').doc(orderId).update({
        'clientResponse': response,
        'clientResponseDate': FieldValue.serverTimestamp(),
        'status': 'client_replied',
      });

      debugPrint('OrderService: Client response added to order $orderId');
    } catch (e) {
      debugPrint('OrderService: Error adding client response: $e');
      throw Exception('Failed to add response: $e');
    }
  }

  // Send contract to client (admin only)
  Future<void> sendContract({
    required String orderId,
    required double finalPrice,
    required double downPaymentAmount,
    required double weeklyPaymentAmount,
    String? contractUrl,
    String? contractNotes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User must be authenticated');
      }

      // Calculate total weekly payments (assuming standard 4-week project, adjust as needed)
      final numberOfWeeks = (finalPrice - downPaymentAmount) / weeklyPaymentAmount;
      final totalWeeklyPayments = weeklyPaymentAmount * numberOfWeeks.ceil();
      final finalPaymentAmount = finalPrice - downPaymentAmount - totalWeeklyPayments;

      await _firestore.collection('orders').doc(orderId).update({
        'contractSent': true,
        'contractSentDate': FieldValue.serverTimestamp(),
        'contractSentBy': user.email,
        'contractUrl': contractUrl ?? '',
        'contractNotes': contractNotes ?? '',
        'contractSigned': false,
        'status': 'contract_sent',
        // Contract pricing
        'finalPrice': finalPrice,
        'downPaymentAmount': downPaymentAmount,
        'weeklyPaymentAmount': weeklyPaymentAmount,
        'numberOfWeeks': numberOfWeeks.ceil(),
        'totalWeeklyPayments': totalWeeklyPayments,
        'finalPaymentAmount': finalPaymentAmount,
        // Payment tracking
        'totalPaidAmount': 0.0,
        'weeklyPaymentsMade': 0,
        'progressReports': <Map<String, dynamic>>[],
      });

      debugPrint('OrderService: Contract sent for order $orderId');
    } catch (e) {
      debugPrint('OrderService: Error sending contract: $e');
      throw Exception('Failed to send contract: $e');
    }
  }

  // Mark contract as signed by client
  Future<void> markContractSigned({
    required String orderId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      await _firestore.collection('orders').doc(orderId).update({
        'contractSigned': true,
        'contractSignedDate': FieldValue.serverTimestamp(),
        'contractSignedBy': user.uid,
        'status': 'contract_signed',
      });

      debugPrint('OrderService: Contract marked as signed for order $orderId');
    } catch (e) {
      debugPrint('OrderService: Error marking contract as signed: $e');
      throw Exception('Failed to mark contract as signed: $e');
    }
  }

  // Process down payment
  Future<void> processDownPayment({
    required String orderId,
    required double amount,
    String? paymentMethod,
    String? transactionId,
    String? paymentNotes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      await _firestore.collection('orders').doc(orderId).update({
        'downPaymentAmount': amount,
        'downPaymentPaid': true,
        'downPaymentDate': FieldValue.serverTimestamp(),
        'downPaymentPaidBy': user.uid,
        'paymentMethod': paymentMethod ?? 'Stripe',
        'transactionId': transactionId ?? '',
        'paymentNotes': paymentNotes ?? '',
        'status': 'payment_received',
      });

      debugPrint('OrderService: Down payment processed for order $orderId');
    } catch (e) {
      debugPrint('OrderService: Error processing down payment: $e');
      throw Exception('Failed to process payment: $e');
    }
  }

  // Get payment status for an order
  Future<Map<String, dynamic>?> getPaymentStatus(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        final data = doc.data();
        return {
          'downPaymentPaid': data?['downPaymentPaid'] ?? false,
          'downPaymentAmount': data?['downPaymentAmount'] ?? 0.0,
          'downPaymentDate': data?['downPaymentDate'],
          'paymentMethod': data?['paymentMethod'] ?? '',
          'transactionId': data?['transactionId'] ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('OrderService: Error getting payment status: $e');
      return null;
    }
  }
}

