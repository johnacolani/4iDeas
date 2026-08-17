import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/commerce_data.dart';
import 'package:four_ideas/features/admin/presentation/widgets/admin_access_denied.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/services/commerce_admin_service.dart';

/// Detail view for one product order, addressed by Checkout Session id in the
/// path (`/admin/4icad/orders/:sessionId`).
///
/// The order is loaded from that id rather than passed through `state.extra`,
/// so the page survives a refresh and can be linked to directly.
class AdminProductOrderDetailScreen extends StatefulWidget {
  const AdminProductOrderDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<AdminProductOrderDetailScreen> createState() =>
      _AdminProductOrderDetailScreenState();
}

class _AdminProductOrderDetailScreenState extends State<AdminProductOrderDetailScreen> {
  final CommerceAdminService _service = CommerceAdminService();

  ProductOrder? _order;
  bool? _entitled;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('product_orders')
          .doc(widget.sessionId)
          .get();
      if (!doc.exists || doc.data() == null) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = 'No order exists with that Checkout Session id.';
          });
        }
        return;
      }
      final order = ProductOrder.fromMap(doc.id, doc.data()!);
      final entitled = order.uid.isEmpty
          ? false
          : await _service.entitlementActive(order.uid, order.productKey);
      if (!mounted) return;
      setState(() {
        _order = order;
        _entitled = entitled;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load this order. Confirm your administrator access.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AdminService.isAdmin()) {
      return const AdminAccessDenied(title: 'Order detail');
    }
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        // Opened by id from the orders list, and just as often from a pasted
        // link, so it falls back to the list rather than to home.
        leading: FrostedAppBar.backLeading(
          context,
          fallback: AppRoutes.adminProductOrders,
          tooltip: 'Back to 4iCAD orders',
        ),
        title: Text(
          'Order detail',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 18 : 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: _body(isMobile),
          ),
        ],
      ),
    );
  }

  Widget _body(bool isMobile) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: ColorManager.accentGold));
    }
    if (_error != null || _order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            _error ?? 'Order not found.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 15),
          ),
        ),
      );
    }

    final o = _order!;
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FourICadGlassPanel(
                  goldBorder: true,
                  padding: EdgeInsets.all(isMobile ? 20 : 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.customerEmail ?? '(no email on file)',
                        style: GoogleFonts.roboto(
                          fontSize: isMobile ? 19 : 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FourICadMetaChip(label: o.status.toUpperCase(), emphasise: o.isCompleted),
                          FourICadMetaChip(
                            label: _entitled == true ? 'ENTITLEMENT ACTIVE' : 'NO ENTITLEMENT',
                            icon: _entitled == true ? Icons.key : Icons.key_off,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FourICadGlassPanel(
                  padding: EdgeInsets.all(isMobile ? 20 : 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Product', o.productKey),
                      _row('Purchase date',
                          o.purchasedAt == null ? '—' : _formatDateTime(o.purchasedAt!)),
                      _row('Original price',
                          ProductOrder.formatMinor(o.originalAmount, o.currency)),
                      _row(
                        'Discount',
                        o.amountDiscount == null || o.amountDiscount == 0
                            ? 'None'
                            : '−${ProductOrder.formatMinor(o.amountDiscount, o.currency)}'
                                '${o.percentOff != null ? '  (${o.percentOff!.toInt()}%)' : ''}',
                      ),
                      _row('Promotion code', o.promotionCode ?? 'None'),
                      _row('Amount paid',
                          ProductOrder.formatMinor(o.amountPaid, o.currency), emphasise: true),
                      _row('Currency', (o.currency ?? '—').toUpperCase()),
                      _row('Payment status', o.paymentStatus ?? '—'),
                      _row('Checkout Session', o.checkoutSessionId, monospace: true),
                      _row('PaymentIntent', o.paymentIntentId ?? 'None (no payment required)',
                          monospace: true),
                      _row('Firebase uid', o.uid.isEmpty ? '—' : o.uid, monospace: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FourICadGlassPanel(
                  padding: EdgeInsets.all(isMobile ? 18 : 22),
                  borderRadius: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 19, color: ColorManager.accentGold),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          'Order records are written only by the verified Stripe webhook '
                          'and cannot be edited here. To refund or amend a payment, use the '
                          'Stripe Dashboard — Stripe remains the record of truth.',
                          style: GoogleFonts.roboto(
                            fontSize: 13.5,
                            height: 1.5,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool monospace = false, bool emphasise = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12.5,
              letterSpacing: 0.3,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: monospace
                ? GoogleFonts.robotoMono(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  )
                : GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: emphasise ? FontWeight.w700 : FontWeight.w600,
                    color: emphasise ? ColorManager.accentGold : Colors.white,
                  ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year}, $hh:$mm';
  }
}
