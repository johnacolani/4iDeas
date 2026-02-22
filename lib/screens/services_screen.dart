import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
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

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final hasAny = await _servicesService.hasServices();
      if (hasAny) {
        final list = await _servicesService.getServices();
        if (mounted) setState(() => _servicesFromFirestore = list);
      }
    } catch (_) {}
  }

  List<ServiceItem> get _displayServices =>
      (_servicesFromFirestore != null && _servicesFromFirestore!.isNotEmpty)
          ? _servicesFromFirestore!
          : ServicesData.defaultServices;

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'design_services':
        return Icons.design_services;
      case 'palette':
        return Icons.palette;
      case 'extension':
        return Icons.extension;
      case 'psychology':
        return Icons.psychology;
      case 'phone_android':
        return Icons.phone_android;
      case 'handshake':
        return Icons.handshake;
      default:
        return Icons.design_services;
    }
  }

  Future<void> _navigateToAddService() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminServiceEditScreen(docId: null, initialItem: null),
      ),
    );
    if (result == true) _loadServices();
  }

  Future<void> _navigateToEditService(ServiceItem item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AdminServiceEditScreen(docId: item.id, initialItem: item),
      ),
    );
    if (result == true) _loadServices();
  }

  Future<void> _deleteService(ServiceItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${item.title}"?', style: GoogleFonts.albertSans(color: Colors.white)),
        content: Text(
          'This will remove the service from the list.',
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
      await _servicesService.deleteService(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service removed'), backgroundColor: Colors.orange),
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

  @override
  Widget build(BuildContext context) {
    double he = MediaQuery.of(context).size.height;
    double wi = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints
    final bool isMobile = wi < 600;
    final bool isTablet = wi >= 600 && wi < 1024;
    
    // Responsive font sizes
    final double titleFontSize = isMobile ? 28 : (isTablet ? 32 : 36);
    final double sectionTitleSize = isMobile ? 22 : (isTablet ? 24 : 26);
    final double bodyFontSize = isMobile ? 16 : (isTablet ? 17 : 18);
    
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.amber[100],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: SelectableText(
          'Services',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
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
                      horizontal: isMobile ? 16.0 : (isTablet ? 24.0 : 32.0),
                      vertical: isMobile ? 20.0 : 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : (isTablet ? 700 : 800),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Center(
                              child: Column(
                                children: [
                                  SelectableText(
                                    'Our Services',
                                    style: GoogleFonts.albertSans(
                                      color: Colors.white,
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.01),
                                  SelectableText(
                                    'Professional Product Design Services',
                                    style: TextStyle(
                                      color: ColorManager.orange,
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: he * 0.03),
                                ],
                              ),
                            ),
                            if (AdminService.isAdmin()) ...[
                              Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: OutlinedButton.icon(
                                  onPressed: _navigateToAddService,
                                  icon: Icon(Icons.add, size: 18, color: ColorManager.orange),
                                  label: Text(
                                    'Add service',
                                    style: GoogleFonts.albertSans(color: ColorManager.orange, fontWeight: FontWeight.w600),
                                  ),
                                  style: OutlinedButton.styleFrom(side: BorderSide(color: ColorManager.orange)),
                                ),
                              ),
                            ],
                            ..._displayServices.asMap().entries.map((e) {
                              final item = e.value;
                              final isLast = e.key == _displayServices.length - 1;
                              return Column(
                                children: [
                                  _buildServiceCard(
                                    item: item,
                                    he: he,
                                    isMobile: isMobile,
                                    sectionTitleSize: sectionTitleSize,
                                    bodyFontSize: bodyFontSize,
                                    showAdminActions: AdminService.isAdmin() && _servicesFromFirestore != null,
                                    onEdit: AdminService.isAdmin() && _servicesFromFirestore != null ? () => _navigateToEditService(item) : null,
                                    onDelete: AdminService.isAdmin() && _servicesFromFirestore != null ? () => _deleteService(item) : null,
                                  ),
                                  SizedBox(height: isLast ? he * 0.04 : he * 0.025),
                                ],
                              );
                            }),
                            SizedBox(height: he * 0.02),
                            
                            // Call to Action
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 20 : 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorManager.blue.withValues(alpha: 0.2),
                                      ColorManager.orange.withValues(alpha: 0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SelectableText(
                                      'Ready to start your project?',
                                      style: GoogleFonts.albertSans(
                                        color: Colors.white,
                                        fontSize: sectionTitleSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    SelectableText(
                                      'Let\'s discuss how we can bring your ideas to life',
                                      style: TextStyle(
                                        color: ColorManager.orange,
                                        fontSize: bodyFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            SizedBox(height: he * 0.04),
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

  Widget _buildServiceCard({
    required ServiceItem item,
    required double he,
    required bool isMobile,
    required double sectionTitleSize,
    required double bodyFontSize,
    bool showAdminActions = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final icon = _iconFromName(item.iconName);
    Widget cardContent = Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: ColorManager.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: ColorManager.orange,
                  size: isMobile ? 28 : 32,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      item.title,
                      style: GoogleFonts.albertSans(
                        color: ColorManager.orange,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    SelectableText(
                      item.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: bodyFontSize - 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: he * 0.015),
          SelectableText(
            item.description,
            style: TextStyle(
              color: Colors.white,
              fontSize: bodyFontSize,
              height: 1.6,
            ),
          ),
          SizedBox(height: he * 0.015),
          ...item.details.map((detail) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 6, right: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: ColorManager.blue,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: SelectableText(
                        detail,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: bodyFontSize - 1,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );

    if (showAdminActions && (onEdit != null || onDelete != null)) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          cardContent,
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, size: 22, color: ColorManager.orange),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 22, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 36, minHeight: 36),
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
