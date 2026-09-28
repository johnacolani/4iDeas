import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app_router.dart';
import '../../../../core/ColorManager.dart';
import '../../../../core/widgets/frosted_app_bar.dart';
import '../../../../helper/app_background.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/project_inquiry_service.dart';

class AdminProjectInquiriesScreen extends StatefulWidget {
  const AdminProjectInquiriesScreen({super.key});

  @override
  State<AdminProjectInquiriesScreen> createState() =>
      _AdminProjectInquiriesScreenState();
}

class _AdminProjectInquiriesScreenState
    extends State<AdminProjectInquiriesScreen> {
  final ProjectInquiryService _service = ProjectInquiryService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  static const _statuses = <String>[
    'new',
    'contacted',
    'qualified',
    'awaiting_client',
    'client_replied',
    'closed',
    'converted',
  ];

  @override
  void initState() {
    super.initState();
    if (!AdminService.isAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.home);
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
      final items = await _service.getAdminInquiries();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _pretty(String value) => value
      .split('_')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return ColorManager.accentGold;
      case 'contacted':
        return Colors.blueAccent;
      case 'qualified':
        return ColorManager.primaryTeal;
      case 'awaiting_client':
        return Colors.orangeAccent;
      case 'client_replied':
        return Colors.greenAccent;
      case 'converted':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _manage(Map<String, dynamic> inquiry) async {
    final reply =
        TextEditingController(text: inquiry['adminReply']?.toString() ?? '');
    final notes =
        TextEditingController(text: inquiry['adminNotes']?.toString() ?? '');
    var status = inquiry['status']?.toString() ?? 'new';
    if (!_statuses.contains(status)) status = 'new';

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: ColorManager.containerSurface,
          title: Text(
            'Manage inquiry',
            style: GoogleFonts.roboto(
              color: ColorManager.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${inquiry['name'] ?? ''} | ${inquiry['email'] ?? ''}',
                    style: TextStyle(color: ColorManager.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statuses
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(_pretty(item)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setLocal(() => status = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reply,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Response to client',
                      hintText:
                          'Visible in the client 4iDeas profile after they sign in with the same verified email.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notes,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Private admin notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (save == true) {
      try {
        await _service.updateAdminInquiry(
          inquiryId: inquiry['id'].toString(),
          status: status,
          adminReply: reply.text,
          adminNotes: notes.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inquiry updated in 4iDeas.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not update inquiry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    reply.dispose();
    notes.dispose();
  }

  Future<void> _convert(Map<String, dynamic> inquiry) async {
    try {
      final orderId =
          await _service.convertInquiryToProject(inquiry['id'].toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Converted to project $orderId'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'The client must first create and verify a 4iDeas account with the same email. $e',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _importExisting() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final company = TextEditingController();
    final projectType = TextEditingController();
    final budget = TextEditingController();
    final timeline = TextEditingController();
    final message = TextEditingController();

    Widget field(TextEditingController controller, String label) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
        );

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorManager.containerSurface,
        title: const Text('Import existing inquiry'),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(name, 'Name'),
                field(email, 'Email'),
                field(company, 'Company (optional)'),
                field(projectType, 'Project type'),
                field(budget, 'Budget range'),
                field(timeline, 'Timeline'),
                TextField(
                  controller: message,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (save == true) {
      final complete = name.text.trim().isNotEmpty &&
          email.text.trim().isNotEmpty &&
          projectType.text.trim().isNotEmpty &&
          budget.text.trim().isNotEmpty &&
          timeline.text.trim().isNotEmpty &&
          message.text.trim().isNotEmpty;

      if (!complete) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete all required fields.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        try {
          await _service.createImportedInquiry(
            name: name.text,
            email: email.text,
            company: company.text,
            projectType: projectType.text,
            budgetRange: budget.text,
            timeline: timeline.text,
            message: message.text,
            source: 'formspree_manual_import',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Existing inquiry imported.'),
                backgroundColor: Colors.green,
              ),
            );
          }
          await _load();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Import failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    for (final controller in [
      name,
      email,
      company,
      projectType,
      budget,
      timeline,
      message,
    ]) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        title: Text(
          'Admin - Project Inquiries',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: isMobile ? 19 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Import existing inquiry',
            onPressed: _importExisting,
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: FrostedAppBar.contentPaddingUnderAppBar(context),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : _items.isEmpty
                        ? Center(
                            child: Text(
                              'No project inquiries yet.',
                              style: TextStyle(
                                color: ColorManager.textSecondary,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(isMobile ? 14 : 24),
                            itemCount: _items.length,
                            itemBuilder: (context, index) =>
                                _card(_items[index], isMobile),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> inquiry, bool isMobile) {
    final status = inquiry['status']?.toString() ?? 'new';
    final statusColor = _statusColor(status);
    final adminReply = inquiry['adminReply']?.toString() ?? '';
    final clientReply = inquiry['clientReply']?.toString() ?? '';
    final linkedOrderId = inquiry['linkedOrderId']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: ColorManager.adminPanelCardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inquiry['name']?.toString() ?? 'Unknown',
                    style: GoogleFonts.roboto(
                      color: ColorManager.textPrimary,
                      fontSize: isMobile ? 18 : 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    inquiry['email']?.toString() ?? '',
                    style: TextStyle(color: ColorManager.textSecondary),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.45)),
                ),
                child: Text(
                  _pretty(status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            inquiry['projectType']?.toString() ?? '',
            style: TextStyle(
              color: ColorManager.accentGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${inquiry['budgetRange'] ?? ''} | ${inquiry['timeline'] ?? ''}',
            style: TextStyle(color: ColorManager.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(
            inquiry['message']?.toString() ?? '',
            style: TextStyle(
              color: ColorManager.textPrimary,
              height: 1.45,
            ),
          ),
          if (adminReply.isNotEmpty) ...[
            const SizedBox(height: 12),
            _messageBox('4iDeas response', adminReply, ColorManager.primaryTeal),
          ],
          if (clientReply.isNotEmpty) ...[
            const SizedBox(height: 10),
            _messageBox('Client reply', clientReply, Colors.greenAccent),
          ],
          if (linkedOrderId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Project created: $linkedOrderId',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _manage(inquiry),
                icon: const Icon(Icons.edit_note),
                label: const Text('Manage / Respond'),
              ),
              if (status != 'converted')
                FilledButton.icon(
                  onPressed: () => _convert(inquiry),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Convert to Project'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageBox(String title, String body, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: ColorManager.textPrimary)),
        ],
      ),
    );
  }
}
