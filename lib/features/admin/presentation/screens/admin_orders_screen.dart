import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/ColorManager.dart';
import '../../../../helper/app_background.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/order_service.dart';
import 'admin_order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!AdminService.isAdmin()) {
      // Redirect if not admin
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Admin only.'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _orderService.getAllOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load orders: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;

    if (!AdminService.isAdmin()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: const Color(0xff020923),
        ),
        body: const Center(
          child: Text('Admin access required'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        title: Text(
          'Admin - Client Orders',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadOrders,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else if (_orders.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isMobile ? 18 : 20,
                    ),
                  ),
                ],
              ),
            )
          else
            Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return _buildOrderCard(order, isMobile);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isMobile) {
    final appName = order['appName']?.toString() ?? 'Untitled Order';
    final clientName = order['clientName']?.toString() ?? 'Unknown';
    final clientEmail = order['clientEmail']?.toString() ?? '';
    final status = order['status']?.toString() ?? 'pending';
    final createdAt = order['createdAt']?.toString() ?? '';
    final hasResponse = order['adminResponse'] != null && order['adminResponse'].toString().isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      color: Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasResponse ? Colors.green.withValues(alpha: 0.5) : ColorManager.blue.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminOrderDetailScreen(
                order: order,
                onResponseAdded: () {
                  _loadOrders(); // Refresh list after response
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appName,
                          style: GoogleFonts.albertSans(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Client: $clientName',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                        Text(
                          clientEmail,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasResponse
                              ? Colors.green.withValues(alpha: 0.3)
                              : ColorManager.orange.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hasResponse ? 'Responded' : status.toUpperCase(),
                          style: TextStyle(
                            color: hasResponse ? Colors.green : ColorManager.orange,
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (createdAt.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          createdAt.length > 19 ? createdAt.substring(0, 19) : createdAt,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: isMobile ? 10 : 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (hasResponse) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Response sent',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: isMobile ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

