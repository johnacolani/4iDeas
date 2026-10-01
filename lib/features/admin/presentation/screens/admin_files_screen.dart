import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app_router.dart';
import '../../../../core/ColorManager.dart';
import '../../../../core/widgets/frosted_app_bar.dart';
import '../../../../helper/app_background.dart';
import '../../../../services/admin_file_service.dart';
import '../../../../services/admin_service.dart';

class AdminFilesScreen extends StatefulWidget {
  const AdminFilesScreen({
    super.key,
    this.initialInquiryId = '',
    this.initialClientEmail = '',
    this.initialClientName = '',
  });

  final String initialInquiryId;
  final String initialClientEmail;
  final String initialClientName;

  @override
  State<AdminFilesScreen> createState() => _AdminFilesScreenState();
}

class _AdminFilesScreenState extends State<AdminFilesScreen> {
  final AdminFileService _service = AdminFileService();
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  bool _loading = true;
  String? _error;

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.listFiles();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorManager.accentGold, width: 1.4),
      ),
    );
  }

  Future<void> _showUploadDialog() async {
    final title = TextEditingController(
      text: widget.initialClientName.isEmpty
          ? ''
          : 'File for ${widget.initialClientName}',
    );
    final description = TextEditingController();
    final slug = TextEditingController(
      text: widget.initialInquiryId.isEmpty
          ? ''
          : 'client/${widget.initialInquiryId.substring(0, widget.initialInquiryId.length.clamp(0, 10))}',
    );
    final clientEmail =
        TextEditingController(text: widget.initialClientEmail);
    final inquiryId =
        TextEditingController(text: widget.initialInquiryId);
    final orderId = TextEditingController();

    var audience = widget.initialInquiryId.isEmpty ? 'apple' : 'client';
    int? expiresInDays =
        widget.initialInquiryId.isEmpty ? null : 30;
    PlatformFile? selected;
    var uploading = false;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: !uploading,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Add file to 4iDeas',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: uploading
                        ? null
                        : () async {
                            final result = await FilePicker.platform.pickFiles(
                              withData: true,
                              allowMultiple: false,
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setLocal(() {
                                selected = result.files.single;
                                if (title.text.trim().isEmpty) {
                                  title.text = selected!.name;
                                }
                              });
                            }
                          },
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      selected == null
                          ? 'Choose file'
                          : 'Selected: ${selected!.name}',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: title,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: description,
                    minLines: 2,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Description (optional)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: audience,
                    dropdownColor: const Color(0xFF1F2937),
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Audience'),
                    items: const [
                      DropdownMenuItem(
                        value: 'apple',
                        child: Text('Apple Review'),
                      ),
                      DropdownMenuItem(
                        value: 'client',
                        child: Text('Client'),
                      ),
                      DropdownMenuItem(
                        value: 'public',
                        child: Text('Public / unlisted'),
                      ),
                    ],
                    onChanged: uploading
                        ? null
                        : (value) {
                            if (value != null) {
                              setLocal(() => audience = value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: slug,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration(
                      '4iDeas share path',
                      hint: audience == 'apple'
                          ? 'apple/4icad-review'
                          : 'client/proposal-abc123',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Link: https://4ideasapp.com/share/${AdminFileService.normalizeSlug(slug.text)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  if (audience == 'client') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: clientEmail,
                      style: const TextStyle(color: Colors.white),
                      decoration: _decoration('Client email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: inquiryId,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _decoration('Inquiry id (optional)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: orderId,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _decoration('Project / order id (optional)'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: expiresInDays,
                    dropdownColor: const Color(0xFF1F2937),
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Link expiration'),
                    items: const [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Never'),
                      ),
                      DropdownMenuItem<int?>(
                        value: 7,
                        child: Text('7 days'),
                      ),
                      DropdownMenuItem<int?>(
                        value: 30,
                        child: Text('30 days'),
                      ),
                      DropdownMenuItem<int?>(
                        value: 90,
                        child: Text('90 days'),
                      ),
                    ],
                    onChanged: uploading
                        ? null
                        : (value) =>
                            setLocal(() => expiresInDays = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  uploading ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: uploading
                  ? null
                  : () async {
                      if (selected == null ||
                          title.text.trim().isEmpty ||
                          slug.text.trim().isEmpty) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Choose a file, title, and share path.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setLocal(() => uploading = true);
                      try {
                        await _service.uploadFile(
                          file: selected!,
                          title: title.text,
                          description: description.text,
                          slug: slug.text,
                          audience: audience,
                          clientEmail: clientEmail.text,
                          inquiryId: inquiryId.text,
                          orderId: orderId.text,
                          expiresInDays: expiresInDays,
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } catch (e) {
                        setLocal(() => uploading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Upload failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              icon: uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(uploading ? 'Uploading...' : 'Upload'),
            ),
          ],
        ),
      ),
    );

    for (final controller in <TextEditingController>[
      title,
      description,
      slug,
      clientEmail,
      inquiryId,
      orderId,
    ]) {
      controller.dispose();
    }

    if (saved == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded. The 4iDeas link is ready.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _load();
    }
  }

  Future<void> _replace(Map<String, dynamic> item) async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    try {
      await _service.replaceFile(item: item, file: result.files.single);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File replaced. The share URL did not change.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Replace failed: $e')),
        );
      }
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete shared file?'),
        content: const Text(
          'The 4iDeas share link will stop working immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    await _service.deleteFile(item);
    await _load();
  }

  String _formatBytes(dynamic value) {
    final bytes = value is num ? value.toDouble() : 0;
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar.gold(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        title: Text(
          'Admin - Files & Documents',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 18 : 22,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Upload file',
            onPressed: _showUploadDialog,
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        backgroundColor: ColorManager.accentGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload file'),
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
                              'No shared files yet.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              isMobile ? 14 : 28,
                              18,
                              isMobile ? 14 : 28,
                              110,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) =>
                                _fileCard(_items[index], isMobile),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _fileCard(Map<String, dynamic> item, bool isMobile) {
    final slug = item['slug']?.toString() ?? '';
    final url = AdminFileService.shareUrl(slug);
    final active = item['active'] == true;
    final audience = item['audience']?.toString() ?? 'public';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ColorManager.accentGold.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                item['title']?.toString() ?? item['fileName']?.toString() ?? '',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: isMobile ? 17 : 20,
                ),
              ),
              _pill(
                audience == 'apple'
                    ? 'Apple Review'
                    : audience == 'client'
                        ? 'Client'
                        : 'Public',
                ColorManager.accentGold,
              ),
              _pill(active ? 'Active' : 'Disabled',
                  active ? Colors.greenAccent : Colors.redAccent),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item['fileName'] ?? ''} • ${_formatBytes(item['sizeBytes'])}',
            style: const TextStyle(color: Colors.white60),
          ),
          if ((item['clientEmail']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Client: ${item['clientEmail']}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
          const SizedBox(height: 12),
          SelectableText(
            url,
            style: TextStyle(
              color: ColorManager.primaryTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('4iDeas link copied.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy link'),
              ),
              OutlinedButton.icon(
                onPressed: active
                    ? () => launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.platformDefault,
                        )
                    : null,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
              ),
              OutlinedButton.icon(
                onPressed: () => _replace(item),
                icon: const Icon(Icons.sync_alt),
                label: const Text('Replace file'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await _service.setActive(
                    item['id'].toString(),
                    !active,
                  );
                  await _load();
                },
                icon: Icon(active ? Icons.link_off : Icons.link),
                label: Text(active ? 'Disable link' : 'Enable link'),
              ),
              TextButton.icon(
                onPressed: () => _delete(item),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
