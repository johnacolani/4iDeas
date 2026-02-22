import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../core/ColorManager.dart';
import '../data/contact_data.dart';
import '../services/contact_content_service.dart';
import '../services/admin_service.dart';
import '../features/admin/presentation/widgets/contact_entry_edit_dialog.dart';

class AlertDialogData extends StatefulWidget {
  const AlertDialogData({
    super.key,
    required this.wi,
    required this.he,
  });

  final double wi;
  final double he;

  @override
  State<AlertDialogData> createState() => _AlertDialogDataState();
}

class _AlertDialogDataState extends State<AlertDialogData> {
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
        Navigator.of(context).pop();
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
        title: Text('Delete "${entry.label}"?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will remove this contact entry.',
          style: TextStyle(color: Colors.white70),
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
    final bool isMobile = widget.wi < 600;
    final bool isTablet = widget.wi >= 600 && widget.wi < 1024;
    final isAdmin = AdminService.isAdmin();
    final entriesFromFirestore = _entriesFromFirestore != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? widget.wi * 0.9 : (isTablet ? 400 : 450),
          maxHeight: widget.he * 0.85,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4B556E).withValues(alpha: 0.95),
              const Color(0xFF2D3748).withValues(alpha: 0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                Container(
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
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
                            color: ColorManager.orange.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: isMobile ? 35 : 40,
                          backgroundImage:
                              const AssetImage('assets/images/logo.png'),
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'John A. Colani',
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 24,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.orange,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Senior Product Designer',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                // Contact Information Section
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
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
                                color: Colors.white.withValues(alpha: 0.2),
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
                SizedBox(height: isMobile ? 20 : 24),
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.orange.withValues(alpha: 0.2),
                      foregroundColor: ColorManager.white,
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: ColorManager.orange.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 17,
                        fontWeight: FontWeight.bold,
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
    Widget content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorManager.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ColorManager.orange, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    entry.value,
                    style: TextStyle(
                      color: Colors.white,
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
                color: Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
    return content;
  }
}
