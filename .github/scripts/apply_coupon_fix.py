from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected exactly one match, found {count}")
    return text.replace(old, new, 1)


# Backend: expose the real Stripe product scope and keep stock counts limited
# to the new all-product codes.
path = Path("functions/src/stripe/promotions.ts")
text = path.read_text()
marker = '} from "./promotion-policy";\n\n'
helper = '''} from "./promotion-policy";

type PromotionProductScope = "all" | "windows";

/**
 * New coupons are unrestricted. Legacy coupons were explicitly restricted to
 * the Windows Stripe product, so Stripe's applies_to list is the source of
 * truth when separating the two generations in the admin screen.
 */
function productScope(promo: Stripe.PromotionCode): PromotionProductScope {
  if (promo.metadata?.productScope === "all") return "all";
  if (typeof promo.coupon === "string") return "windows";
  const products = promo.coupon.applies_to?.products;
  return products && products.length > 0 ? "windows" : "all";
}

'''
text = replace_once(text, marker, helper, "backend scope helper")
text = replace_once(
    text,
    "        code: promo.code,\n        percentOff,",
    "        code: promo.code,\n        productScope: \"all\",\n        percentOff,",
    "created code scope",
)
text = replace_once(
    text,
    "        code: p.code,\n        active: p.active,",
    "        code: p.code,\n        productScope: productScope(p),\n        active: p.active,",
    "listed code scope",
)
text = replace_once(
    text,
    '''      stock: summariseStock(
        list.data.map((p) => ({
          percentOff: typeof p.coupon === "string" ? null : p.coupon.percent_off,
          status: codeStatus(p, now),
        }))
      ),''',
    '''      stock: summariseStock(
        list.data
          .filter((p) => productScope(p) === "all")
          .map((p) => ({
            percentOff: typeof p.coupon === "string" ? null : p.coupon.percent_off,
            status: codeStatus(p, now),
          }))
      ),''',
    "all-product stock summary",
)
text = replace_once(
    text,
    '''    const allProductCodes = existing.data.filter((p) => {
      if (typeof p.coupon === "string") return false;
      const products = p.coupon.applies_to?.products;
      return !products || products.length === 0;
    });''',
    '''    const allProductCodes = existing.data.filter((p) => productScope(p) === "all");''',
    "restock scope filter",
)
path.write_text(text)


# Flutter model: carry the scope returned by the backend.
path = Path("lib/services/commerce_admin_service.dart")
text = path.read_text()
text = replace_once(
    text,
    "}\n\n/// Who spent a code, joined from the order the webhook wrote.",
    '''}

enum PromotionProductScope {
  /// Works with every 4iCAD product sold through Stripe.
  all,

  /// Legacy code restricted to the original Windows Stripe product.
  windows,
}

/// Who spent a code, joined from the order the webhook wrote.''',
    "scope enum",
)
text = replace_once(
    text,
    "    required this.active,\n    this.status = PromotionCodeStatus.active,",
    "    required this.active,\n    this.productScope = PromotionProductScope.all,\n    this.status = PromotionCodeStatus.active,",
    "scope constructor",
)
text = replace_once(
    text,
    "  final bool active;\n  final PromotionCodeStatus status;",
    "  final bool active;\n  final PromotionProductScope productScope;\n  final PromotionCodeStatus status;",
    "scope field",
)
text = replace_once(
    text,
    "      active: map['active'] as bool? ?? false,\n      status: switch (map['status'] as String?) {",
    "      active: map['active'] as bool? ?? false,\n      productScope: map['productScope'] == 'windows'\n          ? PromotionProductScope.windows\n          : PromotionProductScope.all,\n      status: switch (map['status'] as String?) {",
    "scope parsing",
)
path.write_text(text)


# Admin UI: scope-aware email and two clearly separated code groups.
path = Path("lib/features/admin/presentation/screens/admin_promotion_codes_screen.dart")
text = path.read_text()

