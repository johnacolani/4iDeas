import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/design_system/theme.dart';
import 'package:four_ideas/core/home_warm_colors.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/core/widgets/service_offering_card.dart';
import 'package:four_ideas/data/services_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/services/services_content_service.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_service_edit_screen.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ServicesContentService _servicesService = ServicesContentService();
  List<ServiceItem>? _servicesFromFirestore;
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final hasAny = await _servicesService.hasServices();
      if (hasAny) {
        final list = await _servicesService.getServices();
        if (mounted) setState(() => _servicesFromFirestore = list);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingServices = false);
  }

  List<ServiceItem> get _displayServices =>
      (_servicesFromFirestore != null && _servicesFromFirestore!.isNotEmpty)
          ? _servicesFromFirestore!
          : ServicesData.defaultServices;

  Future<void> _navigateToAddService() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminServiceEditScreen(docId: null, initialItem: null),
      ),
    );
    if (result == true) _loadServices();
  }

  Future<void> _navigateToEditService(ServiceItem item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminServiceEditScreen(docId: item.id, initialItem: item),
      ),
    );
    if (result == true) _loadServices();
  }

  Future<void> _deleteService(ServiceItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${item.title}"?',
            style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the service from the list.',
          style: GoogleFonts.albertSans(
              color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.albertSans(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.albertSans(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _servicesService.deleteService(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Service removed'), backgroundColor: Colors.orange),
        );
        _loadServices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _goContact(BuildContext context) => context.go(AppRoutes.contact);

  static const LinearGradient _goldGradient = LinearGradient(
    colors: [AppColors.primaryGold, AppColors.primaryGoldDark],
  );

  Widget _buildServiceOfferings({
    required List<ServiceItem> items,
    required bool isMobile,
    required double wi,
    required double sectionTitleSize,
    required double bodyFontSize,
    required bool showAdminActions,
  }) {
    final useTwoCols = !isMobile && wi >= 960;

    Widget cardFor(ServiceItem item) {
      return ServiceOfferingCard(
        item: item,
        isMobile: isMobile,
        sectionTitleSize: sectionTitleSize,
        bodyFontSize: bodyFontSize,
        onCta: () => _goContact(context),
        showAdminActions: showAdminActions,
        onEdit: showAdminActions ? () => _navigateToEditService(item) : null,
        onDelete: showAdminActions ? () => _deleteService(item) : null,
      );
    }

    if (!useTwoCols) {
      return Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: isMobile ? 20 : 24),
            cardFor(items[i]),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cardFor(left)),
              const SizedBox(width: 24),
              Expanded(
                child: right != null ? cardFor(right) : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < items.length) {
        rows.add(const SizedBox(height: 24));
      }
    }
    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;

    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;

    final double titleFontSize = isMobile ? 28 : (isTablet ? 32 : 34);
    final double sectionTitleSize = isMobile ? 19 : (isTablet ? 20 : 21);
    final double bodyFontSize = isMobile ? 16 : (isTablet ? 17 : 18);
    final double maxShell = isMobile ? double.infinity : 1120;

    final bool showAdminActions =
        AdminService.isAdmin() && _servicesFromFirestore != null;

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
          'Services',
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
              child: CustomScrollView(
                slivers: [
                  if (_isLoadingServices)
                    SliverToBoxAdapter(
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            HomeWarmColors.sectionAccent),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : (isTablet ? 24.0 : 32.0),
                        vertical: isMobile ? 20.0 : 28.0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxShell),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Semantics(
                                      header: true,
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            _goldGradient.createShader(bounds),
                                        blendMode: BlendMode.srcIn,
                                        child: Text(
                                          'How 4iDeas helps teams ship',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.albertSans(
                                            color: Colors.white,
                                            fontSize: titleFontSize,
                                            fontWeight: FontWeight.w800,
                                            height: 1.15,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: he * 0.012),
                                    SelectableText(
                                      'Founder-led studio services for startups and businesses—MVP delivery, product design with engineering, practical AI features, and ongoing improvement for products already in market.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.albertSans(
                                        color: const Color(0xFFD1D5DB),
                                        fontSize: bodyFontSize,
                                        fontWeight: FontWeight.w500,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: he * 0.028),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        TextButton(
                                          onPressed: () => context.go(
                                              '${AppRoutes.portfolio}?section=featured'),
                                          child: Text(
                                            'See featured case studies',
                                            style: GoogleFonts.albertSans(
                                              color: AppColors.primaryGold,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: AppColors
                                                  .primaryGold
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              context.go(AppRoutes.insights),
                                          child: Text(
                                            'Read implementation insights',
                                            style: GoogleFonts.albertSans(
                                              color: AppColors.primaryGold,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: AppColors
                                                  .primaryGold
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (AdminService.isAdmin()) ...[
                                OutlinedButton.icon(
                                  onPressed: _navigateToAddService,
                                  icon: Icon(Icons.add,
                                      size: 18,
                                      color: AppColors.primaryGold),
                                  label: Text(
                                    'Add service',
                                    style: GoogleFonts.albertSans(
                                      color: AppColors.primaryGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: AppColors.primaryGold),
                                  ),
                                ),
                                SizedBox(height: isMobile ? 16 : 20),
                              ],
                              _buildServiceOfferings(
                                items: _displayServices,
                                isMobile: isMobile,
                                wi: wi,
                                sectionTitleSize: sectionTitleSize,
                                bodyFontSize: bodyFontSize,
                                showAdminActions: showAdminActions,
                              ),
                              SizedBox(height: he * 0.04),
                              Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 560),
                                  child: Container(
                                    padding: EdgeInsets.all(isMobile ? 20 : 26),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color: Colors.white24),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF0F172A)
                                              .withValues(alpha: 0.94),
                                          const Color(0xFF111827)
                                              .withValues(alpha: 0.9),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: HomeWarmColors.headlinePrimary
                                              .withValues(alpha: 0.06),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              _goldGradient.createShader(bounds),
                                          blendMode: BlendMode.srcIn,
                                          child: Text(
                                            'Ready to discuss your product?',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.albertSans(
                                              color: Colors.white,
                                              fontSize: sectionTitleSize + 1,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        SelectableText(
                                          'Send a short note about your product, timeline, and budget band. I respond with candid next steps—whether we are a fit or not.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.albertSans(
                                            color: const Color(0xFFD1D5DB),
                                            fontSize: bodyFontSize - 1,
                                            height: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton(
                                            style: FilledButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFF0B0F19),
                                              backgroundColor:
                                                  AppColors.primaryGold,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: isMobile ? 14 : 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () =>
                                                _goContact(context),
                                            child: Text(
                                              'Discuss your project',
                                              style: GoogleFonts.albertSans(
                                                fontSize: bodyFontSize,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        TextButton(
                                          onPressed: () =>
                                              context.go(AppRoutes.orderHere),
                                          child: Text(
                                            'Prefer a structured brief? Submit a project form',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.albertSans(
                                              color: AppColors.primaryGold,
                                              fontWeight: FontWeight.w600,
                                              fontSize: bodyFontSize - 2,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: AppColors
                                                  .primaryGold
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            TextButton(
                                              onPressed: () => context
                                                  .go(AppRoutes.portfolio),
                                              child: Text(
                                                'Review portfolio proof',
                                                style: GoogleFonts.albertSans(
                                                  color: AppColors.primaryGold,
                                                  fontWeight: FontWeight.w700,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColors
                                                          .primaryGold
                                                          .withValues(
                                                              alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => context
                                                  .go(AppRoutes.insights),
                                              child: Text(
                                                'Read delivery insights',
                                                style: GoogleFonts.albertSans(
                                                  color: AppColors.primaryGold,
                                                  fontWeight: FontWeight.w700,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColors
                                                          .primaryGold
                                                          .withValues(
                                                              alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: he * 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
