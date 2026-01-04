import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String? tittle;
  final String? content;
  final String? cancelText;
  final String? confirmText;
  final Color? confirmColor;
  final VoidCallback? onConfirm;
  const ConfirmDialog({
    super.key,
    this.tittle = 'Confirm',
    this.content,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.confirmColor = AppColors.primary,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.all(AppConstants.paddingMd),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMd,
        vertical: AppConstants.paddingSm,
      ),
      actionsPadding: const EdgeInsets.all(AppConstants.paddingMd),
      title: Text(tittle!),
      content: Text(content ?? ''),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText!),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            if (onConfirm != null) {
              onConfirm!();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          child: Text(confirmText!),
        ),
      ],
    );
  }
}
