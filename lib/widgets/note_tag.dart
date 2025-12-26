import 'package:flutter/material.dart';

import '../core/constants.dart';

class NoteTag extends StatelessWidget {
  const NoteTag({
    required this.label,
    this.onClosed,
    this.onTap,
    super.key,
  });
  final String label;
  final VoidCallback? onClosed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF3E3E3E) : gray100,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 2,
        ),
        margin: const EdgeInsets.only(right: 4),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: onClosed != null ? 14 : 12,
                color: isDark ? Colors.white70 : gray700,
              ),
            ),
            if (onClosed != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClosed,
                child: const Icon(
                  Icons.close,
                  size: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
