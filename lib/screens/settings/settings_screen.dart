import 'package:flutter/material.dart';
import '../../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Theme Section
          _buildSectionHeader(context, 'Appearance'),

          // Dark Mode Toggle
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Mode',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        ThemeToggleSwitch(
                          value: isDark,
                          onChanged: (value) {
                            appState.setDarkMode(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Switch between light and dark theme',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Other Settings Sections
          _buildSectionHeader(context, 'Account'),
          _buildSettingItem(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              // TODO: Implement change password navigation
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.email_outlined,
            title: 'Change Email',
            subtitle: 'Update your account email',
            onTap: () {
              // TODO: Implement change email navigation
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}

class ThemeToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ThemeToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 36,
        width: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background icons
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Icon(
                Icons.wb_sunny,
                size: 18,
                color: value ? Colors.grey.shade600 : Colors.orange,
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Icon(
                Icons.nightlight_round,
                size: 18,
                color: value ? Colors.white : Colors.grey.shade400,
              ),
            ),
            // Sliding circle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: value ? 36 : 4,
              top: 4,
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? Colors.white : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
