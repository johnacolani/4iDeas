import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/features/admin/presentation/widgets/admin_access_denied.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/services/commerce_admin_service.dart';

/// Admin screen for the approved 4iCAD promotion-code tiers.
///
/// Every action here calls Stripe through an authenticated Cloud Function, so
/// what this screen shows is live Stripe state. Nothing about a discount is
/// written to Firestore and then trusted — Checkout stays authoritative.
class AdminPromotionCodesScreen extends StatefulWidget {
  const AdminPromotionCodesScreen({super.key});

  @override
  State<AdminPromotionCodesScreen> createState() => _AdminPromotionCodesScreenState();
}

class _AdminPromotionCodesScreenState extends State<AdminPromotionCodesScreen> {
  final CommerceAdminService _service = CommerceAdminService();
  final _codeController = TextEditingController();
  final _maxRedemptionsController = TextEditingController();
  final _noteController = TextEditingController();

  /// The only tiers the backend accepts.
  static const List<int> _tiers = [10, 30, 50, 70, 100];

  int _percentOff = 10;
  DateTime? _expiresAt;
  bool _firstTimeOnly = false;

  /// Generated codes are single-use by default: a code handed to one person
  /// should stop working once that person has used it, which is what makes the
  /// list below meaningful.
  int _count = 5;
  bool _generate = true;

  PromotionBoard? _board;
  bool _loading = true;
  bool _creating = false;
  bool _restocking = false;
  String? _error;
  String? _listError;

