import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/ColorManager.dart';
import '../core/home_warm_colors.dart';
import '../data/contact_data.dart';
import '../services/contact_content_service.dart';
import '../services/admin_service.dart';
import '../features/admin/presentation/widgets/contact_entry_edit_dialog.dart';

/// Contact list + actions. Used by [ContactUsScreen] (route) and [AlertDialogData] (modal).
class ContactUsContent extends StatefulWidget {
  const ContactUsContent({
    super.key,
    required this.embeddedInDialog,
    this.paddingOverride,
  });

  /// When true, shows a Close button and pops the route stack on navigate entries.
  final bool embeddedInDialog;

  /// When null, uses default screen padding. Pass [EdgeInsets.zero] when the parent already pads.
  final EdgeInsetsGeometry? paddingOverride;

  @override
  State<ContactUsContent> createState() => _ContactUsContentState();
}

class _ContactUsContentState extends State<ContactUsContent> {
  final ContactContentService _contactService = ContactContentService();
  List<ContactEntry>? _entriesFromFirestore;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final hasAny = await _contactService.hasEntries();
      if (hasAny) {
        final list = await _contactService.getEntries();
        if (mounted) setState(() => _entriesFromFirestore = list);
      }
    } catch (_) {}
  }

  List<ContactEntry> get _displayEntries =>
      (_entriesFromFirestore != null && _entriesFromFirestore!.isNotEmpty)
          ? _entriesFromFirestore!
          : ContactData.defaultEntries;

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''));
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onEntryTap(ContactEntry entry) {
    switch (entry.type) {
      case 'phone':
        _launchPhone(entry.value);
        break;
      case 'email':
        _launchEmail(entry.value);
        break;
      case 'link':
        if (entry.urlOrRoute != null) _launchURL(entry.urlOrRoute!);
        break;
      case 'navigate':
        if (widget.embeddedInDialog && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        if (entry.urlOrRoute != null) context.go(entry.urlOrRoute!);
        break;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'link':
        return Icons.work;
      case 'navigate':
        return Icons.public;
      default:
        return Icons.contact_page;
    }
  }

  Future<void> _openAddContact() async {
    final entry = await showContactEntryEditDialog(context, initial: null);
    if (entry == null || !mounted) return;
    try {
      await _contactService.addEntry(entry);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact added'), backgroundColor: Colors.green),
        );
        _loadContacts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openEditContact(ContactEntry entry) async {
    final updated = await showContactEntryEditDialog(context, initial: entry);
    if (updated == null || !mounted) return;
    try {
      await _contactService.updateEntry(entry.id, updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact updated'), backgroundColor: Colors.green),
        );
        _loadContacts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteContact(ContactEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1a1a2e),
        title: Text('Delete "${entry.label}"?', style: TextStyle(color: ColorManager.accentGoldDark)),
        content: Text(
          'This will remove this contact entry.',
          style: TextStyle(color: ColorManager.accentGoldDark.withValues(alpha: 0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: ColorManager.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _contactService.deleteEntry(entry.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact removed'), backgroundColor: Colors.orange),
        );
        _loadContacts();
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
    final wi = MediaQuery.sizeOf(context).width;
    final he = MediaQuery.sizeOf(context).height;
    final bool isMobile = wi < 600;
    final isAdmin = AdminService.isAdmin();
    final entriesFromFirestore = _entriesFromFirestore != null;

    return Padding(
      padding: widget.paddingOverride ??
          EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HomeWarmColors.shellTop.withValues(alpha: 0.95),
                  HomeWarmColors.shellBottom.withValues(alpha: 0.88),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HomeWarmColors.appBarBorderBottom.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: HomeWarmColors.appBarShadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorManager.accentGold.withValues(alpha: 0.55),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: isMobile ? 35 : 40,
                    backgroundImage: const AssetImage('assets/images/logo.png'),
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'John A. Colani',
                  style: GoogleFonts.albertSans(
                    fontSize: isMobile ? 22 : 24,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Senior Flutter engineer · Product designer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: isMobile ? 14 : 15,
                    color: ColorManager.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 20 : 24),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: ColorManager.containerSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorManager.containerBorder,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                if (isAdmin && entriesFromFirestore) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openAddContact,
                      icon: Icon(Icons.add, size: 18, color: ColorManager.orange),
                      label: Text(
                        'Add contact',
                        style: TextStyle(color: ColorManager.orange, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorManager.orange),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                ..._displayEntries.asMap().entries.map((e) {
                  final entry = e.value;
                  final isLast = e.key == _displayEntries.length - 1;
                  return Column(
                    children: [
                      _buildContactItem(
                        entry: entry,
                        isMobile: isMobile,
                        onTap: () => _onEntryTap(entry),
                        showAdminActions: isAdmin && entriesFromFirestore,
                        onEdit: isAdmin && entriesFromFirestore ? () => _openEditContact(entry) : null,
                        onDelete: isAdmin && entriesFromFirestore ? () => _deleteContact(entry) : null,
                      ),
                      if (!isLast) ...[
                        SizedBox(height: 12),
                        Divider(
                          color: ColorManager.containerBorder,
                          thickness: 1,
                        ),
                        SizedBox(height: 12),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
          if (widget.embeddedInDialog) ...[
            SizedBox(height: isMobile ? 20 : 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.accentGold,
                  foregroundColor: ColorManager.backgroundDark,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.albertSans(
                    fontSize: isMobile ? 16 : 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else
            SizedBox(height: he * 0.04),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required ContactEntry entry,
    required bool isMobile,
    required VoidCallback onTap,
    bool showAdminActions = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final icon = _iconForType(entry.type);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorManager.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ColorManager.primaryTeal, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: TextStyle(
                      color: ColorManager.textMuted,
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    entry.value,
                    style: TextStyle(
                      color: ColorManager.textPrimary,
                      fontSize: isMobile ? 16 : 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (showAdminActions && (onEdit != null || onDelete != null))
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20, color: ColorManager.orange),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: ColorManager.textMuted,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
