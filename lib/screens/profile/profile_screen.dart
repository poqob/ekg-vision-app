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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                              final filePath = result.files.single.path!;
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final token = prefs.getString('auth_token');
                              if (token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Not authenticated.')),
                                );
                                return;
                              }
                              final uri = Uri.parse(
                                  'http://localhost:8080/upload_profile_picture?userId=${user.id}');
                              final request = http.MultipartRequest('POST', uri)
                                ..headers['Authorization'] = 'Bearer $token'
                                ..files.add(await http.MultipartFile.fromPath(
                                    'file', filePath));
                              final response = await request.send();
                              await response.stream.bytesToString();
                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Profile picture uploaded!')),
                                );
                                // Download and cache the new profile picture
                                await _downloadAndCacheProfilePicture(user.id);
                                // Load the new profile picture from memory
                                _loadProfilePictureFromMemory();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
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
                    backgroundImage: MemoryImage(_profilePictureBytes!),
                  )
                : CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: user != null && user.username.isNotEmpty
                        ? Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                fontSize: 40, color: Colors.black),
                          )
                        : const Icon(Icons.person,
                            size: 50, color: Colors.black),
                  ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 40),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
              Navigator.of(context).pushNamed(app_routes.Routes.settings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginHistoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Show about dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Show confirmation dialog
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
                // Perform logout
                await appState.logout();

                // Navigate to login screen
                Navigator.of(context)
                    .pushReplacementNamed(app_routes.Routes.login);
              }
            },
          ),
        ],
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
