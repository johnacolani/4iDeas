import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

/// Read-only admin view of 4iCAD product orders.
///
/// Payment truth belongs to Stripe and the webhook, so nothing here can edit an
/// order — Firestore rules forbid client writes to order documents outright.
class AdminProductOrdersScreen extends StatefulWidget {
  const AdminProductOrdersScreen({super.key});

  @override
  State<AdminProductOrdersScreen> createState() => _AdminProductOrdersScreenState();
}

class _AdminProductOrdersScreenState extends State<AdminProductOrdersScreen> {
  final CommerceAdminService _service = CommerceAdminService();

  @override
  Widget build(BuildContext context) {
    if (!AdminService.isAdmin()) {
      return const AdminAccessDenied(title: '4iCAD orders');
    }
    final isMobile = MediaQuery.of(context).size.width < 760;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        leading: FrostedAppBar.backLeading(context),
        title: Text(
          '4iCAD orders',
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
            child: StreamBuilder<List<ProductOrder>>(
              stream: _service.watchOrders(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return _message('Could not load orders. Confirm your administrator access.');
                }
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: ColorManager.accentGold),
                  );
                }
                final orders = snap.data!;
                if (orders.isEmpty) {
                  return _message('No 4iCAD orders yet.');
                }
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${orders.length} order${orders.length == 1 ? '' : 's'}',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 14),
                            for (final order in orders)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _orderTile(order, isMobile),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 15),
          ),
        ),
      );

  Widget _orderTile(ProductOrder order, bool isMobile) {
    final statusColor = switch (order.status) {
      'completed' => const Color(0xFF67C79B),
      'expired' => const Color(0xFFDFB362),
      'failed' => const Color(0xFFE98D82),
      _ => Colors.white70,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.go(AppRoutes.adminProductOrderPath(order.checkoutSessionId)),
      child: FourICadGlassPanel(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.customerEmail ?? '(no email on file)',
                    style: GoogleFonts.roboto(
                      fontSize: isMobile ? 15 : 16.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  ProductOrder.formatMinor(order.amountPaid, order.currency),
                  style: GoogleFonts.robotoMono(
                    fontSize: isMobile ? 14 : 15.5,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FourICadMetaChip(label: order.status.toUpperCase()),
                if (order.purchasedAt != null)
                  FourICadMetaChip(label: _formatDate(order.purchasedAt!)),
                if (order.promotionCode != null)
                  FourICadMetaChip(
                    label: '${order.promotionCode}'
                        '${order.percentOff != null ? ' · ${order.percentOff!.toInt()}% off' : ''}',
                    icon: Icons.local_offer_outlined,
                    emphasise: true,
                  ),
                if (order.isFreeRedemption)
                  const FourICadMetaChip(label: 'FREE REDEMPTION'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: statusColor),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    order.checkoutSessionId,
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 18, color: Colors.white.withValues(alpha: 0.4)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
