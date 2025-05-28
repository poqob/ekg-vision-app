import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart' as app_routes;
import '../../state/app_state.dart';
import '../../models/doctor.dart' as user_model;
import 'login_history_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _profilePictureBytes;

  @override
  void initState() {
    super.initState();
    _loadProfilePictureFromMemory();
  }

  void _loadProfilePictureFromMemory() async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString('profile_picture_bytes');
    if (b64 != null && b64.isNotEmpty) {
      try {
        setState(() {
          _profilePictureBytes = base64Decode(b64);
        });
      } catch (e) {
        await prefs.remove('profile_picture_bytes');
        setState(() {
          _profilePictureBytes = null;
        });
      }
    } else {
      setState(() {
        _profilePictureBytes = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final user_model.User? user = appState.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Card
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.upload_file),
                                    title: const Text('Upload Profile Picture'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final result = await FilePicker.platform
                                          .pickFiles(type: FileType.image);
                                      if (result != null &&
                                          result.files.single.path != null &&
                                          user != null) {
                                        final filePath =
                                            result.files.single.path!;
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        final token =
                                            prefs.getString('auth_token');
                                        if (token == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Not authenticated.')),
                                          );
                                          return;
                                        }
                                        final uri = Uri.parse(
                                            'http://localhost:8080/upload_profile_picture?userId=${user.id}');
                                        final request = http.MultipartRequest(
                                            'POST', uri)
                                          ..headers['Authorization'] =
                                              'Bearer $token'
                                          ..files.add(
                                              await http.MultipartFile.fromPath(
                                                  'file', filePath));
                                        final response = await request.send();
                                        await response.stream.bytesToString();
                                        if (response.statusCode == 200) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Profile picture uploaded!')),
                                          );
                                          // Download and cache the new profile picture
                                          await _downloadAndCacheProfilePicture(
                                              user.id);
                                          // Load the new profile picture from memory
                                          _loadProfilePictureFromMemory();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Upload failed: ${response.statusCode}')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Shoot a Photo'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      // TODO: Implement camera capture and upload logic
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text('Delete Profile Picture'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      // TODO: Implement delete profile picture logic
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: (_profilePictureBytes != null)
                          ? CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  MemoryImage(_profilePictureBytes!),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: user != null && user.username.isNotEmpty
                                  ? Text(
                                      user.username
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 40, color: Colors.black),
                                    )
                                  : const Icon(Icons.person,
                                      size: 50, color: Colors.black),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name?.isNotEmpty == true
                          ? user!.name!
                          : (user?.username ?? 'User'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProfileActionButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.of(context).pushNamed(app_routes.Routes.settings);
                  },
                ),
                const SizedBox(width: 16),
                _ProfileActionButton(
                  icon: Icons.history,
                  label: 'History',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginHistoryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _ProfileActionButton(
                  icon: Icons.logout,
                  label: 'Logout',
                  color: Colors.red,
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('LOGOUT'),
                          ),
                        ],
                      ),
                    );
                    if (shouldLogout == true && context.mounted) {
                      await appState.logout();
                      Navigator.of(context)
                          .pushReplacementNamed(app_routes.Routes.login);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Details List
            Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AboutScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndCacheProfilePicture(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final ppUrl = 'http://localhost:8080/profile_picture/$userId';
    try {
      final ppResponse = await http.get(Uri.parse(ppUrl));
      if (ppResponse.statusCode == 200 &&
          ppResponse.headers['content-type']?.startsWith('image/') == true) {
        await prefs.setString(
            'profile_picture_bytes', base64Encode(ppResponse.bodyBytes));
      } else {
        await prefs.remove('profile_picture_bytes');
      }
    } catch (e) {
      await prefs.remove('profile_picture_bytes');
    }
  }
}

// Add a custom action button for quick actions
class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color?.withOpacity(0.08) ??
          Theme.of(context).colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: color ?? Theme.of(context).colorScheme.primary,
                  size: 28),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color ?? Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
