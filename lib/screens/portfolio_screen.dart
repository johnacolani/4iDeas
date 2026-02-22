import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/features/portfolio/presentation/screens/design_philosophy_screen.dart';
import 'package:four_ideas/features/portfolio/presentation/widgets/case_study_card.dart';
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
  List<PortfolioApp>? _appsFromFirestore;
  List<PortfolioPublication>? _publicationsFromFirestore;
  List<OpenSourceItem>? _openSourceFromFirestore;
  List<PortfolioCaseStudy>? _caseStudiesFromFirestore;

  @override
  void initState() {
    super.initState();
    _loadPortfolioApps();
    _loadPublications();
    _loadOpenSource();
    _loadCaseStudies();
  }

  Future<void> _loadPortfolioApps() async {
    try {
      final hasAny = await _portfolioService.hasApps();
      if (hasAny) {
        final apps = await _portfolioService.getApps();
        if (mounted) setState(() => _appsFromFirestore = apps);
      }
    } catch (_) {}
  }

  List<PortfolioApp> get _displayApps =>
      (_appsFromFirestore != null && _appsFromFirestore!.isNotEmpty)
          ? _appsFromFirestore!
          : PortfolioData.apps;

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

  List<PortfolioCaseStudy> get _displayCaseStudies =>
      (_caseStudiesFromFirestore != null && _caseStudiesFromFirestore!.isNotEmpty)
          ? _caseStudiesFromFirestore!
          : PortfolioData.caseStudies;

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
    if (result == true) _loadPortfolioApps();
  }

  Future<void> _navigateToEditApp(PortfolioApp app) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminPortfolioAppEditScreen(docId: app.id, initialApp: app),
      ),
    );
    if (result == true) _loadPortfolioApps();
  }

  Future<void> _deleteApp(PortfolioApp app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${app.name}"?', style: GoogleFonts.albertSans(color: Colors.white)),
        content: Text(
          'This will remove the app from the portfolio. You can add it again later.',
          style: GoogleFonts.albertSans(color: Colors.white70),
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
      await _portfolioService.deleteApp(app.id);
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
        title: Text('Delete "${p.title}"?', style: GoogleFonts.albertSans(color: Colors.white)),
        content: Text(
          'This will remove the publication from the list.',
          style: GoogleFonts.albertSans(color: Colors.white70),
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
        title: Text('Delete "${item.title}"?', style: GoogleFonts.albertSans(color: Colors.white)),
        content: Text(
          'This will remove the item from the list.',
          style: GoogleFonts.albertSans(color: Colors.white70),
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
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminCaseStudyEditScreen(docId: cs.id, initialCaseStudy: cs),
      ),
    );
    if (result == true) _loadCaseStudies();
  }

  Future<void> _deleteCaseStudy(PortfolioCaseStudy cs) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${cs.title}"?', style: GoogleFonts.albertSans(color: Colors.white)),
        content: Text(
          'This will remove the case study from the list.',
          style: GoogleFonts.albertSans(color: Colors.white70),
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amber[100]),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: Text(
          'Portfolio',
          style: GoogleFonts.albertSans(
            color: Colors.white,
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
                slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : (isTablet ? 24 : 32),
                      vertical: isMobile ? 20 : 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero
                        _buildHero(
                          he: he,
                          wi: wi,
                          titleSize: titleSize,
                          bodySize: bodySize,
                          isMobile: isMobile,
                          sectionTitleSize: sectionTitleSize,
                        ),
                        SizedBox(height: he * 0.04),

                        // Design Philosophy
                        _DesignPhilosophyCard(
                          bodySize: bodySize,
                          isMobile: isMobile,
                        ),
                        SizedBox(height: he * 0.04),

                        // Featured Case Studies
                        _SectionTitle(
                          title: 'Featured Case Studies',
                          sectionTitleSize: sectionTitleSize,
                        ),
                        if (AdminService.isAdmin()) ...[
                          SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _navigateToAddCaseStudy,
                            icon: Icon(Icons.add, size: 18, color: ColorManager.orange),
                            label: Text(
                              'Add case study',
                              style: GoogleFonts.albertSans(color: ColorManager.orange, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ColorManager.orange),
                            ),
                          ),
                        ],
                        SizedBox(height: 16),
                        ..._displayCaseStudies.map(
                          (cs) => Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: CaseStudyCard(
                              caseStudy: cs,
                              isMobile: isMobile,
                              isTablet: isTablet,
                              showAdminActions: AdminService.isAdmin() && _caseStudiesFromFirestore != null,
                              onEdit: AdminService.isAdmin() && _caseStudiesFromFirestore != null ? () => _navigateToEditCaseStudy(cs) : null,
                              onDelete: AdminService.isAdmin() && _caseStudiesFromFirestore != null ? () => _deleteCaseStudy(cs) : null,
                            ),
                          ),
                        ),
                        SizedBox(height: he * 0.04),

                        // App Showcase
                        _SectionTitle(
                          title: 'App Showcase',
                          sectionTitleSize: sectionTitleSize,
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
                        SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double availableWidth = constraints.maxWidth;
                            final bool isAdmin = AdminService.isAdmin();
                            final bool appsFromFirestore = _appsFromFirestore != null && _appsFromFirestore!.isNotEmpty;
                            int crossAxisCount;
                            double mainAxisExtent;
                            double spacing;
                            if (availableWidth > 900) {
                              crossAxisCount = 3;
                              mainAxisExtent = 340;
                              spacing = 18;
                            } else if (availableWidth > 600) {
                              crossAxisCount = 2;
                              mainAxisExtent = 360;
                              spacing = 16;
                            } else {
                              crossAxisCount = 1;
                              mainAxisExtent = 380;
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
                                  showAdminActions: isAdmin && appsFromFirestore,
                                  onEdit: isAdmin && appsFromFirestore ? () => _navigateToEditApp(app) : null,
                                  onDelete: isAdmin && appsFromFirestore ? () => _deleteApp(app) : null,
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: he * 0.04),

                        // Publications
                        _SectionTitle(
                          title: 'Publications',
                          sectionTitleSize: sectionTitleSize,
                        ),
                        if (AdminService.isAdmin()) ...[
                          SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _navigateToAddPublication,
                            icon: Icon(Icons.add, size: 18, color: ColorManager.orange),
                            label: Text(
                              'Add publication',
                              style: GoogleFonts.albertSans(color: ColorManager.orange, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ColorManager.orange),
                            ),
                          ),
                        ],
                        SizedBox(height: 12),
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
                            onPressed: () =>
                                _launchUrl(PortfolioData.mediumProfile),
                            icon: Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: ColorManager.blue,
                            ),
                            label: SelectableText(
                              'View all on Medium',
                              style: GoogleFonts.albertSans(
                                color: ColorManager.blue,
                                fontSize: bodySize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: he * 0.04),

                        // Open Source & Package
                        _SectionTitle(
                          title: 'Open Source & Package',
                          sectionTitleSize: sectionTitleSize,
                        ),
                        if (AdminService.isAdmin()) ...[
                          SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _navigateToAddOpenSource,
                            icon: Icon(Icons.add, size: 18, color: ColorManager.orange),
                            label: Text(
                              'Add open source item',
                              style: GoogleFonts.albertSans(color: ColorManager.orange, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ColorManager.orange),
                            ),
                          ),
                        ],
                        SizedBox(height: 16),
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
                              color: ColorManager.blue,
                            ),
                            label: SelectableText(
                              'GitHub Profile',
                              style: GoogleFonts.albertSans(
                                color: ColorManager.blue,
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
    return Center(
      child: Column(
        children: [
          Center(
            child: SelectableText(
              'Product Design & Development',
              style: GoogleFonts.albertSans(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: he * 0.01),
          Center(
            child: SelectableText(
              'End-to-end product design from research to cross-platform delivery',
              style: GoogleFonts.albertSans(
                color: ColorManager.orange,
                fontSize: bodySize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const DesignPhilosophyScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 18 : 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorManager.orange.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: ColorManager.orange,
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
                        color: Colors.white,
                        fontSize: bodySize + 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    SelectableText(
                      'How I approach product design: empathy, process, and principles.',
                      style: GoogleFonts.albertSans(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: bodySize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: ColorManager.orange.withValues(alpha: 0.9),
                size: 18,
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
        color: ColorManager.orange,
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
    Widget cardContent = InkWell(
      onTap: () async {
        final uri = Uri.parse(item.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorManager.orange, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    item.title,
                    style: GoogleFonts.albertSans(
                      color: Colors.white,
                      fontSize: bodySize + 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  SelectableText(
                    item.subtitle,
                    style: GoogleFonts.albertSans(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: bodySize - 1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: ColorManager.blue, size: 20),
          ],
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
                    icon: Icon(Icons.edit, size: 20, color: ColorManager.orange),
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
