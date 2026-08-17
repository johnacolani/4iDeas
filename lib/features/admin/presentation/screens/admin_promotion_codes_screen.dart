import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

  List<PromotionCodeView>? _codes;
  bool _loading = true;
  bool _creating = false;
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
      final codes = await _service.listPromotionCodes();
      if (mounted) setState(() => _codes = codes);
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
            'Creates real Stripe Coupons and Promotion Codes scoped to 4iCAD. '
            'Generate a batch to hand out one at a time — each is single-use, so '
            'it shows as USED here the moment a customer redeems it.',
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
              'Codes look like 4ICAD$_percentOff-K7QF2P. Nothing is emailed — '
              'copy one from the list and send it however you like.',
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
    final codes = _codes ?? const <PromotionCodeView>[];
    if (codes.isEmpty) {
      return FourICadGlassPanel(
        child: Text(
          'No promotion codes exist yet.',
          style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
        ),
      );
    }
    // Spendable codes first: the stock you can still hand out is the thing you
    // came here for, and spent ones are history.
    final sorted = [...codes]..sort((a, b) {
        if (a.isSpent != b.isSpent) return a.isSpent ? 1 : -1;
        final ad = a.createdAt, bd = b.createdAt;
        if (ad == null || bd == null) return 0;
        return bd.compareTo(ad);
      });

    return Column(
      children: [
        for (final code in sorted)
          Padding(
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
                            // A spent code is greyed so the stock still in play
                            // reads at a glance.
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
                      // Only a still-spendable code can be switched off. A used
                      // one is finished, and the toggle would imply otherwise.
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
          ),
      ],
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
