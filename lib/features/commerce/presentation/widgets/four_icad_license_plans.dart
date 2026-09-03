import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';
import 'package:four_ideas/services/license_service.dart';

/// Device-license pricing for 4iCAD.
///
/// Prices are read from Stripe through `getLicensePlans`; no Stripe Price id or
/// amount is trusted from the browser. Checkout receives only plan + primary
/// platform and the backend chooses the configured Stripe Price.
class FourICadLicensePlans extends StatefulWidget {
  const FourICadLicensePlans({
    super.key,
    required this.signedIn,
    required this.emailVerified,
    required this.isMobile,
    required this.isTablet,
  });

  final bool signedIn;
  final bool emailVerified;
  final bool isMobile;
  final bool isTablet;

  @override
  State<FourICadLicensePlans> createState() => _FourICadLicensePlansState();
}

class _FourICadLicensePlansState extends State<FourICadLicensePlans> {
  final LicenseService _service = LicenseService();
  late Future<List<LicensePlanView>> _plans;
  String _primaryPlatform = 'windows';
  String? _busyPlan;

  @override
  void initState() {
    super.initState();
    _plans = _service.getPlans();
  }

  void _refresh() {
    setState(() => _plans = _service.getPlans());
  }

  Future<void> _buy(LicensePlanView plan) async {
    if (!widget.signedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in before purchasing a 4iCAD license.')),
      );
      context.go(AppRoutes.login);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (!mounted) return;
      if (FirebaseAuth.instance.currentUser?.emailVerified != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verify your email before purchasing 4iCAD.'),
          ),
        );
        return;
      }

      setState(() => _busyPlan = plan.plan);
      final url = await _service.createCheckoutSession(
        plan: plan.plan,
        primaryPlatform: _primaryPlatform,
      );
      final uri = Uri.parse(url);
      await launchUrl(
        uri,
        webOnlyWindowName: '_self',
        mode: LaunchMode.platformDefault,
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().contains('already-exists')
          ? 'This account already has that 4iCAD license.'
          : error.toString().contains('failed-precondition')
              ? 'This license plan is not available for checkout yet.'
              : 'Could not start license checkout. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _busyPlan = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your license',
                    style: GoogleFonts.roboto(
                      fontSize: widget.isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose one primary platform. Your free cross-platform activations can be used on other supported native platforms.',
                    style: GoogleFonts.roboto(
                      fontSize: widget.isMobile ? 14.5 : 16,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isMobile) ...[
              const SizedBox(width: 20),
              TextButton.icon(
                onPressed: widget.signedIn
                    ? () => context.go(AppRoutes.fourICadLicense)
                    : null,
                icon: const Icon(Icons.devices_outlined, size: 20),
                label: const Text('My License'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _platformChooser(),
        const SizedBox(height: 20),
        FutureBuilder<List<LicensePlanView>>(
          future: _plans,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 190,
                child: Center(
                  child: CircularProgressIndicator(color: ColorManager.accentGold),
                ),
              );
            }
            if (snap.hasError) {
              return FourICadGlassPanel(
                padding: const EdgeInsets.all(18),
                borderRadius: 14,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Could not load license pricing right now.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              );
            }
            final plans = snap.data ?? const [];
            if (plans.isEmpty) {
              return const SizedBox.shrink();
            }
            if (widget.isMobile) {
              return Column(
                children: [
                  for (final plan in plans) ...[
                    _planCard(plan),
                    if (plan != plans.last) const SizedBox(height: 12),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < plans.length; i++) ...[
                  Expanded(child: _planCard(plans[i])),
                  if (i != plans.length - 1) const SizedBox(width: 16),
                ],
              ],
            );
          },
        ),
        if (widget.isMobile && widget.signedIn) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: () => context.go(AppRoutes.fourICadLicense),
              icon: const Icon(Icons.devices_outlined, size: 18),
              label: const Text('Manage My License'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _platformChooser() {
    const platforms = <(String, String, IconData)>[
      ('windows', 'Windows', Icons.desktop_windows_outlined),
      ('macos', 'macOS', Icons.laptop_mac_outlined),
      ('linux', 'Linux', Icons.terminal_outlined),
      ('ios', 'iOS', Icons.phone_iphone_outlined),
      ('android', 'Android', Icons.android_outlined),
    ];

    return FourICadGlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 14,
      child: Row(
        children: [
          const Icon(Icons.computer_outlined,
              size: 23, color: ColorManager.accentGold),
          const SizedBox(width: 13),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _primaryPlatform,
              style: GoogleFonts.roboto(
                fontSize: widget.isMobile ? 15.5 : 17,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: 'Primary platform',
                labelStyle: GoogleFonts.roboto(
                  fontSize: widget.isMobile ? 13.5 : 14.5,
                  color: Colors.white70,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              items: [
                for (final item in platforms)
                  DropdownMenuItem(
                    value: item.$1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.$3, size: 20),
                        const SizedBox(width: 9),
                        Text(item.$2),
                      ],
                    ),
                  ),
              ],
              onChanged: _busyPlan == null
                  ? (value) {
                      if (value != null) {
                        setState(() => _primaryPlatform = value);
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(LicensePlanView plan) {
    final company = plan.plan == 'company';
    final price = plan.formattedPrice;
    final busy = _busyPlan == plan.plan;
    final canBuy = plan.active && price != null;

    String buttonLabel() {
      if (!widget.signedIn) return 'Sign in to buy';
      if (!widget.emailVerified) return 'Verify email first';
      if (!canBuy) return 'Not configured yet';
      return company ? 'Buy Company License' : 'Buy Individual License';
    }

    final VoidCallback? onPressed;
    if (!widget.signedIn) {
      onPressed = () => _buy(plan);
    } else if (widget.emailVerified && canBuy) {
      onPressed = () => _buy(plan);
    } else {
      onPressed = null;
    }

    return FourICadGlassPanel(
      goldBorder: company,
      padding: EdgeInsets.all(widget.isMobile ? 20 : 26),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${plan.displayName} License',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: widget.isMobile ? 20 : 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (company)
                FourICadMetaChip(
                  label: 'BUSINESS',
                  icon: Icons.business_outlined,
                  emphasise: true,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            price ?? 'Pricing not configured',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: widget.isMobile ? 34 : 38,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'one-time purchase',
            style: GoogleFonts.roboto(
              color: Colors.white60,
              fontSize: widget.isMobile ? 13 : 14,
            ),
          ),
          const SizedBox(height: 20),
          _benefit(
            Icons.devices_outlined,
            '${plan.primaryDeviceLimit} ${plan.primaryDeviceLimit == 1 ? 'device' : 'devices'} on your primary platform',
          ),
          const SizedBox(height: 10),
          _benefit(
            Icons.add_circle_outline,
            '+${plan.bonusOtherPlatformLimit} FREE ${plan.bonusOtherPlatformLimit == 1 ? 'activation' : 'activations'} on other platforms',
            gold: true,
          ),
          const SizedBox(height: 10),
          _benefit(
            Icons.all_inclusive,
            '${plan.totalDeviceLimit} active ${plan.totalDeviceLimit == 1 ? 'device' : 'devices'} maximum',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FourICadPrimaryButton(
              label: buttonLabel(),
              icon: company ? Icons.business_center_outlined : Icons.person_outline,
              busy: busy,
              onPressed: onPressed,
            ),
          ),
          if (widget.signedIn && !widget.emailVerified) ...[
            const SizedBox(height: 12),
            Text(
              'Open the verification link in your email, then refresh this page.',
              style: GoogleFonts.roboto(
                color: ColorManager.accentGold.withValues(alpha: 0.88),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String text, {bool gold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: gold ? ColorManager.accentGold : Colors.white70,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              color: gold ? ColorManager.accentGold : Colors.white70,
              fontSize: widget.isMobile ? 14.5 : 15.5,
              height: 1.42,
              fontWeight: gold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
