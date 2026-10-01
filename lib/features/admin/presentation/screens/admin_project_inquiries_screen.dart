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
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
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

  static const _dialogColor = Color(0xFF111827);
  static const _fieldColor = Color(0xFF172033);

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
      case 'closed':
        return Colors.grey;
      default:
        return Colors.white70;
    }
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: _fieldColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorManager.accentGold, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _manage(Map<String, dynamic> inquiry) async {
    final reply =
        TextEditingController(text: inquiry['adminReply']?.toString() ?? '');
    final notes =
        TextEditingController(text: inquiry['adminNotes']?.toString() ?? '');
    var status = inquiry['status']?.toString() ?? 'new';
    if (!_statuses.contains(status)) status = 'new';
    var busy = false;

    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: _dialogColor,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Icon(Icons.forum_outlined, color: ColorManager.accentGold),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Manage inquiry',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${inquiry['name'] ?? ''}  •  ${inquiry['email'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    dropdownColor: _dialogColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Status'),
                    items: _statuses
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(_pretty(item)),
                          ),
                        )
                        .toList(),
                    onChanged: busy
                        ? null
                        : (value) {
                            if (value != null) setLocal(() => status = value);
                          },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reply,
                    minLines: 5,
                    maxLines: 10,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Response to client',
                      hint:
                          'This response appears in the client profile. Send Response also queues the email.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notes,
                    minLines: 3,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Private admin notes',
                      hint: 'Only 4iDeas admins can see these notes.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Any active file attached to this inquiry is automatically included in the response email as a 4ideasapp.com link.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy
                  ? null
                  : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      setLocal(() => busy = true);
                      try {
                        await _service.updateAdminInquiry(
                          inquiryId: inquiry['id'].toString(),
                          status: status,
                          adminReply: reply.text,
                          adminNotes: notes.text,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } catch (e) {
                        setLocal(() => busy = false);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Could not save inquiry: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save draft'),
            ),
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      if (reply.text.trim().isEmpty) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Write a response before sending.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setLocal(() => busy = true);
                      try {
                        final result = await _service.sendAdminResponse(
                          inquiryId: inquiry['id'].toString(),
                          response: reply.text,
                          adminNotes: notes.text,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                        if (mounted) {
                          final fileCount = result['fileCount'] ?? 0;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Response saved and email sent'
                                '${fileCount == 0 ? '.' : ' with $fileCount file link(s).'}',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setLocal(() => busy = false);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Could not send response: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(busy ? 'Working...' : 'Send Response'),
            ),
          ],
        ),
      ),
    );

    reply.dispose();
    notes.dispose();

    if (changed == true) {
      await _load();
    }
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
              'The client must create and verify a 4iDeas account with the same email first. $e',
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
    var busy = false;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: _dialogColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Import existing inquiry',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SizedBox(
            width: 680,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(name, 'Name'),
                  _dialogField(email, 'Email'),
                  _dialogField(company, 'Company (optional)'),
                  _dialogField(projectType, 'Project type'),
                  _dialogField(budget, 'Budget range'),
                  _dialogField(timeline, 'Timeline'),
                  TextField(
                    controller: message,
                    minLines: 4,
                    maxLines: 8,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Message'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  busy ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      final complete = name.text.trim().isNotEmpty &&
                          email.text.trim().isNotEmpty &&
                          projectType.text.trim().isNotEmpty &&
                          budget.text.trim().isNotEmpty &&
                          timeline.text.trim().isNotEmpty &&
                          message.text.trim().isNotEmpty;
                      if (!complete) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please complete all required fields.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setLocal(() => busy = true);
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
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } catch (e) {
                        setLocal(() => busy = false);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Import failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_for_offline_outlined),
              label: Text(busy ? 'Importing...' : 'Import'),
            ),
          ],
        ),
      ),
    );

    for (final controller in <TextEditingController>[
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

    if (saved == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Existing inquiry imported.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _load();
    }
  }

  Widget _dialogField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
      ),
    );
  }

  void _addFile(Map<String, dynamic> inquiry) {
    context.push(
      AppRoutes.adminFiles,
      extra: <String, dynamic>{
        'inquiryId': inquiry['id']?.toString() ?? '',
        'clientEmail': inquiry['email']?.toString() ?? '',
        'clientName': inquiry['name']?.toString() ?? '',
      },
    );
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
            tooltip: 'Files & Documents',
            onPressed: () => context.push(AppRoutes.adminFiles),
            icon: const Icon(Icons.folder_copy_outlined),
          ),
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
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              isMobile ? 14 : 26,
                              18,
                              isMobile ? 14 : 26,
                              48,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) => Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1120),
                                child: _card(_items[index], isMobile),
                              ),
                            ),
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
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorManager.accentGold.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                inquiry['name']?.toString() ?? 'Unknown',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _statusPill(_pretty(status), statusColor),
            ],
          ),
          const SizedBox(height: 5),
          SelectableText(
            inquiry['email']?.toString() ?? '',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Text(
            inquiry['projectType']?.toString() ?? '',
            style: TextStyle(
              color: ColorManager.accentGold,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${inquiry['budgetRange'] ?? ''}  •  ${inquiry['timeline'] ?? ''}',
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 12),
          Text(
            inquiry['message']?.toString() ?? '',
            style: const TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 15,
            ),
          ),
          if (adminReply.isNotEmpty) ...[
            const SizedBox(height: 14),
            _messageBox(
              '4iDeas response',
              adminReply,
              ColorManager.primaryTeal,
            ),
          ],
          if (clientReply.isNotEmpty) ...[
            const SizedBox(height: 10),
            _messageBox(
              'Client reply',
              clientReply,
              Colors.greenAccent,
            ),
          ],
          if (linkedOrderId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Project created: $linkedOrderId',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _manage(inquiry),
                icon: const Icon(Icons.mark_email_read_outlined),
                label: const Text('Manage / Respond'),
              ),
              OutlinedButton.icon(
                onPressed: () => _addFile(inquiry),
                icon: const Icon(Icons.attach_file),
                label: const Text('Add File'),
              ),
              if (status != 'converted')
                OutlinedButton.icon(
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

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _messageBox(String title, String body, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
        ],
      ),
    );
  }
}