send_start = text.index("  Future<void> _send(PromotionCodeView code) async {")
send_end = text.index("  /// Puts a code on the clipboard", send_start)
send_block = r'''  Future<void> _send(PromotionCodeView code) async {
    final controller = TextEditingController(text: code.sentTo ?? '');
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1428),
        title: Text(
          'Send ${code.code}',
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opens your email app with the code written out. The address is '
              'recorded here so you can see who it went to.',
              style: GoogleFonts.roboto(
                fontSize: 13.5,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
              decoration: InputDecoration(
                hintText: 'customer@example.com',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            icon: const Icon(Icons.mail_outline, size: 17),
            label: const Text('Compose email'),
            style: FilledButton.styleFrom(
              backgroundColor: ColorManager.accentGold,
              foregroundColor: const Color(0xFF1A1305),
            ),
          ),
        ],
      ),
    );
    controller.dispose();

    if (email == null || email.isEmpty || !mounted) return;

    final allProducts = code.productScope == PromotionProductScope.all;
    final percent = code.percentOff?.toInt();
    final subjectText =
        'Your ${percent == null ? '' : '$percent% '}discount code for '
        '${allProducts ? '4iCAD' : '4iCAD for Windows'}';
    final bodyText =
        'Hello,\n\n'
        'Here is your discount code for '
        '${allProducts ? '4iCAD' : '4iCAD for Windows'}:\n\n'
        '    ${code.code}\n\n'
        '${allProducts ? 'This code works with every 4iCAD product available through our Stripe checkout.' : 'This is a legacy code and it works with 4iCAD for Windows only.'}\n\n'
        'To use it, go to https://4ideasapp.com/4icad, sign in and press Buy. '
        'On the payment page, choose "Add promotion code" and enter the code '
        'above — the discount is applied before you pay.\n\n'
        'The code works once.\n\n'
        'Thank you,\n4iDeas';
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _emailQuery(<String, String>{
        'subject': subjectText,
        'body': bodyText,
      }),
    );

    // Launch first, while this is still part of the user's click. On Flutter
    // Web, waiting for the Cloud Function first can lose browser user-activation
    // and mailto then opens unreliably. _top also avoids an extra blank tab.
    bool launched = false;
    try {
      launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_top',
      );
    } catch (_) {
      launched = false;
    }
    if (!mounted) return;

    if (!launched) {
      await Clipboard.setData(
        ClipboardData(text: 'To: $email\nSubject: $subjectText\n\n$bodyText'),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email app opened. The complete email is on your clipboard.'),
        ),
      );
    }

    try {
      await _service.assignPromotionCode(id: code.id, sentTo: email);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            launched
                ? 'Email composer opened, but the recipient could not be recorded.'
                : _message(e, 'Could not record the recipient.'),
          ),
          backgroundColor: const Color(0xFF9B3A31),
        ),
      );
      return;
    }

    await _load();
  }

  static String _emailQuery(Map<String, String> values) => values.entries
      .map((entry) =>
          '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
      .join('&');

'''
text = text[:send_start] + send_block + text[send_end:]

