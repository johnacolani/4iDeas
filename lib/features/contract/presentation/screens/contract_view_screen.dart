import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../helper/app_background.dart';

class ContractViewScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const ContractViewScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    final finalPrice = (order['finalPrice'] ?? 0.0) as num;
    final downPaymentAmount = (order['downPaymentAmount'] ?? 0.0) as num;
    final weeklyPaymentAmount = (order['weeklyPaymentAmount'] ?? 0.0) as num;
    final numberOfWeeks = (order['numberOfWeeks'] ?? 0) as int;
    final totalWeeklyPayments = (order['totalWeeklyPayments'] ?? 0.0) as num;
    final finalPaymentAmount = (order['finalPaymentAmount'] ?? 0.0) as num;
    final contractNotes = order['contractNotes']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: const Color(0xff020923),
        title: Text(
          'Service Agreement',
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
          SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contract Header
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
                    children: [
                      Icon(Icons.description, color: Colors.purple, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'SERVICE AGREEMENT',
                        style: GoogleFonts.albertSans(
                          color: Colors.white,
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        order['appName']?.toString() ?? 'Project',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: isMobile ? 18 : 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Parties Section
                _buildSection(
                  'PARTIES',
                  [
                    _buildSubsection(
                      'Service Provider',
                      [
                        '4iDeas',
                        'Based in Richmond, VA',
                      ],
                      isMobile,
                    ),
                    SizedBox(height: 16),
                    _buildSubsection(
                      'Client',
                      [
                        order['clientName']?.toString() ?? 'N/A',
                        order['clientEmail']?.toString() ?? 'N/A',
                        if (order['clientPhone']?.toString().isNotEmpty == true)
                          order['clientPhone'].toString(),
                        if (order['clientCompany']?.toString().isNotEmpty == true)
                          order['clientCompany'].toString(),
                      ],
                      isMobile,
                    ),
                  ],
                  isMobile,
                ),

                // Project Details
                _buildSection(
                  'PROJECT DETAILS',
                  [
                    _buildDetailRow('Project Name', order['appName']?.toString() ?? 'N/A', isMobile),
                    _buildDetailRow('Project Type', order['appType']?.toString() ?? 'N/A', isMobile),
                    _buildDetailRow('Platform(s)', (order['selectedPlatforms'] as List?)?.join(', ') ?? 'N/A', isMobile),
                    if (order['appDescription']?.toString().isNotEmpty == true)
                      _buildDetailRow('Description', order['appDescription'].toString(), isMobile, isMultiline: true),
                  ],
                  isMobile,
                ),

                // Financial Terms
                _buildSection(
                  'FINANCIAL TERMS',
                  [
                    _buildFinancialCard(
                      'Total Project Cost',
                      '\$${finalPrice.toStringAsFixed(2)}',
                      Colors.purple,
                      isMobile,
                    ),
                    SizedBox(height: 16),
                    _buildSubsection(
                      'Payment Schedule',
                      null,
                      isMobile,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPaymentItem(
                            'Down Payment',
                            '\$${downPaymentAmount.toStringAsFixed(2)}',
                            'Due upon contract signing',
                            Colors.orange,
                            isMobile,
                          ),
                          SizedBox(height: 12),
                          _buildPaymentItem(
                            'Weekly Payments',
                            '\$${weeklyPaymentAmount.toStringAsFixed(2)} per week',
                            '$numberOfWeeks weeks × \$${weeklyPaymentAmount.toStringAsFixed(2)} = \$${totalWeeklyPayments.toStringAsFixed(2)}',
                            Colors.blue,
                            isMobile,
                          ),
                          SizedBox(height: 12),
                          _buildPaymentItem(
                            'Final Payment',
                            '\$${finalPaymentAmount.toStringAsFixed(2)}',
                            'Due upon project completion',
                            Colors.green,
                            isMobile,
                          ),
                        ],
                      ),
                    ),
                  ],
                  isMobile,
                ),

                // Payment Methods
                _buildSection(
                  'PAYMENT METHODS',
                  [
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.white.withValues(alpha: 0.7), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Stripe (Credit/Debit Card), PayPal, Bank Transfer',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: isMobile ? 14 : 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                  isMobile,
                ),

                // Project Timeline
                if (order['timeline']?.toString().isNotEmpty == true)
                  _buildSection(
                    'PROJECT TIMELINE',
                    [
                      _buildDetailRow('Target Completion', order['timeline'].toString(), isMobile),
                      _buildDetailRow('Priority Level', order['priority']?.toString() ?? 'Normal', isMobile),
                    ],
                    isMobile,
                  ),

                // Terms and Conditions
                _buildSection(
                  'TERMS AND CONDITIONS',
                  [
                    _buildTermItem(
                      '1. Scope of Work',
                      'This contract covers the development services as described. Changes may require additional agreement.',
                      isMobile,
                    ),
                    SizedBox(height: 12),
                    _buildTermItem(
                      '2. Progress Reports',
                      'Service Provider will provide weekly progress reports. Weekly payments become due upon report delivery.',
                      isMobile,
                    ),
                    SizedBox(height: 12),
                    _buildTermItem(
                      '3. Payment Terms',
                      'Down payment required before commencement. Weekly payments due within 7 days of progress report. Final payment due upon completion.',
                      isMobile,
                    ),
                    SizedBox(height: 12),
                    _buildTermItem(
                      '4. Intellectual Property',
                      'Upon final payment, all deliverables and intellectual property transfer to the Client.',
                      isMobile,
                    ),
                  ],
                  isMobile,
                ),

                // Additional Notes
                if (contractNotes.isNotEmpty)
                  _buildSection(
                    'ADDITIONAL NOTES',
                    [
                      Text(
                        contractNotes,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: isMobile ? 14 : 15,
                        ),
                      ),
                    ],
                    isMobile,
                  ),

                // Signatures Section
                _buildSection(
                  'SIGNATURES',
                  [
                    _buildSignatureBox('Service Provider: 4iDeas', order['contractSignedBy'] != null, isMobile),
                    SizedBox(height: 16),
                    _buildSignatureBox('Client: ${order['clientName'] ?? 'N/A'}', order['contractSigned'] == true, isMobile),
                  ],
                  isMobile,
                ),

                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.albertSans(
              color: Colors.white,
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubsection(String title, List<String>? items, bool isMobile, {Widget? child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 16 : 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        if (child != null)
          child
        else if (items != null)
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $item',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isMobile ? 14 : 15,
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isMobile, {bool isMultiline = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 15,
            ),
            maxLines: isMultiline ? null : 3,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(String label, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(String label, String amount, String description, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      amount,
                      style: TextStyle(
                        color: color,
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String number, String description, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: isMobile ? 14 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureBox(String label, bool signed, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: signed ? Colors.green.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: signed ? Colors.green.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (signed)
                Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            signed ? 'Signed' : 'Signature',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: isMobile ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

