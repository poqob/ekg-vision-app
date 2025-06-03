import 'package:flutter/material.dart';
import '../../constants/app_info.dart';
import '../../constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('About'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite,
                    color: Theme.of(context).colorScheme.primary, size: 36),
                const SizedBox(width: 12),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 24),
            Text(
              'EKG Vision is a modern health application designed to help users manage and analyze their ECG scans with ease. The app provides a user-friendly interface, secure data management, and advanced analysis tools to empower users in monitoring their heart health.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Developed by the ${AppInfo.credits}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Center(
              child: Text(
                '\u00a9 2025 EKG Vision. All rights reserved.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: isDark ? Colors.white38 : Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
