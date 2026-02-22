import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/core/ColorManager.dart';
import 'package:four_ideas/data/contact_data.dart';

/// Dialog to add or edit a contact entry. Returns the updated/created entry or null if cancelled.
Future<ContactEntry?> showContactEntryEditDialog(
  BuildContext context, {
  ContactEntry? initial,
}) async {
  return showDialog<ContactEntry>(
    context: context,
    builder: (ctx) => _ContactEntryEditDialog(initial: initial),
  );
}

class _ContactEntryEditDialog extends StatefulWidget {
  final ContactEntry? initial;

  const _ContactEntryEditDialog({this.initial});

  @override
  State<_ContactEntryEditDialog> createState() => _ContactEntryEditDialogState();
}

class _ContactEntryEditDialogState extends State<_ContactEntryEditDialog> {
  late String _type;
  final _labelController = TextEditingController();
  final _valueController = TextEditingController();
  final _urlOrRouteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    if (e != null) {
      _type = e.type;
      _labelController.text = e.label;
      _valueController.text = e.value;
      _urlOrRouteController.text = e.urlOrRoute ?? '';
    } else {
      _type = 'phone';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    _urlOrRouteController.dispose();
    super.dispose();
  }

  ContactEntry _buildEntry() {
    return ContactEntry(
      id: widget.initial?.id ?? 'ce-${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      label: _labelController.text.trim(),
      value: _valueController.text.trim(),
      urlOrRoute: _urlOrRouteController.text.trim().isEmpty ? null : _urlOrRouteController.text.trim(),
      order: widget.initial?.order ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff1a1a2e),
      title: Text(
        widget.initial == null ? 'Add contact' : 'Edit contact',
        style: GoogleFonts.albertSans(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Type',
                style: GoogleFonts.albertSans(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _type,
                dropdownColor: const Color(0xff2d3748),
                style: GoogleFonts.albertSans(color: Colors.white),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'phone', child: Text('Phone')),
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'link', child: Text('Link (URL)')),
                  DropdownMenuItem(value: 'navigate', child: Text('Navigate (in-app)')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'phone'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _labelController,
                style: GoogleFonts.albertSans(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Label',
                  labelStyle: GoogleFonts.albertSans(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueController,
                style: GoogleFonts.albertSans(color: Colors.white),
                decoration: InputDecoration(
                  labelText: _type == 'phone' ? 'Phone number' : _type == 'email' ? 'Email' : 'Display text',
                  labelStyle: GoogleFonts.albertSans(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (_type == 'link' || _type == 'navigate') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _urlOrRouteController,
                  style: GoogleFonts.albertSans(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: _type == 'navigate' ? 'Route (e.g. /portfolio)' : 'URL',
                    labelStyle: GoogleFonts.albertSans(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ColorManager.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: GoogleFonts.albertSans(color: ColorManager.orange)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_labelController.text.trim().isEmpty || _valueController.text.trim().isEmpty) return;
            if ((_type == 'link' || _type == 'navigate') && _urlOrRouteController.text.trim().isEmpty) return;
            Navigator.of(context).pop(_buildEntry());
          },
          style: ElevatedButton.styleFrom(backgroundColor: ColorManager.orange, foregroundColor: Colors.white),
          child: Text(widget.initial == null ? 'Add' : 'Save', style: GoogleFonts.albertSans(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
