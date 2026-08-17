import 'package:flutter/material.dart';
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

  /// The only tiers the backend accepts.
  static const List<int> _tiers = [10, 30, 50, 70, 100];

  int _percentOff = 10;
  DateTime? _expiresAt;
  bool _firstTimeOnly = false;

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
    if (!RegExp(r'^[A-Z0-9_-]{3,40}$').hasMatch(code)) {
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

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      await _service.createPromotionCode(
        code: code,
        percentOff: _percentOff,
        maxRedemptions: maxRedemptions,
        expiresAt: _expiresAt,
        firstTimeOnly: _firstTimeOnly,
      );
      if (!mounted) return;
      setState(() {
        _creating = false;
        _maxRedemptionsController.clear();
        _expiresAt = null;
        _firstTimeOnly = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created $code in Stripe.'),
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
            'Creates a real Stripe Coupon and Promotion Code scoped to 4iCAD. '
            'Customers enter the code on the Stripe checkout page.',
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
          _field(_codeController, 'Customer-facing code', 'e.g. 4ICAD10', enabled: !_creating),
          const SizedBox(height: 14),
          _field(
            _maxRedemptionsController,
            'Maximum redemptions (optional)',
            'Leave blank for unlimited',
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
            label: 'Create in Stripe',
            icon: Icons.local_offer_outlined,
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
    return Column(
      children: [
        for (final code in codes)
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
                            color: Colors.white,
                          ),
                        ),
                      ),
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
                      if (code.percentOff != null)
                        FourICadMetaChip(
                          label: '${code.percentOff!.toInt()}% off',
                          emphasise: true,
                        ),
                      FourICadMetaChip(label: code.active ? 'ACTIVE' : 'INACTIVE'),
                      FourICadMetaChip(
                        label: code.maxRedemptions == null
                            ? '${code.timesRedeemed} redeemed'
                            : '${code.timesRedeemed}/${code.maxRedemptions} redeemed',
                      ),
                      if (code.expiresAt != null)
                        FourICadMetaChip(
                          label: 'Expires ${code.expiresAt!.day}/'
                              '${code.expiresAt!.month}/${code.expiresAt!.year}',
                          icon: Icons.event,
                        ),
                      if (code.firstTimeOnly)
                        const FourICadMetaChip(label: 'FIRST-TIME ONLY'),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