list_start = text.index("  Widget _list(bool isMobile) {")
list_end = text.index("  /// Who spent the code", list_start)
list_block = r'''  Widget _list(bool isMobile) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: ColorManager.accentGold)),
      );
    }
    if (_listError != null) {
      return FourICadGlassPanel(
        child: Text(
          _listError!,
          style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
      );
    }
    final codes = _board?.codes ?? const <PromotionCodeView>[];
    if (codes.isEmpty) {
      return FourICadGlassPanel(
        child: Text(
          'No promotion codes exist yet.',
          style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
        ),
      );
    }

    // Keep usable stock above history inside each scope, then keep the two
    // generations visibly separate so an old Windows-only code can never be
    // mistaken for a current all-product code.
    final sorted = [...codes]..sort((a, b) {
        if (a.isSpent != b.isSpent) return a.isSpent ? 1 : -1;
        final ad = a.createdAt, bd = b.createdAt;
        if (ad == null || bd == null) return 0;
        return bd.compareTo(ad);
      });
    final allProducts = sorted
        .where((code) => code.productScope == PromotionProductScope.all)
        .toList();
    final windowsOnly = sorted
        .where((code) => code.productScope == PromotionProductScope.windows)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allProducts.isNotEmpty)
          _scopeSection(
            title: 'All products',
            subtitle: 'Current codes — Windows, Web, Linux and future Stripe products.',
            icon: Icons.public,
            codes: allProducts,
            isMobile: isMobile,
          ),
        if (allProducts.isNotEmpty && windowsOnly.isNotEmpty)
          const SizedBox(height: 24),
        if (windowsOnly.isNotEmpty)
          _scopeSection(
            title: 'Windows only · legacy',
            subtitle: 'Older codes restricted to the original Windows Stripe product.',
            icon: Icons.window,
            codes: windowsOnly,
            isMobile: isMobile,
          ),
      ],
    );
  }

  Widget _scopeSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<PromotionCodeView> codes,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 19, color: ColorManager.accentGold),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$title · ${codes.length}',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (final code in codes) _codeCard(code, isMobile),
      ],
    );
  }

  Widget _codeCard(PromotionCodeView code, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                    code.code,
                    style: GoogleFonts.robotoMono(
                      fontSize: isMobile ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      color: code.isSpent ? Colors.white54 : Colors.white,
                      decoration: code.isUsed ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white38,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copy(code),
                  icon: const Icon(Icons.copy_all_outlined, size: 18),
                  color: Colors.white70,
                  tooltip: 'Copy code',
                ),
                if (!code.isSpent)
                  IconButton(
                    onPressed: () => _send(code),
                    icon: const Icon(Icons.mail_outline, size: 19),
                    color: ColorManager.accentGold,
                    tooltip: 'Send by email',
                  ),
                if (!code.isUsed)
                  Switch(
                    value: code.active,
                    onChanged: (_) => _toggle(code),
                    activeThumbColor: ColorManager.accentGold,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusChip(code.status),
                FourICadMetaChip(
                  label: code.productScope == PromotionProductScope.all
                      ? 'ALL PRODUCTS'
                      : 'WINDOWS ONLY',
                  icon: code.productScope == PromotionProductScope.all
                      ? Icons.public
                      : Icons.window,
                  emphasise: code.productScope == PromotionProductScope.all,
                ),
                if (code.percentOff != null)
                  FourICadMetaChip(
                    label: '${code.percentOff!.toInt()}% off',
                    emphasise: !code.isSpent,
                  ),
                FourICadMetaChip(
                  label: code.maxRedemptions == null
                      ? '${code.timesRedeemed} redeemed'
                      : '${code.timesRedeemed}/${code.maxRedemptions} redeemed',
                ),
                if (code.expiresAt != null)
                  FourICadMetaChip(
                    label: 'Expires ${_date(code.expiresAt!)}',
                    icon: Icons.event,
                  ),
                if (code.firstTimeOnly)
                  const FourICadMetaChip(label: 'FIRST-TIME ONLY'),
              ],
            ),
            if (code.sentTo != null && code.sentTo!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.outgoing_mail, size: 15, color: Colors.white38),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sent to ${code.sentTo}'
                      '${code.sentAt == null ? '' : ' on ${_date(code.sentAt!)}'}',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (code.note != null && code.note!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined,
                      size: 15, color: Colors.white38),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      code.note!,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (code.redeemedBy != null) _redeemedLine(code, isMobile),
          ],
        ),
      ),
    );
  }

'''
text = text[:list_start] + list_block + text[list_end:]

text = replace_once(
    text,
    "                  'Code stock',",
    "                  'All-products code stock',",
    "stock title",
)
text = replace_once(
    text,
    "            'Five single-use codes per discount. Send one to a customer and it '\n            'moves to used the moment they redeem it at checkout.',",
    "            'Five single-use all-product codes per discount. Legacy Windows-only '\n            'codes are kept separate below and do not count toward this stock.',",
    "stock description",
)
text = replace_once(
    text,
    "            label: short == 0 ? 'All tiers full' : 'Top up to 5 per discount',",
    "            label: short == 0 ? 'All-product tiers full' : 'Top up all-product codes',",
    "stock button",
)
text = replace_once(
    text,
    "            'Creates real Stripe Coupons and Promotion Codes scoped to 4iCAD. '\n            'Generate a batch to hand out one at a time — each is single-use, so '\n            'it shows as USED here the moment a customer redeems it.',",
    "            'Creates real Stripe Coupons and Promotion Codes that work across every '\n            '4iCAD product sold through Stripe. Generate a batch to hand out one '\n            'at a time — each is single-use and tracked here after redemption.',",
    "create description",
)
text = replace_once(
    text,
    "              'Codes look like 4ICAD$_percentOff-K7QF2P. Nothing is emailed — '\n              'copy one from the list and send it however you like.',",
    "              'Codes look like 4ICAD$_percentOff-K7QF2P. Use Copy or Send by '\n              'email from the list below.',",
    "generated codes help",
)
path.write_text(text)
