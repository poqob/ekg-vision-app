import 'package:flutter/material.dart';
import '../../constants/app_info.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Information')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Version'),
              subtitle: Text(AppInfo.version),
            ),
            const Divider(),
            ListTile(
              title: const Text('Credits'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Mustafa BİÇER'),
                  SizedBox(height: 4),
                  Text('https://github.com/poqob'),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('License'),
              subtitle: SelectableText(AppInfo.license),
            ),
            const Divider(),
            ListTile(
              title: const Text('Privacy Policy'),
              subtitle: const Text(
                'This application is a thesis project and is intended solely for academic and research purposes. No commercial use is intended or permitted.\n\nWe do not collect, store, or share any personal data for commercial gain. All data processed by this application is used exclusively for the purposes of the thesis and is handled with care and confidentiality.\n\nBy using this application, you acknowledge that it is provided as-is, without warranty, and solely for non-commercial, educational, or research use.',
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
