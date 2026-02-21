import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/portfolio_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/services/portfolio_content_service.dart';
import 'admin_portfolio_app_edit_screen.dart';

/// Admin screen to add, edit, or remove portfolio content (apps, etc.).
class AdminPortfolioScreen extends StatefulWidget {
  const AdminPortfolioScreen({super.key});

  @override
  State<AdminPortfolioScreen> createState() => _AdminPortfolioScreenState();
}

class _AdminPortfolioScreenState extends State<AdminPortfolioScreen> {
  final PortfolioContentService _service = PortfolioContentService();
  List<PortfolioApp> _apps = [];
  bool _loading = true;
  String? _error;
  bool _useFirestore = false;

  @override
  void initState() {
    super.initState();
    if (!AdminService.isAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access denied. Admin only.'), backgroundColor: Colors.red),
        );
      });
      return;
    }
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apps = await _service.getApps();
      final hasAny = await _service.hasApps();
      if (mounted) {
        setState(() {
          _apps = apps;
          _useFirestore = hasAny;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
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
      await _service.deleteApp(app.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App removed'), backgroundColor: Colors.orange),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _navigateToEdit({String? docId, PortfolioApp? app}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPortfolioAppEditScreen(
          docId: docId,
          initialApp: app,
        ),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final wi = MediaQuery.of(context).size.width;
    final isMobile = wi < 600;

    if (!AdminService.isAdmin()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: const Color(0xff020923),
        ),
        body: const Center(child: Text('Admin access required')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        centerTitle: true,
        backgroundColor: const Color(0xff020923),
        title: Text(
          'Admin - Portfolio & Info',
          style: GoogleFonts.albertSans(
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: ColorManager.orange))
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.withValues(alpha: 0.8)),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: GoogleFonts.albertSans(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _load,
                      style: ElevatedButton.styleFrom(backgroundColor: ColorManager.orange),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portfolio Apps',
                          style: GoogleFonts.albertSans(
                            color: ColorManager.orange,
                            fontSize: isMobile ? 20 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _useFirestore
                              ? 'Managing ${_apps.length} app(s) from Firestore. Add, edit, or remove below.'
                              : 'No Firestore apps yet. Add one to manage portfolio from here (otherwise the app uses built-in data).',
                          style: GoogleFonts.albertSans(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: isMobile ? 14 : 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (_apps.isEmpty && _useFirestore)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No apps in Firestore. Tap + to add.',
                        style: GoogleFonts.albertSans(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final app = _apps[index];
                        return _buildAppCard(app, isMobile);
                      },
                      childCount: _apps.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        backgroundColor: ColorManager.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppCard(PortfolioApp app, bool isMobile) {
    return Card(
      margin: EdgeInsets.only(
        left: isMobile ? 16 : 24,
        right: isMobile ? 16 : 24,
        bottom: 12,
      ),
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: GoogleFonts.albertSans(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.description,
                    style: GoogleFonts.albertSans(
                      color: Colors.white70,
                      fontSize: isMobile ? 13 : 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: ColorManager.orange),
              onPressed: () => _navigateToEdit(docId: app.id, app: app),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.withValues(alpha: 0.9)),
              onPressed: () => _deleteApp(app),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}
