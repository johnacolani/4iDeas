import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/privacy_policy_data.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/services/privacy_policy_content_service.dart';
import 'admin_privacy_policy_edit_screen.dart';

/// Admin screen to add, edit, or remove app privacy policies.
class AdminPrivacyPolicyScreen extends StatefulWidget {
  const AdminPrivacyPolicyScreen({super.key});

  @override
  State<AdminPrivacyPolicyScreen> createState() =>
      _AdminPrivacyPolicyScreenState();
}

class _AdminPrivacyPolicyScreenState extends State<AdminPrivacyPolicyScreen> {
  final PrivacyPolicyContentService _service = PrivacyPolicyContentService();
  final ScrollController _scrollController = ScrollController();
  List<(String docId, PrivacyPolicy policy)> _policies = [];
  bool _loading = true;
  String? _error;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!AdminService.isAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Access denied. Admin only.'),
              backgroundColor: Colors.red),
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
      final list = await _service.getPoliciesWithDocIds();
      if (mounted) {
        setState(() {
          _policies = list;
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

  Future<void> _delete(String docId, PrivacyPolicy policy) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${policy.appName}" policy?',
            style: GoogleFonts.roboto(color: Colors.white)),
        content: Text(
          'This will remove the privacy policy from the site. You can add it again later.',
          style: GoogleFonts.roboto(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.roboto(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text('Delete', style: GoogleFonts.roboto(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _service.deletePolicy(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Policy removed'),
              backgroundColor: Colors.orange),
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

  Future<void> _navigateToEdit({String? docId, PrivacyPolicy? policy}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPrivacyPolicyEditScreen(
          docId: docId,
          initialPolicy: policy,
        ),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (!AdminService.isAdmin()) {
      return Scaffold(
        appBar: FrostedAppBar.darkNavy(title: const Text('Access Denied')),
        body: const Center(child: Text('Admin access required')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: Colors.amber),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        title: Text(
          'Admin - Privacy Policies',
          style: GoogleFonts.roboto(
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
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: ColorManager.orange))
                : _error != null
                    ? _buildError()
                    : Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'App Privacy Policies',
                                      style: GoogleFonts.roboto(
                                        color: ColorManager.orange,
                                        fontSize: isMobile ? 20 : 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _policies.isEmpty
                                          ? 'No policies yet. Tap + to add one — upload a .md file or paste Markdown.'
                                          : 'Managing ${_policies.length} policy(ies). Add, edit, or remove below.',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white
                                            .withValues(alpha: 0.8),
                                        fontSize: isMobile ? 14 : 15,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final entry = _policies[index];
                                  return _buildCard(
                                      entry.$1, entry.$2, isMobile);
                                },
                                childCount: _policies.length,
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 80)),
                          ],
                        ),
                      ),
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

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.red.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.orange),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );

  Widget _buildCard(String docId, PrivacyPolicy policy, bool isMobile) {
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
                    policy.appName,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '/privacy/${policy.slug}'
                    '${policy.lastUpdated.isNotEmpty ? '  •  Updated ${policy.lastUpdated}' : ''}',
                    style: GoogleFonts.roboto(
                      color: Colors.white70,
                      fontSize: isMobile ? 12 : 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: ColorManager.orange),
              onPressed: () => _navigateToEdit(docId: docId, policy: policy),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Colors.red.withValues(alpha: 0.9)),
              onPressed: () => _delete(docId, policy),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}
