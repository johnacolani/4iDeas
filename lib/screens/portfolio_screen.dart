import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/portfolio_app_card.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/portfolio_publication_card.dart';
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
  final PublicationContentService _publicationService = PublicationContentService();
  final OpenSourceContentService _openSourceService = OpenSourceContentService();
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection(_featuredCaseStudiesKey));
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
      final staticOnly =
          PortfolioData.apps.where((a) => !idsFromCloud.contains(a.id)).toList();
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
      (_publicationsFromFirestore != null && _publicationsFromFirestore!.isNotEmpty)
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
      final staticOnly = PortfolioData.caseStudies.where((s) => !firestoreIds.contains(s.id)).toList();
      final mergedFirestore = fromFirestore.map((cs) {
        if (cs.id == 'asd') return PortfolioData.mergeFirestoreAsdAdaptiveCopyFromStatic(cs);
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

  static const String _designSystemUrl = 'https://my-flutter-apps-f87ea.web.app/';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _navigateToAddApp() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminPortfolioAppEditScreen(docId: null, initialApp: null),
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
        title: Text('Delete "${app.name}"?', style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the app from the portfolio. You can add it again later.',
          style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.albertSans(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.albertSans(color: Colors.red)),
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
            content: Text('This app is only in built-in data. Remove it from code or add a cloud copy first.'),
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
          const SnackBar(content: Text('App removed'), backgroundColor: Colors.orange),
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
        builder: (context) => AdminPublicationEditScreen(docId: null, initialPublication: null),
      ),
    );
    if (result == true) _loadPublications();
  }

  Future<void> _navigateToEditPublication(PortfolioPublication p) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminPublicationEditScreen(docId: p.id, initialPublication: p),
      ),
    );
    if (result == true) _loadPublications();
  }

  Future<void> _deletePublication(PortfolioPublication p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${p.title}"?', style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the publication from the list.',
          style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.albertSans(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.albertSans(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _publicationService.deletePublication(p.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication removed'), backgroundColor: Colors.orange),
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
        builder: (context) => AdminOpenSourceEditScreen(docId: null, initialItem: null),
      ),
    );
    if (result == true) _loadOpenSource();
  }

  Future<void> _navigateToEditOpenSource(OpenSourceItem item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminOpenSourceEditScreen(docId: item.id, initialItem: item),
      ),
    );
    if (result == true) _loadOpenSource();
  }

  Future<void> _deleteOpenSource(OpenSourceItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${item.title}"?', style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the item from the list.',
          style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.albertSans(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.albertSans(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _openSourceService.deleteItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Open source item removed'), backgroundColor: Colors.orange),
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
        builder: (context) => AdminCaseStudyEditScreen(docId: null, initialCaseStudy: null),
      ),
    );
    if (result == true) _loadCaseStudies();
  }

  Future<void> _navigateToEditCaseStudy(PortfolioCaseStudy cs) async {
    final isFromFirestore = _caseStudiesFromFirestore?.any((f) => f.id == cs.id) ?? false;
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
    final adaptiveCandidates = cs.sections.where((s) => s.isAsdAdaptivePlatformSection).toList();
    final adaptiveSection = adaptiveCandidates.isEmpty ? null : adaptiveCandidates.first;
    final initialPaths = adaptiveSection != null
        ? (adaptiveSection.imagePaths ?? adaptiveSection.displayImages.map((i) => i.path).toList()).join('\n')
        : '';

    final controller = TextEditingController(text: initialPaths);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Edit adaptive & responsive images', style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.8,
            child: TextField(
              controller: controller,
              maxLines: 14,
              style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'One asset path per line\ne.g. assets/images/asd_app_adaptive/asd-001.jpg',
                hintStyle: GoogleFonts.albertSans(color: ColorManager.accentGoldDark.withValues(alpha: 0.38)),
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
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
            child: Text('Cancel', style: GoogleFonts.albertSans(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Save', style: GoogleFonts.albertSans(color: ColorManager.orange, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved != true || !mounted) return;

    final pathLines = controller.text.trim().split(RegExp(r'\n')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
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
      sections: newSections,
      order: cs.order,
    );

    try {
      await _caseStudyService.setCaseStudyWithId('asd', updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adaptive & responsive images updated'), backgroundColor: Colors.green),
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
        title: Text('Delete "${cs.title}"?', style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove the case study from the list.',
          style: GoogleFonts.albertSans(color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.albertSans(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.albertSans(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _caseStudyService.deleteCaseStudy(cs.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case study removed'), backgroundColor: Colors.orange),
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
    final double gapAfterHero = he * 0.004;
    final double gapAfterSubtitle = he * 0.012;
    final double gapAfterDesignSystemCard = he * 0.012;
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: ColorManager.portfolioTextTitle),
        centerTitle: true,
        backgroundColor: ColorManager.accentGold,
        leading: Semantics(
          label: 'Back to home',
          button: true,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorManager.portfolioTextTitle),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        title: Text(
          'Portfolio',
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextTitle,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: Scrollbar(
              thumbVisibility: true,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                if (_isLoadingPortfolio)
                  SliverToBoxAdapter(
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(ColorManager.portfolioTextTitle),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      // Aligns section edges with "My Own Design System" card (page 16/24/32 + card gutter 12/24).
                      left: isMobile ? 28 : (isTablet ? 48 : 56),
                      right: isMobile ? 28 : (isTablet ? 48 : 56),
                      top: 0,
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

                        // Content below hero: moved up 200px to reduce gap
                        Transform.translate(
                          offset: const Offset(0, -200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        // 2. End-to-end product design from research to cross-platform delivery
                        Center(
                          child: SelectableText(
                            'End-to-end product design from research to cross-platform delivery',
                            style: GoogleFonts.albertSans(
                              color: ColorManager.portfolioTextBody,
                              fontSize: bodySize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: gapAfterSubtitle),

                        // 3. My Own Design System card
                        _DesignSystemHighlight(
                          designSystemTitleSize: isMobile ? 22 : (sectionTitleSize + 4),
                          designSystemSubSize: isMobile ? 14 : (bodySize - 1),
                          bodySize: bodySize,
                          isMobile: isMobile,
                          onTapLink: () => _launchUrl(_designSystemUrl),
                        ),
                        SizedBox(height: gapAfterDesignSystemCard),

                        // 4. Design Philosophy & Principles card
                        _DesignPhilosophyCard(
                          bodySize: bodySize,
                          isMobile: isMobile,
                        ),
                        SizedBox(height: gapAfterDesignPhilosophy),
                        _PortfolioSectionNav(
                          bodySize: bodySize,
                          isMobile: isMobile,
                          onTapFeatured: () => _scrollToSection(_featuredCaseStudiesKey),
                          onTapApps: () => _scrollToSection(_appShowcaseKey),
                          onTapPublications: () => _scrollToSection(_publicationsKey),
                          onTapOpenSource: () => _scrollToSection(_openSourceKey),
                        ),
                        SizedBox(height: 14),

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
                            icon: Icon(Icons.add, size: 18, color: ColorManager.portfolioTextBody),
                            label: Text(
                              'Add case study',
                              style: GoogleFonts.albertSans(color: ColorManager.portfolioTextBody, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ColorManager.portfolioTextBody.withValues(alpha: 0.5)),
                            ),
                          ),
                        ],
                        SizedBox(height: gapAfterFeaturedTitle),
                        _FeaturedCaseStudiesShowcase(
                          caseStudies: _displayCaseStudies,
                          isMobile: isMobile,
                          bodySize: bodySize,
                          gapBetweenCards: gapBetweenCaseStudyCards,
                          onOpenCaseStudy: (id) => context.go(AppRoutes.portfolioCaseStudyPath(id)),
                          showAdminActions: AdminService.isAdmin(),
                          onEdit: AdminService.isAdmin() ? _navigateToEditCaseStudy : null,
                          onDelete: AdminService.isAdmin() ? _deleteCaseStudy : null,
                          canDeleteCaseStudy: (id) =>
                              _caseStudiesFromFirestore?.any((f) => f.id == id) ?? false,
                          onEditAdaptiveSection:
                              AdminService.isAdmin() ? (cs) => _openEditAdaptiveSection(cs) : null,
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 10),
                            child: OutlinedButton.icon(
                              onPressed: () => context.push(AppRoutes.portfolioDesignSystemPath('4ideas')),
                              icon: Icon(Icons.design_services_outlined, size: 18, color: ColorManager.portfolioTextBody),
                              label: Text(
                                'Open 4iDeas Design System',
                                style: GoogleFonts.albertSans(
                                  color: ColorManager.portfolioTextBody,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: ColorManager.portfolioTextBody.withValues(alpha: 0.5)),
                              ),
                            ),
                          ),
                        ),
                        if (AdminService.isAdmin()) ...[
                          Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: _navigateToAddApp,
                                icon: Icon(Icons.add, size: 18, color: Colors.white),
                                label: Text('Add app', style: GoogleFonts.albertSans(color: Colors.white, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.orange,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: gapAfterAppShowcaseTitle),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double availableWidth = constraints.maxWidth;
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
                              physics: const NeverScrollableScrollPhysics(),
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
                                  onEdit: isAdmin ? () => _navigateToEditApp(app) : null,
                                  onDelete: isAdmin && _firestoreDocIdForPortfolioApp(app) != null
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
                            title: 'Publications',
                            sectionTitleSize: sectionTitleSize,
                          ),
                        ),
                        if (AdminService.isAdmin()) ...[
                          SizedBox(height: gapAfterPublicationsTitle),
                          OutlinedButton.icon(
                            onPressed: _navigateToAddPublication,
                            icon: Icon(Icons.add, size: 18, color: ColorManager.portfolioTextBody),
                            label: Text(
                              'Add publication',
                              style: GoogleFonts.albertSans(color: ColorManager.portfolioTextBody, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ColorManager.portfolioTextBody.withValues(alpha: 0.5)),
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
                              showAdminActions: AdminService.isAdmin() && _publicationsFromFirestore != null,
                              onEdit: AdminService.isAdmin() && _publicationsFromFirestore != null ? () => _navigateToEditPublication(p) : null,
                              onDelete: AdminService.isAdmin() && _publicationsFromFirestore != null ? () => _deletePublication(p) : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _launchUrl(PortfolioData.mediumProfile),
                            icon: Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: ColorManager.portfolioTextBody,
                            ),
                            label: SelectableText(
                              'View all on Medium',
                              style: GoogleFonts.albertSans(
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
                            title: 'Open Source & Package',
                            sectionTitleSize: sectionTitleSize,
                          ),
                        ),
                        if (AdminService.isAdmin()) ...[
                          SizedBox(height: gapAfterOpenSourceTitle),
                          OutlinedButton.icon(
                            onPressed: _navigateToAddOpenSource,
                            icon: Icon(Icons.add, size: 18, color: ColorManager.portfolioTextBody),
                            label: Text(
                              'Add open source item',
                              style: GoogleFonts.albertSans(color: ColorManager.portfolioTextBody, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ColorManager.portfolioTextBody.withValues(alpha: 0.5)),
                            ),
                          ),
                        ],
                        SizedBox(height: gapAfterOpenSourceTitle),
                        ..._displayOpenSourceItems.asMap().entries.map((e) {
                          final item = e.value;
                          return Padding(
                            padding: EdgeInsets.only(bottom: e.key < _displayOpenSourceItems.length - 1 ? 12 : 0),
                            child: _OpenSourceCard(
                              item: item,
                              isMobile: isMobile,
                              bodySize: bodySize,
                              showAdminActions: AdminService.isAdmin() && _openSourceFromFirestore != null,
                              onEdit: AdminService.isAdmin() && _openSourceFromFirestore != null ? () => _navigateToEditOpenSource(item) : null,
                              onDelete: AdminService.isAdmin() && _openSourceFromFirestore != null ? () => _deleteOpenSource(item) : null,
                            ),
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
                              style: GoogleFonts.albertSans(
                                color: ColorManager.portfolioTextBody,
                                fontSize: bodySize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: he * 0.03),
                            ],
                          ),
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
    // Lottie behind title — animation + title only (layout kept as-is)
    final double lottieHeight = titleSize * 1.3 * 9;
    final double lottieWidth = titleSize * 12 * 9;

    return Center(
      child: Transform.translate(
        offset: Offset(0, -he * 0.20),
        child: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                width: lottieWidth * 0.3,
                height: lottieHeight,
                child: Center(
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
                      color: ColorManager.portfolioTextBody.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, 60),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: math.max(8.0, wi * 0.04)),
                      child: SelectableText(
                        'Product design\n&\ncross-platform app development (Flutter)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.albertSans(
                          color: ColorManager.portfolioTextTitle,
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
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

class _DesignSystemHighlight extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapLink,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 28,
            vertical: isMobile ? 20 : 24,
          ),
          decoration: ColorManager.portfolioHighlightCardDecoration(borderRadius: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isMobile) ...[
                  Icon(
                    Icons.palette_outlined,
                    size: 48,
                    color: ColorManager.portfolioTextBody,
                  ),
                  SizedBox(width: 24),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        'My Own Design System',
                        style: GoogleFonts.playfairDisplay(
                          color: ColorManager.portfolioTextTitle,
                          fontSize: designSystemTitleSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      SelectableText(
                        'developed by: John Colani',
                        style: GoogleFonts.cormorantGaramond(
                          color: ColorManager.portfolioTextBody,
                          fontSize: designSystemSubSize + 2,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 10),
                      SelectableText(
                        'A living design system built in Flutter—components, patterns, and UI primitives crafted for real products. Explore the full showcase and token-based theming.',
                        style: GoogleFonts.albertSans(
                          color: ColorManager.portfolioTextBody,
                          fontSize: bodySize - 1,
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
                            style: GoogleFonts.albertSans(
                              color: ColorManager.portfolioTextBody,
                              fontSize: bodySize,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isMobile) ...[
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.designPhilosophy),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 28,
            vertical: isMobile ? 20 : 24,
          ),
          decoration: ColorManager.portfolioHighlightCardDecoration(borderRadius: 20),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: ColorManager.portfolioTextBody,
                size: isMobile ? 32 : 36,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'Design Philosophy & Principles',
                      style: GoogleFonts.albertSans(
                        color: ColorManager.portfolioTextTitle,
                        fontSize: bodySize + 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    SelectableText(
                      'How I approach product design: empathy, process, and principles.',
                      style: GoogleFonts.albertSans(
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
                color: ColorManager.portfolioTextBody,
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
      ('Publications', onTapPublications),
      ('Open Source', onTapOpenSource),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions
          .map(
            (item) => OutlinedButton(
              onPressed: item.$2,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ColorManager.portfolioTextBody.withValues(alpha: 0.45)),
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: 10),
              ),
              child: Text(
                item.$1,
                style: GoogleFonts.albertSans(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < caseStudies.length; i++) ...[
          _FeaturedCaseStudyRow(
            caseStudy: caseStudies[i],
            isMobile: isMobile,
            bodySize: bodySize,
            tags: _featuredTagsById[caseStudies[i].id] ?? const <String>[],
            onOpen: () => onOpenCaseStudy(caseStudies[i].id),
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
    );

    if (showAdminActions &&
        (onEdit != null || (onDelete != null && canDelete) || onEditAdaptiveSection != null)) {
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
                    icon: Icon(Icons.image, size: 22, color: ColorManager.portfolioTextBody),
                    onPressed: () => onEditAdaptiveSection!(caseStudy),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    tooltip: 'Edit Adaptive section images',
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, size: 22, color: ColorManager.portfolioTextBody),
                    onPressed: () => onEdit!(caseStudy),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                if (onDelete != null && canDelete)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 22, color: Colors.red),
                    onPressed: () => onDelete!(caseStudy),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
class _FeaturedCaseStudyHeroStrip extends StatelessWidget {
  final String? heroImagePath;
  static const double _height = 150;

  const _FeaturedCaseStudyHeroStrip({required this.heroImagePath});

  @override
  Widget build(BuildContext context) {
    final path = heroImagePath?.trim();
    if (path == null || path.isEmpty) {
      return Container(
        width: double.infinity,
        height: _height,
        color: Colors.white.withValues(alpha: 0.04),
        alignment: Alignment.center,
        child: Text(
          'Hero image placeholder',
          style: GoogleFonts.albertSans(
            color: ColorManager.portfolioTextBody.withValues(alpha: 0.72),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final Widget image = isNetwork
        ? Image.network(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: _height,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => _placeholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: _height,
                color: Colors.white.withValues(alpha: 0.06),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorManager.portfolioTextBody.withValues(alpha: 0.5),
                  ),
                ),
              );
            },
          )
        : Image.asset(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: _height,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => _placeholder(),
          );

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: image,
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: _height,
      color: Colors.white.withValues(alpha: 0.04),
      alignment: Alignment.center,
      child: Text(
        'Hero image failed to load',
        style: GoogleFonts.albertSans(
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

  const _PremiumFeaturedCard({
    required this.caseStudy,
    required this.isMobile,
    required this.bodySize,
    required this.tags,
    required this.onOpen,
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorManager.portfolioTextBody.withValues(alpha: 0.18),
                ColorManager.portfolioTextBody.withValues(alpha: 0.08),
                ColorManager.portfolioTextBody.withValues(alpha: 0.14),
              ],
            ),
            border: Border.all(
              color: ColorManager.portfolioTextBody.withValues(alpha: 0.40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _FeaturedCaseStudyHeroStrip(heroImagePath: caseStudy.heroImagePath),
              ),
              const SizedBox(height: 14),
              Text(
                caseStudy.title,
                style: GoogleFonts.albertSans(
                  color: ColorManager.portfolioTextTitle,
                  fontSize: bodySize + 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                caseStudy.subtitle,
                style: GoogleFonts.albertSans(
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
                style: GoogleFonts.albertSans(
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.albertSans(
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
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'View Case Study',
                    style: GoogleFonts.albertSans(
                      color: ColorManager.portfolioTextBody,
                      fontSize: bodySize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: ColorManager.portfolioTextBody, size: 18),
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
      style: GoogleFonts.albertSans(
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
          decoration: ColorManager.portfolioHighlightCardDecoration(borderRadius: 16),
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
                      style: GoogleFonts.albertSans(
                        color: ColorManager.portfolioTextTitle,
                        fontSize: bodySize + 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    SelectableText(
                      item.subtitle,
                      style: GoogleFonts.albertSans(
                        color: ColorManager.portfolioTextBody,
                        fontSize: bodySize - 1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: ColorManager.portfolioTextBody, size: 20),
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
                    icon: Icon(Icons.edit, size: 20, color: ColorManager.portfolioTextBody),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.red),
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
