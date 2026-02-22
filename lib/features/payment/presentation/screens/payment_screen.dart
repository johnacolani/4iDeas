import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../helper/app_background.dart';
import '../../../../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const PaymentScreen({
    super.key,
    required this.order,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final OrderService _orderService = OrderService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paymentNotesController = TextEditingController();
  bool _isProcessing = false;
  String? _error;
  String? _selectedPaymentMethod = 'Stripe';

  @override
  void initState() {
    super.initState();
    // Pre-fill amount if available (you can set a default or calculate it)
    // For now, we'll leave it empty for user to enter
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paymentNotesController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_amountController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter the down payment amount';
      });
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Please enter a valid amount';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final orderId = widget.order['id'] as String;
      
      // TODO: Integrate with actual payment gateway (Stripe, PayPal, etc.)
      // For now, we'll simulate the payment and store it in Firestore
      // In production, you'll need to:
      // 1. Create a payment intent with Stripe
      // 2. Process the payment
      // 3. Get the transaction ID
      // 4. Then save to Firestore
      
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate a mock transaction ID (replace with real transaction ID from payment gateway)
      final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
      
      await _orderService.processDownPayment(
        orderId: orderId,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        transactionId: transactionId,
        paymentNotes: _paymentNotesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment of \$${amount.toStringAsFixed(2)} processed successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to process payment: ${e.toString()}';
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    
    final order = widget.order;
    final appName = order['appName']?.toString() ?? 'Untitled Order';
    final contractSigned = order['contractSigned'] == true;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: const Color(0xff020923),
        title: Text(
          'Down Payment',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order Info Card
                Container(
                  padding: EdgeInsets.all(isMobile ? 20 : 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.purple,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              appName,
                              style: GoogleFonts.albertSans(
                                color: Colors.white,
                                fontSize: isMobile ? 20 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (contractSigned)
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Contract Signed',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: isMobile ? 14 : 15,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Contract must be signed before payment',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: isMobile ? 14 : 15,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),

                // Payment Form
                Container(
                  padding: EdgeInsets.all(isMobile ? 20 : 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment,
                            color: ColorManager.orange,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Down Payment',
                            style: GoogleFonts.albertSans(
                              color: Colors.white,
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 24),
                      
                      // Payment Amount
                      Text(
                        'Amount *',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: Colors.white, fontSize: isMobile ? 18 : 20),
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: ColorManager.orange, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Payment Method
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPaymentMethod,
                          dropdownColor: const Color(0xff020923),
                          style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 18),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'Stripe', child: Text('Stripe (Credit/Debit Card)')),
                            DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                            DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),

                      // Payment Notes
                      Text(
                        'Payment Notes (Optional)',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _paymentNotesController,
                        maxLines: 3,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Any additional notes about this payment...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: ColorManager.orange, width: 2),
                          ),
                        ),
                      ),

                      if (_error != null) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 24),
                      
                      // Process Payment Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: (contractSigned && !_isProcessing) ? _processPayment : null,
                          icon: Icon(Icons.payment, size: 24),
                          label: Text(
                            'Process Payment',
                            style: GoogleFonts.albertSans(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: contractSigned ? ColorManager.orange : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),

                      if (_isProcessing) ...[
                        SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: ColorManager.orange),
                              SizedBox(height: 12),
                              Text(
                                'Processing payment...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

