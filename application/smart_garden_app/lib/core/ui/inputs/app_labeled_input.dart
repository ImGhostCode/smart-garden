import 'package:flutter/material.dart';

class LabeledInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final Widget child;

  const LabeledInput({
    super.key,
    required this.label,
    this.hintText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (hintText != null) ...[
          const SizedBox(height: 4),
          Text(hintText!, style: TextStyle(color: Colors.grey.shade600)),
        ],
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