  @override
  void initState() {
    super.initState();
    _codeController.text = '4ICAD10';
    _load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _maxRedemptionsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _listError = null;
    });
    try {
      final board = await _service.listPromotionCodes();
      if (mounted) setState(() => _board = board);
    } catch (e) {
      if (mounted) {
        setState(() => _listError = _message(e, 'Could not load promotion codes from Stripe.'));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  /// Suggests the conventional code for a tier, but the admin can override it.
  void _onTierChanged(int percent) {
    setState(() {
      _percentOff = percent;
      final suggested = percent == 100 ? '4ICADFREE' : '4ICAD$percent';
      final current = _codeController.text.trim().toUpperCase();
      final wasSuggestion = _tiers.any(
        (t) => current == (t == 100 ? '4ICADFREE' : '4ICAD$t'),
      );
      if (current.isEmpty || wasSuggestion) _codeController.text = suggested;
    });
  }

  Future<void> _create() async {
    final code = _codeController.text.trim().toUpperCase();
    if (!_generate && !RegExp(r'^[A-Z0-9_-]{3,40}$').hasMatch(code)) {
      setState(() => _error = 'Use 3–40 characters: letters, digits, - or _.');
      return;
    }
    final maxText = _maxRedemptionsController.text.trim();
    int? maxRedemptions;
    if (maxText.isNotEmpty) {
      maxRedemptions = int.tryParse(maxText);
      if (maxRedemptions == null || maxRedemptions < 1) {
        setState(() => _error = 'Maximum redemptions must be a positive whole number.');
        return;
      }
    }
    // Generated codes are for handing out one by one, so they default to
    // single-use unless the admin deliberately says otherwise.
    if (_generate) maxRedemptions ??= 1;

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final created = await _service.createPromotionCodes(
        code: _generate ? null : code,
        count: _generate ? _count : 1,
        percentOff: _percentOff,
        maxRedemptions: maxRedemptions,
        expiresAt: _expiresAt,
        firstTimeOnly: _firstTimeOnly,
        note: _noteController.text,
      );
      if (!mounted) return;
      setState(() {
        _creating = false;
        _maxRedemptionsController.clear();
        _noteController.clear();
        _expiresAt = null;
        _firstTimeOnly = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            created.length == 1
                ? 'Created ${created.first.code} in Stripe.'
                : 'Created ${created.length} codes in Stripe.',
          ),
          backgroundColor: const Color(0xFF1B7F4B),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = _message(e, 'Could not create the promotion code.');
      });
    }
  }

  /// Brings every tier back to five spendable codes.
  Future<void> _restock() async {
    setState(() => _restocking = true);
    try {
      final created = await _service.restockPromotionCodes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            created == 0
                ? 'Every tier already has five codes.'
                : 'Created $created code${created == 1 ? '' : 's'}.',
          ),
          backgroundColor: const Color(0xFF1B7F4B),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message(e, 'Could not top up the codes.')),
          backgroundColor: const Color(0xFF9B3A31),
        ),
      );
    }
    if (mounted) setState(() => _restocking = false);
  }

  /// Records the recipient, then opens a pre-written email in the admin's own
  /// mail app.
  ///
  /// Deliberately not sent by the server: the site has no mail infrastructure,
  /// and a message that arrives from your own address is more likely to be read
  /// — and to be replied to — than one from a no-reply sender. The recipient is
  /// recorded either way, so the list can show who was given what.
  Future<void> _send(PromotionCodeView code) async {
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

  /// Puts a code on the clipboard so it can be pasted into a message or email.
  Future<void> _copy(PromotionCodeView code) async {
    await Clipboard.setData(ClipboardData(text: code.code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${code.code}.'),
        backgroundColor: const Color(0xFF1B7F4B),
      ),
    );
  }

  Future<void> _toggle(PromotionCodeView code) async {
    try {
      await _service.setPromotionCodeActive(code.id, !code.active);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message(e, 'Could not update that code.')),
          backgroundColor: const Color(0xFF9B3A31),
        ),
      );
    }
  }

  String _message(Object e, String fallback) {
    final text = e.toString();
    if (text.contains('already-exists')) {
      return 'That code already exists in Stripe. Choose a different one.';
    }
    if (text.contains('permission-denied')) return 'Administrator access required.';
    if (text.contains('failed-precondition') || text.contains('internal')) {
      return 'Stripe is not configured yet. Add the Stripe secret key first.';
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (!AdminService.isAdmin()) {
      return const AdminAccessDenied(title: 'Promotion codes');
    }
    final isMobile = MediaQuery.of(context).size.width < 760;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: ColorManager.accentGold),
        leading: FrostedAppBar.backLeading(context),
        title: Text(
          'Promotion codes',
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
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _stockCard(isMobile),
                        const SizedBox(height: 20),
                        _createCard(isMobile),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Text(
                              'Codes in Stripe',
                              style: GoogleFonts.roboto(
                                fontSize: isMobile ? 19 : 23,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _loading ? null : _load,
                              icon: const Icon(Icons.refresh, color: Colors.white70),
                              tooltip: 'Refresh',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _list(isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The screen's headline answer: how many codes are left to give away in each
  /// tier, and how many customers have spent one.
  Widget _stockCard(bool isMobile) {
    final stock = _board?.stock ?? const <TierStock>[];
    final short = stock.where((t) => t.missing > 0).length;

    return FourICadGlassPanel(
      goldBorder: true,
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'All-products code stock',
                  style: GoogleFonts.roboto(
                    fontSize: isMobile ? 18 : 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (_board != null)
                Text(
                  '${_board!.totalAvailable} available · ${_board!.totalUsed} used',
                  style: GoogleFonts.roboto(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Five single-use all-product codes per discount. Legacy Windows-only '
            'codes are kept separate below and do not count toward this stock.',
            style: GoogleFonts.roboto(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 18),
          if (_loading && _board == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: ColorManager.accentGold)),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [for (final tier in stock) _tierTile(tier, isMobile)],
            ),
          const SizedBox(height: 18),
          FourICadPrimaryButton(
            label: short == 0 ? 'All-product tiers full' : 'Top up all-product codes',
            icon: Icons.inventory_2_outlined,
            busy: _restocking,
            // Nothing to do when every tier is full, and a button that mints
            // nothing would only teach the admin to distrust it.
            onPressed: short == 0 ? null : _restock,
          ),
        ],
      ),
    );
  }

  Widget _tierTile(TierStock tier, bool isMobile) {
    final low = tier.available == 0;
    return Container(
      width: isMobile ? double.infinity : 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: low
              ? const Color(0xFFE98D82).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tier.percentOff}% off',
            style: GoogleFonts.roboto(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: ColorManager.accentGold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${tier.available}',
                style: GoogleFonts.robotoMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: low ? const Color(0xFFE98D82) : Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'available',
                style: GoogleFonts.roboto(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${tier.used} used'
            '${tier.unusable > 0 ? ' · ${tier.unusable} expired' : ''}',
            style: GoogleFonts.roboto(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createCard(bool isMobile) {
    return FourICadGlassPanel(
      goldBorder: true,
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a promotion code',
            style: GoogleFonts.roboto(
              fontSize: isMobile ? 18 : 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Creates real Stripe Coupons and Promotion Codes that work across every '
            '4iCAD product sold through Stripe. Generate a batch to hand out one '
            'at a time — each is single-use and tracked here after redemption.',
            style: GoogleFonts.roboto(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Discount',
            style: GoogleFonts.roboto(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final tier in _tiers)
                ChoiceChip(
                  label: Text('$tier%'),
                  selected: _percentOff == tier,
                  onSelected: _creating ? null : (_) => _onTierChanged(tier),
                  labelStyle: GoogleFonts.roboto(
                    fontWeight: FontWeight.w700,
                    color: _percentOff == tier ? const Color(0xFF1A1305) : Colors.white70,
                  ),
                  selectedColor: ColorManager.accentGold,
                  backgroundColor: Colors.white.withValues(alpha: 0.07),
                  side: BorderSide(
                    color: _percentOff == tier
                        ? ColorManager.accentGold
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                icon: Icon(Icons.auto_awesome, size: 17),
                label: Text('Generate codes'),
              ),
              ButtonSegment(
                value: false,
                icon: Icon(Icons.edit_outlined, size: 17),
                label: Text('Name one myself'),
              ),
            ],
            selected: {_generate},
            onSelectionChanged:
                _creating ? null : (s) => setState(() => _generate = s.first),
            style: SegmentedButton.styleFrom(
              foregroundColor: Colors.white70,
              selectedForegroundColor: const Color(0xFF1A1305),
              selectedBackgroundColor: ColorManager.accentGold,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
            ),
          ),
          const SizedBox(height: 18),
          if (_generate) ...[
            Text(
              'How many',
              style: GoogleFonts.roboto(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final n in const [1, 5, 10, 20])
                  ChoiceChip(
                    label: Text('$n'),
                    selected: _count == n,
                    onSelected: _creating ? null : (_) => setState(() => _count = n),
                    labelStyle: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      color: _count == n ? const Color(0xFF1A1305) : Colors.white70,
                    ),
                    selectedColor: ColorManager.accentGold,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                    side: BorderSide(
                      color: _count == n
                          ? ColorManager.accentGold
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Codes look like 4ICAD$_percentOff-K7QF2P. Use Copy or Send by '
              'email from the list below.',
              style: GoogleFonts.roboto(
                fontSize: 12.5,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ] else
            _field(_codeController, 'Customer-facing code', 'e.g. 4ICAD10',
                enabled: !_creating),
          const SizedBox(height: 14),
          _field(
            _noteController,
            'Note (optional)',
            'Who is this batch for? e.g. Trade show, Acme Ltd',
            enabled: !_creating,
          ),
          const SizedBox(height: 14),
          _field(
            _maxRedemptionsController,
            'Maximum redemptions (optional)',
            _generate ? 'Blank means single-use' : 'Leave blank for unlimited',
            enabled: !_creating,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  _expiresAt == null
                      ? 'No expiry'
                      : 'Expires ${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}',
                  style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
                ),
              ),
              TextButton.icon(
                onPressed: _creating
                    ? null
                    : () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: now.add(const Duration(days: 1)),
                          lastDate: now.add(const Duration(days: 365 * 3)),
                          initialDate: now.add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _expiresAt = picked);
                      },
                icon: const Icon(Icons.event, size: 17),
                label: const Text('Set expiry'),
                style: TextButton.styleFrom(foregroundColor: ColorManager.accentGold),
              ),
              if (_expiresAt != null)
                IconButton(
                  onPressed: _creating ? null : () => setState(() => _expiresAt = null),
                  icon: const Icon(Icons.clear, size: 18, color: Colors.white54),
                  tooltip: 'Clear expiry',
                ),
            ],
          ),
          CheckboxListTile(
            value: _firstTimeOnly,
            onChanged: _creating ? null : (v) => setState(() => _firstTimeOnly = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: ColorManager.accentGold,
            checkColor: const Color(0xFF1A1305),
            title: Text(
              'First-time customers only',
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 14.5),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.roboto(color: const Color(0xFFE98D82), fontSize: 13.5),
            ),
          ],
          const SizedBox(height: 18),
          FourICadPrimaryButton(
            label: _generate
                ? (_count == 1 ? 'Generate 1 code' : 'Generate $_count codes')
                : 'Create in Stripe',
            icon: _generate ? Icons.auto_awesome : Icons.local_offer_outlined,
            busy: _creating,
            onPressed: _create,
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ColorManager.accentGold, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _list(bool isMobile) {
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

  /// Who spent the code, joined from the order the Stripe webhook wrote. This
  /// is the only place the two halves meet: Stripe counts the redemption, our
  /// order record knows the person behind it.
  Widget _redeemedLine(PromotionCodeView code, bool isMobile) {
    final r = code.redeemedBy!;
    final who = r.email ?? r.uid ?? 'a customer';
    final when = r.at == null ? null : _date(r.at!);
    final saved = (r.amountDiscount ?? 0) > 0 && r.currency != null
        ? ' · saved ${_money(r.amountDiscount!, r.currency!)}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.person_outline, size: 16, color: Color(0xFF67C79B)),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Used by $who${when == null ? '' : ' on $when'}$saved',
                style: GoogleFonts.roboto(
                  fontSize: isMobile ? 13 : 13.5,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(PromotionCodeStatus status) {
    final (label, color) = switch (status) {
      PromotionCodeStatus.active => ('AVAILABLE', const Color(0xFF67C79B)),
      PromotionCodeStatus.used => ('USED', const Color(0xFFE98D82)),
      PromotionCodeStatus.expired => ('EXPIRED', const Color(0xFFE8B14C)),
      PromotionCodeStatus.disabled => ('DISABLED', Colors.white54),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: GoogleFonts.robotoMono(
          fontSize: 11.5,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  static String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  static String _money(int minor, String currency) {
    final amount = (minor / 100).toStringAsFixed(2);
    return currency.toLowerCase() == 'usd' ? '\$$amount' : '$amount ${currency.toUpperCase()}';
  }
}
