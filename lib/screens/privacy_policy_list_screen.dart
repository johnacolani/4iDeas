import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/core/widgets/frosted_app_bar.dart';
import 'package:four_ideas/data/privacy_policy_data.dart';
import 'package:four_ideas/features/admin/presentation/screens/admin_privacy_policy_edit_screen.dart';
import 'package:four_ideas/helper/app_background.dart';
import 'package:four_ideas/services/admin_service.dart';
import 'package:four_ideas/services/privacy_policy_content_service.dart';

/// Public list of app privacy policies. Tap one to read it.
///
/// Admins additionally get add / edit / delete controls inline (the same
/// actions as the admin manager), so the whole workflow lives on one screen.
class PrivacyPolicyListScreen extends StatefulWidget {
  const PrivacyPolicyListScreen({super.key});

  @override
  State<PrivacyPolicyListScreen> createState() =>
      _PrivacyPolicyListScreenState();
}

class _PrivacyPolicyListScreenState extends State<PrivacyPolicyListScreen> {
  final PrivacyPolicyContentService _service = PrivacyPolicyContentService();
  List<(String docId, PrivacyPolicy policy)> _policies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final policies = await _service.getPoliciesWithDocIds();
    if (mounted) {
      setState(() {
        _policies = policies;
        _loading = false;
      });
    }
  }

  /// Admin-only: open the add form (with .md file picker) that saves to Firebase.
  Future<void> _addPolicy() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AdminPrivacyPolicyEditScreen(),
      ),
    );
    if (changed == true) _load();
  }

  /// Admin-only: edit an existing policy.
  Future<void> _editPolicy(String docId, PrivacyPolicy policy) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminPrivacyPolicyEditScreen(
          docId: docId,
          initialPolicy: policy,
        ),
      ),
    );
    if (changed == true) _load();
  }

  /// Admin-only: delete a policy after confirmation.
  Future<void> _deletePolicy(String docId, PrivacyPolicy policy) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${policy.appName}" policy?',
            style: GoogleFonts.roboto(color: Colors.white)),
        content: Text(
          'This removes the privacy policy from the site. You can add it again later.',
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
              content: Text('Policy removed'), backgroundColor: Colors.orange),
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isAdmin = AdminService.isAdmin();

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _addPolicy,
              backgroundColor: ColorManager.orange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file),
              label: Text(
                'Add policy',
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      appBar: FrostedAppBar.darkNavy(
        iconTheme: const IconThemeData(color: Colors.amber),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        title: Text(
          'Privacy Policies',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
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
                : _policies.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            isAdmin
                                ? 'No policies yet. Tap "Add policy" to upload a .md file.'
                                : 'Privacy policies will appear here soon.',
                            style: GoogleFonts.roboto(
                                color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: ListView.separated(
                            padding: EdgeInsets.all(isMobile ? 16 : 24),
                            itemCount: _policies.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final entry = _policies[index];
                              return _buildTile(
                                  entry.$1, entry.$2, isMobile, isAdmin);
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
      String docId, PrivacyPolicy policy, bool isMobile, bool isAdmin) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(
          AppRoutes.privacyPolicyPath(
              policy.slug.isNotEmpty ? policy.slug : docId),
          extra: policy,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Row(
            children: [
              const Icon(Icons.privacy_tip_outlined,
                  color: ColorManager.orange),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${policy.appName} — Privacy Policy',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (policy.lastUpdated.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Last updated ${policy.lastUpdated}',
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: ColorManager.orange),
                  tooltip: 'Edit',
                  onPressed: () => _editPolicy(docId, policy),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.withValues(alpha: 0.9)),
                  tooltip: 'Delete',
                  onPressed: () => _deletePolicy(docId, policy),
                ),
              ] else
                const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
