import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _policy = '''
This application is a thesis project and is intended solely for academic and research purposes. No commercial use is intended or permitted.

We do not collect, store, or share any personal data for commercial gain. All data processed by this application is used exclusively for the purposes of the thesis and is handled with care and confidentiality.

By using this application, you acknowledge that it is provided as-is, without warranty, and solely for non-commercial, educational, or research use.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(_policy, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
