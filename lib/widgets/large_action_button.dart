import 'package:flutter/material.dart';

class LargeActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final bool enabled;

  const LargeActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 150,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: icon,
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.black : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
