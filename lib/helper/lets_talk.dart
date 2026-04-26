import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/design_system/theme.dart';

const String kHomePhoneDigits = '8047749008';

Future<void> launchHomePhone() async {
  final uri = Uri(scheme: 'tel', path: kHomePhoneDigits);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Phone / contact chooser; used from home and hero.
void showLetsTalkDialog(BuildContext context) {
  showDialog<String>(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        title: const Text(
          "Let's Talk",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tap the number or use the Call now button to place a call.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: AppColors.borderColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => Navigator.of(dialogContext).pop('call'),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: AppColors.primaryGold, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '(804) 774-9008',
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('dismissed'),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('call'),
            child: const Text('Call now',
                style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    },
  ).then((result) {
    if (result == 'call') {
      launchHomePhone();
    }
  });
}
