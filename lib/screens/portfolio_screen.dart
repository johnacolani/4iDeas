import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/design_system/theme.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/portfolio_app_card.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/portfolio_publication_card.dart';
import 'package:four_ideas/core/widgets/adaptive_asset_image.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/portfolio_content_service.dart';
import 'package:four_ideas/services/publication_content_service.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_portfolio_app_edit_screen.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_publication_edit_screen.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_open_source_edit_screen.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_case_study_edit_screen.dart';
import 'package:four_ideas/services/open_source_content_service.dart';
import 'package:four_ideas/services/case_study_content_service.dart';
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioContentService _portfolioService = PortfolioContentService();
  final PublicationContentService _publicationService =
      PublicationContentService();
  final OpenSourceContentService _openSourceService =
      OpenSourceContentService();
  final CaseStudyContentService _caseStudyService = CaseStudyContentService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredCaseStudiesKey = GlobalKey();
  final GlobalKey _appShowcaseKey = GlobalKey();
  final GlobalKey _publicationsKey = GlobalKey();
  final GlobalKey _openSourceKey = GlobalKey();
  bool _handledInitialSectionLink = false;
  List<PortfolioApp>? _appsFromFirestore;

  /// Firestore collection document id for each [PortfolioApp.id] (logical slug may differ from doc id).
  Map<String, String>? _portfolioFirestoreDocByAppId;
  List<PortfolioPublication>? _publicationsFromFirestore;
  List<OpenSourceItem>? _openSourceFromFirestore;
  List<PortfolioCaseStudy>? _caseStudiesFromFirestore;
  bool _isLoadingPortfolio = true;

  @override
  void initState() {
    super.initState();
    _loadAllPortfolioData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledInitialSectionLink) return;
    _handledInitialSectionLink = true;
    final section = GoRouterState.of(context).uri.queryParameters['section'];
    if (section == 'featured') {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToSection(_featuredCaseStudiesKey));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPortfolioData() async {
    setState(() => _isLoadingPortfolio = true);
    await Future.wait([
      _loadPortfolioApps(),
      _loadPublications(),
      _loadOpenSource(),
      _loadCaseStudies(),
    ]);
    if (mounted) setState(() => _isLoadingPortfolio = false);
  }

  Future<void> _loadPortfolioApps() async {
    try {
      final hasAny = await _portfolioService.hasApps();
      if (!hasAny) {
        if (mounted) {
          setState(() {
            _appsFromFirestore = null;
            _portfolioFirestoreDocByAppId = null;
          });
        }
        return;
      }
      final withIds = await _portfolioService.getAppsWithDocIds();
      if (mounted) {
        setState(() {
          _appsFromFirestore = withIds.map((t) => t.$2).toList();
          _portfolioFirestoreDocByAppId = {
            for (final (docId, app) in withIds) app.id: docId,
          };
        });
      }
    } catch (_) {}
  }

  String? _firestoreDocIdForPortfolioApp(PortfolioApp app) =>
      _portfolioFirestoreDocByAppId?[app.id];

  List<PortfolioApp> get _displayApps {
    final List<PortfolioApp> list;
    if (_appsFromFirestore != null && _appsFromFirestore!.isNotEmpty) {
      // Merge with built-in catalog: editing one app in Firestore must not hide the rest
      // of the showcase (same idea as case studies: cloud overrides by id, static fills gaps).
      final fromCloud = _appsFromFirestore!
          .map(PortfolioData.mergePortfolioAppCaseStudyFromCatalog)
          .toList();
      final idsFromCloud = fromCloud.map((a) => a.id).toSet();
      final staticOnly = PortfolioData.apps
          .where((a) => !idsFromCloud.contains(a.id))
          .toList();
      list = [...fromCloud, ...staticOnly];
    } else {
      list = PortfolioData.apps;
    }
    return PortfolioData.orderAppsForShowcase(list);
  }

  Future<void> _loadPublications() async {
    try {
      final hasAny = await _publicationService.hasPublications();
      if (hasAny) {
        final list = await _publicationService.getPublications();
        if (mounted) setState(() => _publicationsFromFirestore = list);
      }
    } catch (_) {}
  }

  List<PortfolioPublication> get _displayPublications =>
      (_publicationsFromFirestore != null &&
              _publicationsFromFirestore!.isNotEmpty)
          ? _publicationsFromFirestore!
          : PortfolioData.publications;

  Future<void> _loadOpenSource() async {
    try {
      final hasAny = await _openSourceService.hasItems();
      if (hasAny) {
        final list = await _openSourceService.getItems();
        if (mounted) setState(() => _openSourceFromFirestore = list);
      }
    } catch (_) {}
  }

  List<OpenSourceItem> get _displayOpenSourceItems =>
      (_openSourceFromFirestore != null && _openSourceFromFirestore!.isNotEmpty)
          ? _openSourceFromFirestore!
          : PortfolioData.openSourceItems;

  Future<void> _loadCaseStudies() async {
    try {
      final hasAny = await _caseStudyService.hasCaseStudies();
      if (hasAny) {
        final list = await _caseStudyService.getCaseStudies();
        if (mounted) setState(() => _caseStudiesFromFirestore = list);
      }
    } catch (_) {}
  }

  List<PortfolioCaseStudy> get _displayCaseStudies {
    final List<PortfolioCaseStudy> list;
    final fromFirestore = _caseStudiesFromFirestore;
    if (fromFirestore == null || fromFirestore.isEmpty) {
      list = List<PortfolioCaseStudy>.from(PortfolioData.caseStudies);
    } else {
      final firestoreIds = fromFirestore.map((e) => e.id).toSet();
      final staticOnly = PortfolioData.caseStudies
          .where((s) => !firestoreIds.contains(s.id))
          .toList();
      final mergedFirestore = fromFirestore.map((cs) {
        if (cs.id == 'asd') {
          return PortfolioData.mergeFirestoreAsdAdaptiveCopyFromStatic(cs);
        }
        return PortfolioData.mergeHeroFromStaticIfMissing(cs);
      }).toList();
      list = [...mergedFirestore, ...staticOnly];
    }
    list.sort((a, b) {
      final byOrder = a.order.compareTo(b.order);
      if (byOrder != 0) return byOrder;
      // When order matches (e.g. legacy Firestore defaults), prefer featured static ids first.
      const tieBreak = {
        'rose-chat-seasonal-campaign-engine': 0,
        'service-flow': 1,
        'asd': 2,
        'twin-scriptures': 3,
      };
      final ta = tieBreak[a.id] ?? 99;
      final tb = tieBreak[b.id] ?? 99;
      final byTie = ta.compareTo(tb);
      if (byTie != 0) return byTie;
      return a.id.compareTo(b.id);
    });
    return list;
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  static const String _designSystemUrl =
      'https://my-flutter-apps-f87ea.web.app/';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _navigateToAddApp() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminPortfolioAppEditScreen(docId: null, initialApp: null),
      ),
    );
    if (result == true) _loadAllPortfolioData();
  }

  Future<void> _navigateToEditApp(PortfolioApp app) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminPortfolioAppEditScreen(
          docId: _firestoreDocIdForPortfolioApp(app),
          initialApp: app,
        ),
      ),
    );
    if (result == true) _loadAllPortfolioData();
  }

  Future<void> _deleteApp(PortfolioApp app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${app.name}"?',
            style: GoogleFonts.roboto(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the app from the portfolio. You can add it again later.',
          style: GoogleFonts.roboto(
              color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.roboto(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.roboto(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final docId = _firestoreDocIdForPortfolioApp(app);
    if (docId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'This app is only in built-in data. Remove it from code or add a cloud copy first.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    try {
      await _portfolioService.deleteApp(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('App removed'), backgroundColor: Colors.orange),
        );
        _loadPortfolioApps();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _navigateToAddPublication() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminPublicationEditScreen(docId: null, initialPublication: null),
      ),
    );
    if (result == true) _loadPublications();
  }

  Future<void> _navigateToEditPublication(PortfolioPublication p) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminPublicationEditScreen(docId: p.id, initialPublication: p),
      ),
    );
    if (result == true) _loadPublications();
  }

  Future<void> _deletePublication(PortfolioPublication p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${p.title}"?',
            style: GoogleFonts.roboto(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the publication from the list.',
          style: GoogleFonts.roboto(
              color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.roboto(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.roboto(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _publicationService.deletePublication(p.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Publication removed'),
              backgroundColor: Colors.orange),
        );
        _loadPublications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _navigateToAddOpenSource() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminOpenSourceEditScreen(docId: null, initialItem: null),
      ),
    );
    if (result == true) _loadOpenSource();
  }

  Future<void> _navigateToEditOpenSource(OpenSourceItem item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminOpenSourceEditScreen(docId: item.id, initialItem: item),
      ),
    );
    if (result == true) _loadOpenSource();
  }

  Future<void> _deleteOpenSource(OpenSourceItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${item.title}"?',
            style: GoogleFonts.roboto(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the item from the list.',
          style: GoogleFonts.roboto(
              color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.roboto(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.roboto(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _openSourceService.deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Open source item removed'),
              backgroundColor: Colors.orange),
        );
        _loadOpenSource();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _navigateToAddCaseStudy() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminCaseStudyEditScreen(docId: null, initialCaseStudy: null),
      ),
    );
    if (result == true) _loadCaseStudies();
  }

  Future<void> _navigateToEditCaseStudy(PortfolioCaseStudy cs) async {
    final isFromFirestore =
        _caseStudiesFromFirestore?.any((f) => f.id == cs.id) ?? false;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminCaseStudyEditScreen(
          docId: isFromFirestore ? cs.id : null,
          initialCaseStudy: cs,
        ),
      ),
    );
    if (result == true) await _loadCaseStudies();
  }

  Future<void> _openEditAdaptiveSection(PortfolioCaseStudy cs) async {
    final adaptiveCandidates =
        cs.sections.where((s) => s.isAsdAdaptivePlatformSection).toList();
    final adaptiveSection =
        adaptiveCandidates.isEmpty ? null : adaptiveCandidates.first;
    final initialPaths = adaptiveSection != null
        ? (adaptiveSection.imagePaths ??
                adaptiveSection.displayImages.map((i) => i.path).toList())
            .join('\n')
        : '';

    final controller = TextEditingController(text: initialPaths);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Edit adaptive & responsive images',
            style: GoogleFonts.roboto(color: ColorManager.accentGoldDark)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.8,
            child: TextField(
              controller: controller,
              maxLines: 14,
              style: GoogleFonts.roboto(
                  color: ColorManager.accentGoldDark, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'One asset path per line\ne.g. assets/images/asd_app_adaptive/asd-001.jpg',
                hintStyle: GoogleFonts.roboto(
                    color: ColorManager.accentGoldDark.withValues(alpha: 0.38)),
                alignLabelWithHint: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.roboto(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Save',
                style: GoogleFonts.roboto(
                    color: ColorManager.orange, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved != true || !mounted) return;

    final pathLines = controller.text
        .trim()
        .split(RegExp(r'\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final newSections = cs.sections.map((s) {
      if (s.isAsdAdaptivePlatformSection) {
        return CaseStudySection(
          title: s.title,
          content: s.content,
          imagePaths: pathLines.isEmpty ? null : pathLines,
          images: null,
        );
      }
      return s;
    }).toList();

    final updated = PortfolioCaseStudy(
      id: cs.id,
      title: cs.title,
      subtitle: cs.subtitle,
      overview: cs.overview,
      designApproach: cs.designApproach,
      heroImagePath: cs.heroImagePath,
      heroImagePaths: cs.heroImagePaths,
      sections: newSections,
      order: cs.order,
    );

    try {
      await _caseStudyService.setCaseStudyWithId('asd', updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Adaptive & responsive images updated'),
              backgroundColor: Colors.green),
        );
        await _loadCaseStudies();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteCaseStudy(PortfolioCaseStudy cs) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${cs.title}"?',
            style: GoogleFonts.roboto(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the case study from the list.',
          style: GoogleFonts.roboto(
              color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.roboto(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.roboto(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _caseStudyService.deleteCaseStudy(cs.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Case study removed'),
              backgroundColor: Colors.orange),
        );
        _loadCaseStudies();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;

    final double titleSize = isMobile ? 24 : (isTablet ? 28 : 32);
    final double sectionTitleSize = isMobile ? 20 : (isTablet ? 22 : 24);
    final double bodySize = isMobile ? 15 : (isTablet ? 16 : 17);

    // ---------- CONTROLLABLE GAPS (adjust these to control distance between sections) ----------
    final double gapAfterHero = 0.0;
    final double gapAfterSubtitle = he * 0.012;
    final double gapAfterDesignSystemCard = he * 0.03;
    final double gapAfterDesignPhilosophy = he * 0.012;
    final double gapAfterFeaturedTitle = 8.0;
    final double gapBetweenCaseStudyCards = 24.0;
    final double gapAfterCaseStudies = he * 0.04;
    final double gapAfterAppShowcaseTitle = 16.0;
    final double gapAfterAppShowcase = he * 0.04;
    final double gapAfterPublicationsTitle = 12.0;
    final double gapAfterPublications = he * 0.04;
    final double gapAfterOpenSourceTitle = 16.0;
    // ---------- END GAPS ----------

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        iconTheme: IconThemeData(color: ColorManager.portfolioTextTitle),
        centerTitle: true,
        leading: Semantics(
          label: 'Back to home',
          button: true,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        title: Text(
          'Portfolio',
          style: GoogleFonts.roboto(
            color: ColorManager.portfolioTextTitle,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.w600,
          ),
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
                controller: _scrollController,
                slivers: [
                  if (_isLoadingPortfolio)
                    SliverToBoxAdapter(
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            ColorManager.portfolioTextTitle),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        // Aligns section edges with "My Own Design System" card (page 16/24/32 + card gutter 12/24).
                        left: isMobile ? 28 : (isTablet ? 48 : 56),
                        right: isMobile ? 28 : (isTablet ? 48 : 56),
                        top: isMobile ? 0 : 24,
                        bottom: isMobile ? 20 : 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Hero (animation + title only)
                          _buildHero(
                            he: he,
                            wi: wi,
                            titleSize: titleSize,
                            bodySize: bodySize,
                            isMobile: isMobile,
                            sectionTitleSize: sectionTitleSize,
                          ),
                          SizedBox(height: gapAfterHero),

                          // Content below hero
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 2. My Own Design System card
                              _DesignSystemHighlight(
                                designSystemTitleSize:
                                    isMobile ? 24 : (sectionTitleSize + 6),
                                designSystemSubSize:
                                    isMobile ? 14 : (bodySize - 1),
                                bodySize: bodySize,
                                isMobile: isMobile,
                                onTapLink: () => _launchUrl(_designSystemUrl),
                              ),
                              SizedBox(height: gapAfterDesignSystemCard),

                              // 3. End-to-end product design from research to cross-platform delivery
                              Center(
                                child: SelectableText(
                                  'End-to-end product design from research to cross-platform delivery',
                                  style: GoogleFonts.roboto(
                                    color: ColorManager.portfolioTextTitle,
                                    fontSize:
                                        isMobile ? bodySize + 4 : bodySize + 6,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              SizedBox(height: gapAfterSubtitle),

                              // 4. Design Philosophy & Principles card
                              _DesignPhilosophyCard(
                                bodySize: bodySize,
                                isMobile: isMobile,
                              ),
                              SizedBox(height: gapAfterDesignPhilosophy),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 200,
                                ),
                                child: Center(
                                  child: FractionallySizedBox(
                                    widthFactor: isMobile ? 1.0 : 0.5,
                                    child: _PortfolioSectionNav(
                                      bodySize: bodySize,
                                      isMobile: isMobile,
                                      onTapFeatured: () =>
                                          _scrollToSection(
                                              _featuredCaseStudiesKey),
                                      onTapApps: () =>
                                          _scrollToSection(_appShowcaseKey),
                                      onTapPublications: () =>
                                          _scrollToSection(_publicationsKey),
                                      onTapOpenSource: () =>
                                          _scrollToSection(_openSourceKey),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        context.go(AppRoutes.services),
                                    child: Text(
                                      'Explore services behind this work',
                                      style: GoogleFonts.roboto(
                                        color: ColorManager.portfolioTextBody,
                                        fontSize: bodySize - 1,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: ColorManager
                                            .portfolioTextBody
                                            .withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        context.go(AppRoutes.contact),
                                    child: Text(
                                      'Discuss a similar product',
                                      style: GoogleFonts.roboto(
                                        color: ColorManager.portfolioTextBody,
                                        fontSize: bodySize - 1,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: ColorManager
                                            .portfolioTextBody
                                            .withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // 5. Featured Case Studies
                              KeyedSubtree(
                                key: _featuredCaseStudiesKey,
                                child: _SectionTitle(
                                  title: 'Featured Case Studies',
                                  sectionTitleSize: sectionTitleSize,
                                ),
                              ),
                              if (AdminService.isAdmin()) ...[
                                SizedBox(height: gapAfterFeaturedTitle),
                                OutlinedButton.icon(
                                  onPressed: _navigateToAddCaseStudy,
                                  icon: Icon(Icons.add,
                                      size: 18,
                                      color: ColorManager.portfolioTextBody),
                                  label: Text(
                                    'Add case study',
                                    style: GoogleFonts.roboto(
                                        color: ColorManager.portfolioTextBody,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: ColorManager.portfolioTextBody
                                            .withValues(alpha: 0.5)),
                                  ),
                                ),
                              ],
                              SizedBox(height: gapAfterFeaturedTitle),
                              _FeaturedCaseStudiesShowcase(
                                caseStudies: _displayCaseStudies,
                                isMobile: isMobile,
                                bodySize: bodySize,
                                gapBetweenCards: gapBetweenCaseStudyCards,
                                onOpenCaseStudy: (id) => context
                                    .go(AppRoutes.portfolioCaseStudyPath(id)),
                                onDiscussSimilar: () =>
                                    context.go(AppRoutes.contact),
                                showAdminActions: AdminService.isAdmin(),
                                onEdit: AdminService.isAdmin()
                                    ? _navigateToEditCaseStudy
                                    : null,
                                onDelete: AdminService.isAdmin()
                                    ? _deleteCaseStudy
                                    : null,
                                canDeleteCaseStudy: (id) =>
                                    _caseStudiesFromFirestore
                                        ?.any((f) => f.id == id) ??
                                    false,
                                onEditAdaptiveSection: AdminService.isAdmin()
                                    ? (cs) => _openEditAdaptiveSection(cs)
                                    : null,
                              ),
                              SizedBox(height: gapAfterCaseStudies),

                              // 6. App Showcase (2 columns or responsive grid)
                              KeyedSubtree(
                                key: _appShowcaseKey,
                                child: _SectionTitle(
                                  title: 'App Showcase',
                                  sectionTitleSize: sectionTitleSize,
                                ),
                              ),
                              if (AdminService.isAdmin()) ...[
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ElevatedButton.icon(
                                      onPressed: _navigateToAddApp,
                                      icon: Icon(Icons.add,
                                          size: 18, color: Colors.white),
                                      label: Text('Add app',
                                          style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorManager.orange,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: gapAfterAppShowcaseTitle),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final double availableWidth =
                                      constraints.maxWidth;
                                  final bool isAdmin = AdminService.isAdmin();
                                  int crossAxisCount;
                                  double mainAxisExtent;
                                  double spacing;
                                  // Taller cells so wrapped platform chips (Web, macOS, Windows, stores) stay visible.
                                  if (availableWidth > 900) {
                                    crossAxisCount = 3;
                                    mainAxisExtent = 432;
                                    spacing = 18;
                                  } else if (availableWidth > 600) {
                                    crossAxisCount = 2;
                                    mainAxisExtent = 452;
                                    spacing = 16;
                                  } else {
                                    crossAxisCount = 1;
                                    mainAxisExtent = 476;
                                    spacing = 14;
                                  }
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      mainAxisExtent: mainAxisExtent,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                    ),
                                    itemCount: _displayApps.length,
                                    itemBuilder: (context, index) {
                                      final app = _displayApps[index];
                                      return PortfolioAppCard(
                                        app: app,
                                        isMobile: isMobile,
                                        isTablet: isTablet,
                                        showAdminActions: isAdmin,
                                        onEdit: isAdmin
                                            ? () => _navigateToEditApp(app)
                                            : null,
                                        onDelete: isAdmin &&
                                                _firestoreDocIdForPortfolioApp(
                                                        app) !=
                                                    null
                                            ? () => _deleteApp(app)
                                            : null,
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: gapAfterAppShowcase),

                              // 7. Publications
                              KeyedSubtree(
                                key: _publicationsKey,
                                child: _SectionTitle(
                                  title: "John Colani's Publications",
                                  sectionTitleSize: sectionTitleSize,
                                ),
                              ),
                              if (AdminService.isAdmin()) ...[
                                SizedBox(height: gapAfterPublicationsTitle),
                                OutlinedButton.icon(
                                  onPressed: _navigateToAddPublication,
                                  icon: Icon(Icons.add,
                                      size: 18,
                                      color: ColorManager.portfolioTextBody),
                                  label: Text(
                                    'Add publication',
                                    style: GoogleFonts.roboto(
                                        color: ColorManager.portfolioTextBody,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: ColorManager.portfolioTextBody
                                            .withValues(alpha: 0.5)),
                                  ),
                                ),
                              ],
                              SizedBox(height: gapAfterPublicationsTitle),
                              ..._displayPublications.map(
                                (p) => Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: PortfolioPublicationCard(
                                    publication: p,
                                    isMobile: isMobile,
                                    isTablet: isTablet,
                                    showAdminActions: AdminService.isAdmin() &&
                                        _publicationsFromFirestore != null,
                                    onEdit: AdminService.isAdmin() &&
                                            _publicationsFromFirestore != null
                                        ? () => _navigateToEditPublication(p)
                                        : null,
                                    onDelete: AdminService.isAdmin() &&
                                            _publicationsFromFirestore != null
                                        ? () => _deletePublication(p)
                                        : null,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _launchUrl(PortfolioData.mediumProfile),
                                  icon: Icon(
                                    Icons.open_in_new,
                                    size: 16,
                                    color: ColorManager.portfolioTextBody,
                                  ),
                                  label: SelectableText(
                                    'View all on Medium',
                                    style: GoogleFonts.roboto(
                                      color: ColorManager.portfolioTextBody,
                                      fontSize: bodySize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: gapAfterPublications),

                              // 8. Open Source & Package
                              KeyedSubtree(
                                key: _openSourceKey,
                                child: _SectionTitle(
                                  title: "John Colani's Packages",
                                  sectionTitleSize: sectionTitleSize,
                                ),
                              ),
                              if (AdminService.isAdmin()) ...[
                                SizedBox(height: gapAfterOpenSourceTitle),
                                OutlinedButton.icon(
                                  onPressed: _navigateToAddOpenSource,
                                  icon: Icon(Icons.add,
                                      size: 18,
                                      color: ColorManager.portfolioTextBody),
                                  label: Text(
                                    'Add open source item',
                                    style: GoogleFonts.roboto(
                                        color: ColorManager.portfolioTextBody,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: ColorManager.portfolioTextBody
                                            .withValues(alpha: 0.5)),
                                  ),
                                ),
                              ],
                              SizedBox(height: gapAfterOpenSourceTitle),
                              ..._displayOpenSourceItems
                                  .asMap()
                                  .entries
                                  .map((e) {
                                final item = e.value;
                                final prev = e.key > 0
                                    ? _displayOpenSourceItems[e.key - 1]
                                    : null;
                                final isGithub =
                                    item.url.contains('github.com');
                                final prevWasGithub =
                                    prev?.url.contains('github.com') ?? false;
                                final showGithubSectionTitle =
                                    isGithub && !prevWasGithub;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (showGithubSectionTitle)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 8,
                                          top: e.key > 0 ? 4 : 0,
                                        ),
                                        child: SelectableText(
                                          "John Colani's GitHub repository",
                                          style: GoogleFonts.roboto(
                                            color:
                                                ColorManager.portfolioTextTitle,
                                            fontSize: bodySize + 1,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: e.key <
                                                _displayOpenSourceItems.length -
                                                    1
                                            ? 12
                                            : 0,
                                      ),
                                      child: _OpenSourceCard(
                                        item: item,
                                        isMobile: isMobile,
                                        bodySize: bodySize,
                                        showAdminActions:
                                            AdminService.isAdmin() &&
                                                _openSourceFromFirestore !=
                                                    null,
                                        onEdit: AdminService.isAdmin() &&
                                                _openSourceFromFirestore != null
                                            ? () =>
                                                _navigateToEditOpenSource(item)
                                            : null,
                                        onDelete: AdminService.isAdmin() &&
                                                _openSourceFromFirestore != null
                                            ? () => _deleteOpenSource(item)
                                            : null,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _launchUrl(PortfolioData.githubProfile),
                                  icon: Icon(
                                    Icons.open_in_new,
                                    size: 16,
                                    color: ColorManager.portfolioTextBody,
                                  ),
                                  label: SelectableText(
                                    'GitHub Profile',
                                    style: GoogleFonts.roboto(
                                      color: ColorManager.portfolioTextBody,
                                      fontSize: bodySize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: he * 0.03),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isMobile ? 16 : 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: ColorManager.portfolioTextBody
                                          .withValues(alpha: 0.3)),
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    FilledButton(
                                      onPressed: () =>
                                          context.go(AppRoutes.contact),
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            ColorManager.portfolioTextTitle,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        'Start a project conversation',
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () =>
                                          context.go(AppRoutes.services),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            ColorManager.portfolioTextTitle,
                                        side: BorderSide(
                                            color: ColorManager
                                                .portfolioTextBody
                                                .withValues(alpha: 0.5)),
                                      ),
                                      child: Text(
                                        'See service options',
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          context.go(AppRoutes.insights),
                                      child: Text(
                                        'Read implementation insights',
                                        style: GoogleFonts.roboto(
                                          color: ColorManager.portfolioTextBody,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                          decorationColor: ColorManager
                                              .portfolioTextBody
                                              .withValues(alpha: 0.45),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: he * 0.02),
                            ],
                          ),
                        ],
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

  Widget _buildHero({
    required double he,
    required double wi,
    required double titleSize,
    required double bodySize,
    required bool isMobile,
    required double sectionTitleSize,
  }) {
    // Keep title clear of frosted app bar, especially on desktop web.
    final double heroYOffset = isMobile ? -he * 0.05 : -he * 0.06;
    // Lottie behind title. Keep a tighter hero block height so next section
    // sits closer while preserving the text position.
    final double lottieHeight =
        (isMobile ? he * 0.34 : he * 0.30).clamp(220.0, 300.0);
    final double lottieWidth =
        (wi * (isMobile ? 0.9 : 0.82)).clamp(320.0, 780.0);

    return Center(
      child: Transform.translate(
        offset: Offset(0, heroYOffset),
        child: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                width: lottieWidth,
                height: lottieHeight,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, -he * 0.08),
                    child: Lottie.asset(
                      'assets/waveloop.json',
                      fit: BoxFit.fitHeight,
                      delegates: LottieDelegates(
                        values: [
                          // Apply a teal tint to the full composition.
                          ValueDelegate.colorFilter(
                            ['**'],
                            value: const ColorFilter.mode(
                              Color(0xFF8FD3CB),
                              BlendMode.srcATop,
                            ),
                          ),
                        ],
                      ),
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.palette_outlined,
                        size: titleSize,
                        color: ColorManager.portfolioTextBody
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, 44),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: math.max(8.0, wi * 0.04)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double headlineSize = isMobile
                                  ? (constraints.maxWidth * 0.078)
                                      .clamp(28.0, 44.0)
                                  : (constraints.maxWidth * 0.05)
                                      .clamp(34.0, 66.0);
                              final TextStyle headlineStyle = GoogleFonts.roboto(
                                fontSize: headlineSize,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: 0.2,
                              );

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Flutter App Development for',
                                      textAlign: TextAlign.center,
                                      style: headlineStyle.copyWith(
                                        color: ColorManager.portfolioTextTitle,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 6 : 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          AppColors.primaryGold,
                                          AppColors.primaryGoldDark,
                                        ],
                                      ).createShader(bounds),
                                      child: Text(
                                        'Startups and Bussiness',
                                        textAlign: TextAlign.center,
                                        style: headlineStyle.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          SelectableText(
                            'Interactive Prototype with Figma and Functional Prototype with Flutter and Origami Studio',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFD1D5DB),
                              fontSize: (bodySize - 1).clamp(13.0, 18.0),
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
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
    );
  }
}

class _DesignSystemHighlight extends StatefulWidget {
  final double designSystemTitleSize;
  final double designSystemSubSize;
  final double bodySize;
  final bool isMobile;
  final VoidCallback onTapLink;

  const _DesignSystemHighlight({
    required this.designSystemTitleSize,
    required this.designSystemSubSize,
    required this.bodySize,
    required this.isMobile,
    required this.onTapLink,
  });

  @override
  State<_DesignSystemHighlight> createState() => _DesignSystemHighlightState();
}

class _DesignSystemHighlightState extends State<_DesignSystemHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTapLink,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _orbitController,
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _NeonBorderOrbitPainter(
                        progress: _orbitController.value,
                        borderRadius: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(1.6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1B3A).withValues(alpha: 0.46),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF9EDB4D),
                    width: 1.6,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.4),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(18.4)),
                      ),
                      child: Stack(
                        // Default fit: parent Column can be vertically unbounded (sliver).
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1B3A)
                                    .withValues(alpha: 0.38),
                                borderRadius: BorderRadius.circular(18.4),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.14),
                                    Colors.white.withValues(alpha: 0.06),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.38, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.4),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.24),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.isMobile ? 20 : 28,
                              vertical: widget.isMobile ? 20 : 24,
                            ),
                            child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!widget.isMobile) ...[
                            Icon(
                              Icons.palette_outlined,
                              size: 48,
                              color: ColorManager.portfolioTextBody,
                            ),
                            SizedBox(width: 24),
                          ],
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  'My Own Design System',
                                  style: GoogleFonts.roboto(
                                    color: ColorManager.portfolioTextTitle,
                                    fontSize: widget.designSystemTitleSize,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                SelectableText(
                                  'developed by: John Colani',
                                  style: GoogleFonts.roboto(
                                    color: ColorManager.portfolioTextBody,
                                    fontSize: widget.designSystemSubSize + 2,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 10),
                                SelectableText(
                                  'A living design system built in Flutter—components, patterns, and UI primitives crafted for real products. Explore the full showcase and token-based theming.',
                                  style: GoogleFonts.roboto(
                                    color: ColorManager.portfolioTextBody,
                                    fontSize: widget.bodySize - 1,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 14),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.open_in_new,
                                      size: 18,
                                      color: ColorManager.portfolioTextBody,
                                    ),
                                    SizedBox(width: 8),
                                    SelectableText(
                                      'Open Design System →',
                                      style: GoogleFonts.roboto(
                                        color: ColorManager.portfolioTextBody,
                                        fontSize: widget.bodySize,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (widget.isMobile) ...[
                            SizedBox(width: 12),
                            Icon(
                              Icons.palette_outlined,
                              size: 36,
                              color: ColorManager.portfolioTextBody,
                            ),
                          ],
                        ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NeonBorderOrbitPainter extends CustomPainter {
  const _NeonBorderOrbitPainter({
    required this.progress,
    required this.borderRadius,
  });

  final double progress;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(1.3),
          Radius.circular(borderRadius),
        ),
      );
    final metric = path.computeMetrics().firstOrNull;
    if (metric == null || metric.length <= 0) return;

    final head = metric.length * progress;
    // Draw a subtle trailing neon effect.
    for (int i = 14; i >= 0; i--) {
      final t = i / 14;
      final offset = (head - (i * 7.5)) % metric.length;
      final tangent = metric
          .getTangentForOffset(offset < 0 ? offset + metric.length : offset);
      if (tangent == null) continue;
      final alpha = (1 - t) * 0.85;
      final radius = 1.5 + ((1 - t) * 3.2);
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
      canvas.drawCircle(tangent.position, radius + 1.2, glowPaint);
    }

    final headTangent = metric.getTangentForOffset(head);
    if (headTangent != null) {
      canvas.drawCircle(
        headTangent.position,
        3.2,
        Paint()..color = Colors.white.withValues(alpha: 0.98),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeonBorderOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class _PortfolioFrostedBlueTint extends StatelessWidget {
  const _PortfolioFrostedBlueTint({required this.borderRadius});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F3079).withValues(alpha: 0.42),
            const Color(0xFF040F2D).withValues(alpha: 0.5),
          ],
        ),
      ),
    );
  }
}

/// Dark blue frosted glass — shared by Design Philosophy and Featured Case Studies panels.
class _PortfolioFrostedGlassPanel extends StatelessWidget {
  const _PortfolioFrostedGlassPanel({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  static const double _kBlur = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: _kBlur, sigmaY: _kBlur),
          child: Stack(
            children: [
              Positioned.fill(
                child: _PortfolioFrostedBlueTint(borderRadius: borderRadius),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: LinearGradient(
                      begin: const Alignment(-1, -1),
                      end: const Alignment(0.45, 0.5),
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.28, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesignPhilosophyCard extends StatelessWidget {
  final double bodySize;
  final bool isMobile;

  const _DesignPhilosophyCard({
    required this.bodySize,
    required this.isMobile,
  });

  static const double _kRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return _PortfolioFrostedGlassPanel(
      borderRadius: _kRadius,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 28,
        vertical: isMobile ? 20 : 24,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.designPhilosophy),
          borderRadius: BorderRadius.circular(_kRadius),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: const Color(0xFFE5E7EB),
                size: isMobile ? 32 : 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'Design Philosophy & Principles',
                      style: GoogleFonts.roboto(
                        color: ColorManager.portfolioTextTitle,
                        fontSize: bodySize + 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      'How I approach product design: empathy, process, and principles.',
                      style: GoogleFonts.roboto(
                        color: ColorManager.portfolioTextBody,
                        fontSize: bodySize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFFE5E7EB),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioSectionNav extends StatelessWidget {
  final double bodySize;
  final bool isMobile;
  final VoidCallback onTapFeatured;
  final VoidCallback onTapApps;
  final VoidCallback onTapPublications;
  final VoidCallback onTapOpenSource;

  const _PortfolioSectionNav({
    required this.bodySize,
    required this.isMobile,
    required this.onTapFeatured,
    required this.onTapApps,
    required this.onTapPublications,
    required this.onTapOpenSource,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <(String, VoidCallback)>[
      ('Featured Case Studies', onTapFeatured),
      ('App Showcase', onTapApps),
      ("John Colani's Publications", onTapPublications),
      ("John Colani's Packages", onTapOpenSource),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions
          .map(
            (item) => OutlinedButton(
              onPressed: item.$2,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color:
                        ColorManager.portfolioTextBody.withValues(alpha: 0.45)),
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 14, vertical: 10),
              ),
              child: Text(
                item.$1,
                style: GoogleFonts.roboto(
                  color: ColorManager.portfolioTextBody,
                  fontSize: bodySize - 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FeaturedCaseStudiesShowcase extends StatelessWidget {
  final List<PortfolioCaseStudy> caseStudies;
  final bool isMobile;
  final double bodySize;
  final double gapBetweenCards;
  final ValueChanged<String> onOpenCaseStudy;
  final VoidCallback onDiscussSimilar;
  final bool showAdminActions;
  final void Function(PortfolioCaseStudy cs)? onEdit;
  final void Function(PortfolioCaseStudy cs)? onDelete;
  final bool Function(String id) canDeleteCaseStudy;
  final void Function(PortfolioCaseStudy cs)? onEditAdaptiveSection;

  const _FeaturedCaseStudiesShowcase({
    required this.caseStudies,
    required this.isMobile,
    required this.bodySize,
    required this.gapBetweenCards,
    required this.onOpenCaseStudy,
    required this.onDiscussSimilar,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
    required this.canDeleteCaseStudy,
    this.onEditAdaptiveSection,
  });

  static const Map<String, List<String>> _featuredTagsById = {
    'rose-chat-seasonal-campaign-engine': [
      'Conversational AI',
      'Product Design',
      'Flutter',
      'Firebase',
      'Dynamic UX',
      'System Design',
    ],
    'service-flow': [
      'Multi-tenant SaaS',
      'Product Design',
      'Flutter',
      'System Design',
      'Design System',
    ],
    'asd': [
      'Operations Platform',
      'Multi-role UX',
      'AI Governance',
      'Flutter',
      'Firebase',
    ],
    'twin-scriptures': [
      'Consumer Product',
      'Personalization',
      'RTL & i18n',
      'Flutter',
    ],
  };

  @override
  Widget build(BuildContext context) {
    if (caseStudies.isEmpty) return const SizedBox.shrink();

    return _PortfolioFrostedGlassPanel(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 18 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < caseStudies.length; i++) ...[
            _FeaturedCaseStudyRow(
              caseStudy: caseStudies[i],
              isMobile: isMobile,
              bodySize: bodySize,
              tags: _featuredTagsById[caseStudies[i].id] ?? const <String>[],
              onOpen: () => onOpenCaseStudy(caseStudies[i].id),
              onDiscussSimilar: onDiscussSimilar,
              showAdminActions: showAdminActions,
              onEdit: onEdit,
              onDelete: onDelete,
              canDelete: canDeleteCaseStudy(caseStudies[i].id),
              onEditAdaptiveSection:
                  caseStudies[i].id == 'asd' ? onEditAdaptiveSection : null,
            ),
            if (i < caseStudies.length - 1) SizedBox(height: gapBetweenCards),
          ],
        ],
      ),
    );
  }
}

/// Wraps a premium card with optional admin actions (same pattern as [CaseStudyCard]).
class _FeaturedCaseStudyRow extends StatelessWidget {
  final PortfolioCaseStudy caseStudy;
  final bool isMobile;
  final double bodySize;
  final List<String> tags;
  final VoidCallback onOpen;
  final VoidCallback onDiscussSimilar;
  final bool showAdminActions;
  final void Function(PortfolioCaseStudy cs)? onEdit;
  final void Function(PortfolioCaseStudy cs)? onDelete;
  final bool canDelete;
  final void Function(PortfolioCaseStudy cs)? onEditAdaptiveSection;

  const _FeaturedCaseStudyRow({
    required this.caseStudy,
    required this.isMobile,
    required this.bodySize,
    required this.tags,
    required this.onOpen,
    required this.onDiscussSimilar,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
    this.canDelete = false,
    this.onEditAdaptiveSection,
  });

  @override
  Widget build(BuildContext context) {
    final card = _PremiumFeaturedCard(
      caseStudy: caseStudy,
      isMobile: isMobile,
      bodySize: bodySize,
      tags: tags,
      onOpen: onOpen,
      onDiscussSimilar: onDiscussSimilar,
    );

    if (showAdminActions &&
        (onEdit != null ||
            (onDelete != null && canDelete) ||
            onEditAdaptiveSection != null)) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEditAdaptiveSection != null)
                  IconButton(
                    icon: Icon(Icons.image,
                        size: 22, color: ColorManager.portfolioTextBody),
                    onPressed: () => onEditAdaptiveSection!(caseStudy),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    tooltip: 'Edit Adaptive section images',
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit,
                        size: 22, color: ColorManager.portfolioTextBody),
                    onPressed: () => onEdit!(caseStudy),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                if (onDelete != null && canDelete)
                  IconButton(
                    icon:
                        Icon(Icons.delete_outline, size: 22, color: Colors.red),
                    onPressed: () => onDelete!(caseStudy),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
              ],
            ),
          ),
        ],
      );
    }
    return card;
  }
}

/// Featured card hero strip: asset path, `https://` URL, or empty → placeholder.
/// Fixed strip height 150px. Multi-image portrait strips (Twin, ASD, Rose Chat): narrow
/// phone-width tiles, [BoxFit.contain], spaced apart (no overlap).
class _FeaturedCaseStudyHeroStrip extends StatefulWidget {
  final String? heroImagePath;
  final List<String>? heroImagePaths;
  final bool isMobile;
  final String caseStudyId;
  static const double _height = 150;

  /// Portrait thumbnail width for multi-image strips (mobile-style screenshots).
  static const double _multiHeroPortraitThumbWidth = 72;

  /// Horizontal gap between portrait thumbnails so frames don’t stack visually.
  static const double _multiHeroPortraitGap = 10;

  /// Case studies that use Twin-style multi-hero: contain + narrow tiles + gap.
  static const Set<String> _portraitMultiHeroCaseStudyIds = {
    'twin-scriptures',
    'service-flow',
    'asd',
    'rose-chat-seasonal-campaign-engine',
  };

  const _FeaturedCaseStudyHeroStrip({
    required this.heroImagePath,
    this.heroImagePaths,
    required this.isMobile,
    required this.caseStudyId,
  });

  @override
  State<_FeaturedCaseStudyHeroStrip> createState() =>
      _FeaturedCaseStudyHeroStripState();
}

class _FeaturedCaseStudyHeroStripState
    extends State<_FeaturedCaseStudyHeroStrip> {
  int? _hoveredIndex;
  OverlayEntry? _hoverPreviewEntry;
  final ScrollController _multiHeroScrollController = ScrollController();
  bool _middleMouseScrolling = false;
  double _middleMouseStartDy = 0;
  double _middleMouseStartOffset = 0;
  Timer? _autoScrollTimer;
  Timer? _resumeAutoScrollTimer;
  bool _autoScrollPaused = false;
  bool _autoScrollForward = true;

  static const Duration _autoScrollTick = Duration(milliseconds: 1700);
  static const Duration _autoScrollAnimDuration = Duration(milliseconds: 560);
  static const double _autoScrollStep = 170.0;

  /// [ScrollPosition.maxScrollExtent] is unsafe until the viewport has laid out.
  bool get _multiHeroScrollLaidOut {
    if (!_multiHeroScrollController.hasClients) return false;
    return _multiHeroScrollController.position.hasContentDimensions;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _startAutoScrollIfNeeded());
  }

  bool get _usePortraitMultiHeroStrip =>
      _FeaturedCaseStudyHeroStrip._portraitMultiHeroCaseStudyIds
          .contains(widget.caseStudyId);

  bool get _enableHoverFx => !widget.isMobile;

  BoxFit get _imageFit {
    if (_usePortraitMultiHeroStrip) {
      return BoxFit.contain;
    }
    return widget.isMobile ? BoxFit.fitHeight : BoxFit.cover;
  }

  String _imageLabelFromPath(String path) {
    final normalized = path.toLowerCase();

    const exactLabels = <String, String>{
      'assets/images/admin/admin_dashboard.jpeg': 'Admin Dashboard',
      'assets/images/admin/admin_home_screen.jpeg': 'Admin Home',
      'assets/images/sales_rep/salesrep_dashboard.png': 'Sales Dashboard',
      'assets/images/sales_rep/salesrep_home.png': 'Sales Home',
      'assets/images/scheduler/scheduler dashboard.png': 'Scheduler Dashboard',
      'assets/images/scheduler/scheduler dashboard 01.png':
          'Scheduler Planning',
      'assets/images/installer/installer dashboard.png': 'Installer Dashboard',
      'assets/images/installer/installer home screen.png': 'Installer Home',
      'assets/images/admin/admin_trending_material.jpeg': 'Trending Materials',
      'assets/images/admin/admin_new_material.jpeg': 'New Materials',
    };
    final exact = exactLabels[normalized];
    if (exact != null) return exact;

    if (normalized.contains('sales')) return 'Sales Experience';
    if (normalized.contains('scheduler')) return 'Scheduler Experience';
    if (normalized.contains('installer')) return 'Installer Experience';
    if (normalized.contains('admin')) return 'Admin Experience';
    if (normalized.contains('material')) return 'Materials Management';
    if (normalized.contains('seasonal')) return 'Seasonal Campaign';
    if (normalized.contains('design_system')) return 'Design System';

    final file = path.split('/').last;
    final cleaned = file
        .replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false), '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
    if (cleaned.isEmpty) return 'Case Study Image';
    return cleaned
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1) : ''}')
        .join(' ');
  }

  void _showHoverPreview(BuildContext context, String path) {
    if (!_enableHoverFx) return;
    _hideHoverPreview();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    _hoverPreviewEntry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) {
                  return Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.96 + (0.04 * t),
                      child: child,
                    ),
                  );
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1600,
                    maxHeight: 980,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.32),
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 36,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: isNetwork
                            ? Image.network(
                                path,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => _placeholder(420),
                              )
                            : AdaptiveAssetImage(
                                path,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => _placeholder(420),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_hoverPreviewEntry!);
  }

  void _hideHoverPreview() {
    _hoverPreviewEntry?.remove();
    _hoverPreviewEntry = null;
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeAutoScrollTimer?.cancel();
    _hideHoverPreview();
    _multiHeroScrollController.dispose();
    super.dispose();
  }

  void _startAutoScrollIfNeeded() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(_autoScrollTick, (_) => _autoScrollOnce());
  }

  void _autoScrollOnce() {
    if (_autoScrollPaused || _middleMouseScrolling) return;
    if (!_multiHeroScrollLaidOut) return;
    final pos = _multiHeroScrollController.position;
    if (pos.maxScrollExtent < 20) return;

    final rawTarget = _autoScrollForward
        ? pos.pixels + _autoScrollStep
        : pos.pixels - _autoScrollStep;
    final target = rawTarget.clamp(0.0, pos.maxScrollExtent).toDouble();

    if ((target - pos.pixels).abs() < 0.5) {
      _autoScrollForward = !_autoScrollForward;
      return;
    }
    if (target == 0.0 || (pos.maxScrollExtent - target).abs() < 0.5) {
      _autoScrollForward = !_autoScrollForward;
    }

    _multiHeroScrollController.animateTo(
      target,
      duration: _autoScrollAnimDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void _pauseAutoScroll() {
    _autoScrollPaused = true;
    _resumeAutoScrollTimer?.cancel();
  }

  void _scheduleAutoScrollResume(
      [Duration delay = const Duration(milliseconds: 1200)]) {
    _resumeAutoScrollTimer?.cancel();
    _resumeAutoScrollTimer = Timer(delay, () {
      _autoScrollPaused = false;
    });
  }

  void _scrollMultiHeroBy(double delta) {
    _pauseAutoScroll();
    _scheduleAutoScrollResume();
    if (!_multiHeroScrollLaidOut) return;
    final pos = _multiHeroScrollController.position;
    final target = (pos.pixels + delta).clamp(0.0, pos.maxScrollExtent);
    _multiHeroScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _onMiddleMouseDown(PointerDownEvent event) {
    _pauseAutoScroll();
    if (event.buttons != kMiddleMouseButton) return;
    if (!_multiHeroScrollLaidOut) return;
    _middleMouseScrolling = true;
    _middleMouseStartDy = event.position.dy;
    _middleMouseStartOffset = _multiHeroScrollController.position.pixels;
    _hideHoverPreview();
    if (mounted) setState(() => _hoveredIndex = null);
  }

  void _onMiddleMouseMove(PointerMoveEvent event) {
    if (!_middleMouseScrolling) return;
    if (!_multiHeroScrollLaidOut) return;
    final deltaY = event.position.dy - _middleMouseStartDy;
    final pos = _multiHeroScrollController.position;
    final target = (_middleMouseStartOffset + (deltaY * 1.1))
        .clamp(0.0, pos.maxScrollExtent)
        .toDouble();
    _multiHeroScrollController.jumpTo(target);
  }

  void _onMiddleMouseUp(PointerEvent event) {
    if (_middleMouseScrolling) {
      _middleMouseScrolling = false;
    }
    _scheduleAutoScrollResume();
  }

  @override
  Widget build(BuildContext context) {
    final paths = widget.heroImagePaths
        ?.map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    final stripHeight = _FeaturedCaseStudyHeroStrip._height;

    Widget stripContent;
    if (paths != null && paths.length > 1) {
      final usePortrait = _usePortraitMultiHeroStrip;
      final thumbW = usePortrait
          ? _FeaturedCaseStudyHeroStrip._multiHeroPortraitThumbWidth
          : stripHeight;

      final list = ClipRect(
        child: ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
            },
          ),
          child: Listener(
            onPointerDown: _onMiddleMouseDown,
            onPointerMove: _onMiddleMouseMove,
            onPointerUp: _onMiddleMouseUp,
            onPointerCancel: _onMiddleMouseUp,
            child: ListView.separated(
              controller: _multiHeroScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: _enableHoverFx ? 6 : 0),
              itemCount: paths.length,
              separatorBuilder: (_, __) => SizedBox(
                width: usePortrait
                    ? _FeaturedCaseStudyHeroStrip._multiHeroPortraitGap
                    : 10,
              ),
              itemBuilder: (context, index) {
                final bool isHoveredTile =
                    _hoveredIndex == index && _enableHoverFx;
                return MouseRegion(
                  onEnter: (_) {
                    _pauseAutoScroll();
                    setState(() => _hoveredIndex = index);
                    _showHoverPreview(context, paths[index]);
                  },
                  onExit: (_) {
                    _scheduleAutoScrollResume();
                    setState(() => _hoveredIndex = null);
                    _hideHoverPreview();
                  },
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    offset:
                        isHoveredTile ? const Offset(0, -0.02) : Offset.zero,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      scale: isHoveredTile ? 1.04 : 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: thumbW,
                        height: stripHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isHoveredTile
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _stripImageForPath(
                                paths[index],
                                stripHeight,
                                cellWidth: thumbW,
                                zoomed: isHoveredTile,
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 160),
                                opacity: isHoveredTile ? 1 : 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.24),
                                    ),
                                  ),
                                  child: Text(
                                    _imageLabelFromPath(paths[index]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
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
        ),
      );
      stripContent = Stack(
        children: [
          Positioned.fill(child: list),
          if (_enableHoverFx) ...[
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  tooltip: 'Scroll left',
                  onPressed: () => _scrollMultiHeroBy(-220),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.34),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
              ),
            ),
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  tooltip: 'Scroll right',
                  onPressed: () => _scrollMultiHeroBy(220),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.34),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
        ],
      );
    } else {
      final path = (paths != null && paths.length == 1)
          ? paths.first
          : widget.heroImagePath?.trim();
      if (path == null || path.isEmpty) {
        stripContent = Container(
          width: double.infinity,
          height: stripHeight,
          color: Colors.white.withValues(alpha: 0.04),
          alignment: Alignment.center,
          child: Text(
            'Hero image placeholder',
            style: GoogleFonts.roboto(
              color: ColorManager.portfolioTextBody.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        stripContent = ClipRect(
          child: _stripImageForPath(path, stripHeight, cellWidth: null),
        );
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      height: stripHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: stripContent,
    );
  }

  /// [cellWidth] set for square carousel cells; null = full-width hero row.
  Widget _stripImageForPath(
    String path,
    double side, {
    double? cellWidth,
    bool zoomed = false,
  }) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final w = cellWidth ?? double.infinity;
    final image = isNetwork
        ? Image.network(
            path,
            fit: _imageFit,
            width: w,
            height: side,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => _placeholder(side),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: w,
                height: side,
                color: Colors.white.withValues(alpha: 0.06),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        ColorManager.portfolioTextBody.withValues(alpha: 0.5),
                  ),
                ),
              );
            },
          )
        : AdaptiveAssetImage(
            path,
            fit: _imageFit,
            width: w,
            height: side,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => _placeholder(side),
          );

    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      scale: zoomed ? 1.05 : 1.0,
      child: image,
    );
  }

  Widget _placeholder(double side) {
    return Container(
      width: double.infinity,
      height: side,
      color: Colors.white.withValues(alpha: 0.04),
      alignment: Alignment.center,
      child: Text(
        'Hero image failed to load',
        style: GoogleFonts.roboto(
          color: ColorManager.portfolioTextBody.withValues(alpha: 0.72),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PremiumFeaturedCard extends StatelessWidget {
  final PortfolioCaseStudy caseStudy;
  final bool isMobile;
  final double bodySize;
  final List<String> tags;
  final VoidCallback onOpen;
  final VoidCallback onDiscussSimilar;

  const _PremiumFeaturedCard({
    required this.caseStudy,
    required this.isMobile,
    required this.bodySize,
    required this.tags,
    required this.onOpen,
    required this.onDiscussSimilar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 28,
            vertical: isMobile ? 20 : 24,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.black.withValues(alpha: 0.45),
            border: Border.all(
              color: const Color(0xFFD1D5DB).withValues(alpha: 0.58),
              width: 1.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: FractionallySizedBox(
                  widthFactor: isMobile ? 1.0 : 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _FeaturedCaseStudyHeroStrip(
                      heroImagePath: caseStudy.heroImagePath,
                      heroImagePaths: caseStudy.heroImagePaths,
                      isMobile: isMobile,
                      caseStudyId: caseStudy.id,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                caseStudy.title,
                style: GoogleFonts.roboto(
                  color: ColorManager.portfolioTextTitle,
                  fontSize: bodySize + 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                caseStudy.subtitle,
                style: GoogleFonts.roboto(
                  color: ColorManager.portfolioTextBody,
                  fontSize: bodySize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                caseStudy.overview,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  color: ColorManager.portfolioTextBody,
                  fontSize: bodySize - 0.5,
                  height: 1.45,
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.black.withValues(alpha: 0.40),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24)),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.roboto(
                              color: ColorManager.portfolioTextBody,
                              fontSize: bodySize - 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              SizedBox(height: isMobile ? 16 : 18),
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryGold,
                                AppColors.primaryGoldDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FilledButton(
                            onPressed: onOpen,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: const Color(0xFF0B0F19),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'View case study',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  fontSize: bodySize),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: onDiscussSimilar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorManager.portfolioTextTitle,
                            side: BorderSide(
                                color: ColorManager.portfolioTextTitle
                                    .withValues(alpha: 0.55),
                                width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Discuss a similar project',
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w700,
                                fontSize: bodySize - 1),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryGold,
                                  AppColors.primaryGoldDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FilledButton(
                              onPressed: onOpen,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: const Color(0xFF0B0F19),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'View case study',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700,
                                    fontSize: bodySize),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onDiscussSimilar,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorManager.portfolioTextTitle,
                              side: BorderSide(
                                  color: ColorManager.portfolioTextTitle
                                      .withValues(alpha: 0.55),
                                  width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Discuss a similar project',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  fontSize: bodySize - 1),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final double sectionTitleSize;

  const _SectionTitle({
    required this.title,
    required this.sectionTitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      title,
      style: GoogleFonts.roboto(
        color: ColorManager.portfolioTextTitle,
        fontSize: sectionTitleSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

IconData _iconFromName(String name) {
  switch (name) {
    case 'widgets_outlined':
      return Icons.widgets_outlined;
    case 'code':
      return Icons.code;
    case 'article_outlined':
      return Icons.article_outlined;
    case 'github':
      return Icons.code;
    default:
      return Icons.code;
  }
}

class _OpenSourceCard extends StatelessWidget {
  final OpenSourceItem item;
  final bool isMobile;
  final double bodySize;
  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _OpenSourceCard({
    required this.item,
    required this.isMobile,
    required this.bodySize,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconFromName(item.iconName);

    Widget cardContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(item.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 28,
            vertical: isMobile ? 20 : 24,
          ),
          decoration:
              ColorManager.portfolioHighlightCardDecoration(borderRadius: 16),
          child: Row(
            children: [
              Icon(icon, color: ColorManager.portfolioTextBody, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      item.title,
                      style: GoogleFonts.roboto(
                        color: ColorManager.portfolioTextTitle,
                        fontSize: bodySize + 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    SelectableText(
                      item.subtitle,
                      style: GoogleFonts.roboto(
                        color: ColorManager.portfolioTextBody,
                        fontSize: bodySize - 1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new,
                  color: ColorManager.portfolioTextBody, size: 20),
            ],
          ),
        ),
      ),
    );

    if (showAdminActions && (onEdit != null || onDelete != null)) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          cardContent,
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit,
                        size: 20, color: ColorManager.portfolioTextBody),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon:
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
          ),
        ],
      );
    }
    return cardContent;
  }
}
