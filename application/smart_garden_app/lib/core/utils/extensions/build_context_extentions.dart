import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../ui/dialogs/confirm_dialog.dart';

extension BuildContextExtensions on BuildContext {
  void showConfirmDialog({
    String? title = 'Confirm',
    String? content = '',
    VoidCallback? onConfirm,
    String? confirmText = 'Confirm',
    String? cancelText = 'Cancel',
    Color? confirmColor = AppColors.primary,
  }) {
    showDialog(
      context: this,
      builder: (context) => ConfirmDialog(
        tittle: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }
}
