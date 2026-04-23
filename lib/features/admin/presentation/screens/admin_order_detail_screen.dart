import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../core/widgets/frosted_app_bar.dart';
import '../../../../helper/app_background.dart';
import '../../../../services/order_service.dart';
import '../../../../app_router.dart';
import 'package:go_router/go_router.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onResponseAdded;

  const AdminOrderDetailScreen({
    super.key,
    required this.order,
    required this.onResponseAdded,
  });

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final TextEditingController _responseController = TextEditingController();
  final TextEditingController _contractNotesController =
      TextEditingController();
  final TextEditingController _finalPriceController = TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();
  final TextEditingController _weeklyPaymentController =
      TextEditingController();
  bool _isSubmitting = false;
  bool _isSendingContract = false;
  String? _error;

  @override
  void dispose() {
    _responseController.dispose();
    _contractNotesController.dispose();
    _finalPriceController.dispose();
    _downPaymentController.dispose();
    _weeklyPaymentController.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    if (_responseController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter a response';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final orderId = widget.order['id'] as String;
      await _orderService.addAdminResponse(
        orderId: orderId,
        response: _responseController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Response sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onResponseAdded();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to send response: ${e.toString()}';
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildDetailRow(String label, String value, bool isMobile) {
    if (value.isEmpty || value == 'Not specified') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 100 : 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: ColorManager.textMuted,
                fontSize: isMobile ? 14 : 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: ColorManager.textPrimary,
                fontSize: isMobile ? 14 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    final order = widget.order;
    final appName = order['appName']?.toString() ?? 'Untitled Order';
    final clientName = order['clientName']?.toString() ?? '';
    final clientEmail = order['clientEmail']?.toString() ?? '';
    final existingResponse = order['adminResponse']?.toString() ?? '';
    final clientResponse = order['clientResponse']?.toString() ?? '';
    final contractSent = order['contractSent'] == true;
    final contractSigned = order['contractSigned'] == true;
    final contractNotes = order['contractNotes']?.toString() ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Order Info Card
                    Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 24),
                      decoration: ColorManager.adminPanelCardDecoration(
                          borderRadius: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: GoogleFonts.albertSans(
                              color: ColorManager.textPrimary,
                              fontSize: isMobile ? 24 : 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildDetailRow('Client Name', clientName, isMobile),
                          _buildDetailRow('Email', clientEmail, isMobile),
                          _buildDetailRow('Phone',
                              order['clientPhone']?.toString() ?? '', isMobile),
                          _buildDetailRow(
                              'Company',
                              order['clientCompany']?.toString() ?? '',
                              isMobile),
                          _buildDetailRow('App Type',
                              order['appType']?.toString() ?? '', isMobile),
                          _buildDetailRow(
                              'Description',
                              order['appDescription']?.toString() ?? '',
                              isMobile),
                          _buildDetailRow('Features',
                              order['appFeatures']?.toString() ?? '', isMobile),
                          _buildDetailRow('Budget',
                              order['budget']?.toString() ?? '', isMobile),
                          _buildDetailRow('Timeline',
                              order['timeline']?.toString() ?? '', isMobile),
                          _buildDetailRow('Priority',
                              order['priority']?.toString() ?? '', isMobile),
                          _buildDetailRow('Design Style',
                              order['designStyle']?.toString() ?? '', isMobile),
                          _buildDetailRow(
                              'Design Complexity',
                              order['designComplexity']?.toString() ?? '',
                              isMobile),
                          _buildDetailRow('Color Scheme',
                              order['colorScheme']?.toString() ?? '', isMobile),
                          _buildDetailRow(
                              'Design Inspiration',
                              order['designInspiration']?.toString() ?? '',
                              isMobile),
                          _buildDetailRow(
                              'Brand Guidelines',
                              order['brandGuidelines']?.toString() ?? '',
                              isMobile),
                          _buildDetailRow(
                              'Platforms',
                              (order['selectedPlatforms'] as List?)
                                      ?.join(', ') ??
                                  '',
                              isMobile),
                          _buildDetailRow(
                              'Additional Notes',
                              order['additionalNotes']?.toString() ?? '',
                              isMobile),
                          _buildDetailRow(
                              'Status',
                              order['status']?.toString() ?? 'pending',
                              isMobile),
                          if (order['createdAt'] != null)
                            _buildDetailRow(
                              'Created',
                              order['createdAt'].toString().length > 19
                                  ? order['createdAt']
                                      .toString()
                                      .substring(0, 19)
                                  : order['createdAt'].toString(),
                              isMobile,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Existing Response
                    if (existingResponse.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(isMobile ? 20 : 24),
                        decoration: BoxDecoration(
                          color: ColorManager.containerSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                Colors.green.shade600.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Previous Response',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              existingResponse,
                              style: TextStyle(
                                color: ColorManager.textPrimary,
                                fontSize: isMobile ? 14 : 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 20 : 24),
                    ],

                    // Client Response
                    if (clientResponse.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(isMobile ? 20 : 24),
                        decoration: BoxDecoration(
                          color: ColorManager.containerSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorManager.primaryTeal
                                .withValues(alpha: 0.55),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person,
                                    color: ColorManager.primaryTeal, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Client Response',
                                  style: TextStyle(
                                    color: ColorManager.primaryTeal,
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              clientResponse,
                              style: TextStyle(
                                color: ColorManager.textPrimary,
                                fontSize: isMobile ? 14 : 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 20 : 24),
                    ],

                    // Response Form
                    Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 24),
                      decoration: ColorManager.orderFormCardDecoration(
                          borderRadius: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            existingResponse.isEmpty
                                ? 'Send Response to Client'
                                : 'Update Response',
                            style: GoogleFonts.albertSans(
                              color: ColorManager.textPrimary,
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          TextField(
                            controller: _responseController,
                            maxLines: 8,
                            style: TextStyle(color: ColorManager.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Type your response to the client...',
                              hintStyle:
                                  TextStyle(color: ColorManager.textMuted),
                              filled: true,
                              fillColor: ColorManager.containerSurface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: ColorManager.containerBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: ColorManager.containerBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: ColorManager.primaryTeal,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            SizedBox(height: 12),
                            Text(
                              _error!,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ],
                          SizedBox(height: isMobile ? 16 : 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitResponse,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.primaryTeal,
                                foregroundColor: ColorManager.backgroundDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                ColorManager.backgroundDark),
                                      ),
                                    )
                                  : Text(
                                      'Send Response',
                                      style: GoogleFonts.albertSans(
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Contract Section
                    Container(
                      padding: EdgeInsets.all(isMobile ? 20 : 24),
                      decoration: contractSent
                          ? BoxDecoration(
                              color: ColorManager.containerSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: contractSigned
                                    ? Colors.green.shade600
                                        .withValues(alpha: 0.45)
                                    : ColorManager.accentCoral
                                        .withValues(alpha: 0.55),
                                width: 1.5,
                              ),
                            )
                          : ColorManager.signUpAuthCardDecoration(
                              borderRadius: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: contractSent
                                    ? (contractSigned
                                        ? Colors.green.shade700
                                        : ColorManager.accentCoral)
                                    : ColorManager.secondaryPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Contract',
                                  style: GoogleFonts.albertSans(
                                    color: ColorManager.textPrimary,
                                    fontSize: isMobile ? 20 : 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (contractSent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: contractSigned
                                        ? Colors.green.withValues(alpha: 0.3)
                                        : Colors.orange.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    contractSigned ? 'SIGNED' : 'SENT',
                                    style: TextStyle(
                                      color: contractSigned
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: isMobile ? 12 : 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          if (contractSent) ...[
                            if (contractNotes.isNotEmpty) ...[
                              Text(
                                'Notes:',
                                style: TextStyle(
                                  color: ColorManager.textSecondary,
                                  fontSize: isMobile ? 14 : 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                contractNotes,
                                style: TextStyle(
                                  color: ColorManager.textPrimary,
                                  fontSize: isMobile ? 14 : 15,
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                            if (contractSigned) ...[
                              Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Contract has been signed by client',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: isMobile ? 14 : 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                'Contract sent. Waiting for client to sign.',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: isMobile ? 14 : 15,
                                ),
                              ),
                            ],
                          ] else ...[
                            Text(
                              'Send contract to client after agreement',
                              style: TextStyle(
                                color: ColorManager.textSecondary,
                                fontSize: isMobile ? 14 : 15,
                              ),
                            ),
                            SizedBox(height: 20),

                            // Final Price
                            Text(
                              'Final Price *',
                              style: TextStyle(
                                color: ColorManager.textSecondary,
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _finalPriceController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              style: TextStyle(
                                  color: ColorManager.textPrimary,
                                  fontSize: isMobile ? 16 : 18),
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(
                                    color: ColorManager.textMuted,
                                    fontSize: isMobile ? 16 : 18),
                                hintText: '0.00',
                                hintStyle:
                                    TextStyle(color: ColorManager.textMuted),
                                filled: true,
                                fillColor: ColorManager.containerSurface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.containerBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.containerBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.secondaryPurple,
                                      width: 2),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Down Payment
                            Text(
                              'Down Payment Amount *',
                              style: TextStyle(
                                color: ColorManager.textSecondary,
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _downPaymentController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              style: TextStyle(
                                  color: ColorManager.textPrimary,
                                  fontSize: isMobile ? 16 : 18),
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(
                                    color: ColorManager.textMuted,
                                    fontSize: isMobile ? 16 : 18),
                                hintText: '0.00',
                                hintStyle:
                                    TextStyle(color: ColorManager.textMuted),
                                filled: true,
                                fillColor: ColorManager.containerSurface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.containerBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.containerBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.secondaryPurple,
                                      width: 2),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Weekly Payment
                            Text(
                              'Weekly Payment Amount *',
                              style: TextStyle(
                                color: ColorManager.textSecondary,
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _weeklyPaymentController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              style: TextStyle(
                                  color: ColorManager.textPrimary,
                                  fontSize: isMobile ? 16 : 18),
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(
                                    color: ColorManager.textMuted,
                                    fontSize: isMobile ? 16 : 18),
                                hintText: '0.00',
                                hintStyle:
                                    TextStyle(color: ColorManager.textMuted),
                                helperText:
                                    'Payments triggered after weekly progress reports',
                                helperStyle: TextStyle(
                                    color: ColorManager.textMuted,
                                    fontSize: 12),
                                filled: true,
                                fillColor: ColorManager.containerSurface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.containerBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.containerBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.secondaryPurple,
                                      width: 2),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Contract Notes
                            Text(
                              'Contract Notes (Optional)',
                              style: TextStyle(
                                color: ColorManager.textSecondary,
                                fontSize: isMobile ? 14 : 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _contractNotesController,
                              maxLines: 4,
                              style: const TextStyle(
                                  color: ColorManager.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Additional notes or instructions...',
                                hintStyle:
                                    TextStyle(color: ColorManager.textMuted),
                                filled: true,
                                fillColor: ColorManager.containerSurface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.containerBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.containerBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: ColorManager.secondaryPurple,
                                      width: 2),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isSendingContract ? null : _sendContract,
                                icon: Icon(Icons.send,
                                    color: ColorManager.onDarkPrimary),
                                label: Text(
                                  'Send Contract',
                                  style: GoogleFonts.albertSans(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.secondaryPurple,
                                  foregroundColor: ColorManager.onDarkPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }

  Future<void> _sendContract() async {
    // Validate required fields
    if (_finalPriceController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter the final price';
      });
      return;
    }
    if (_downPaymentController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter the down payment amount';
      });
      return;
    }
    if (_weeklyPaymentController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter the weekly payment amount';
      });
      return;
    }

    final finalPrice = double.tryParse(_finalPriceController.text.trim());
    final downPayment = double.tryParse(_downPaymentController.text.trim());
    final weeklyPayment = double.tryParse(_weeklyPaymentController.text.trim());

    if (finalPrice == null || finalPrice <= 0) {
      setState(() {
        _error = 'Please enter a valid final price';
      });
      return;
    }
    if (downPayment == null || downPayment <= 0) {
      setState(() {
        _error = 'Please enter a valid down payment amount';
      });
      return;
    }
    if (weeklyPayment == null || weeklyPayment <= 0) {
      setState(() {
        _error = 'Please enter a valid weekly payment amount';
      });
      return;
    }
    if (downPayment >= finalPrice) {
      setState(() {
        _error = 'Down payment must be less than final price';
      });
      return;
    }

    setState(() {
      _isSendingContract = true;
      _error = null;
    });

    try {
      final orderId = widget.order['id'] as String;
      await _orderService.sendContract(
        orderId: orderId,
        finalPrice: finalPrice,
        downPaymentAmount: downPayment,
        weeklyPaymentAmount: weeklyPayment,
        contractNotes: _contractNotesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contract sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onResponseAdded(); // Refresh the order list
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to send contract: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send contract: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingContract = false;
        });
      }
    }
  }
}
