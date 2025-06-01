import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_config.dart';
import '../../constants/api_endpoints.dart';

class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends State<LoginHistoryScreen> {
  late Future<List<LoginHistoryEntry>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = fetchLoginHistory();
  }

  Future<List<LoginHistoryEntry>> fetchLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('User not logged in');
    final res = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}${ApiEndpoints.loginHistory}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => LoginHistoryEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch login history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login History'),
      ),
      body: FutureBuilder<List<LoginHistoryEntry>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No login history found.'));
          } else {
            final history = snapshot.data!;
            return ListView.separated(
              itemCount: history.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final entry = history[i];
                return ListTile(
                  leading: Icon(
                    entry.status == 'success'
                        ? Icons.check_circle
                        : Icons.error,
                    color:
                        entry.status == 'success' ? Colors.green : Colors.red,
                  ),
                  title: Text(entry.username),
                  subtitle: Text(
                    'Date: ${entry.formatDate()}\nIP: ${entry.ip ?? '-'}\nAgent: ${entry.userAgent ?? '-'}',
                  ),
                  trailing: Text(entry.status,
                      style: TextStyle(
                        color: entry.status == 'success'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class LoginHistoryEntry {
  final String id;
  final String userId;
  final String email;
  final String username;
  final DateTime timestamp;
  final String? ip;
  final String? userAgent;
  final String status;

  LoginHistoryEntry({
    required this.id,
    required this.userId,
    required this.email,
    required this.username,
    required this.timestamp,
    required this.ip,
    required this.userAgent,
    required this.status,
  });

  factory LoginHistoryEntry.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic id) {
      if (id is String) return id;
      if (id is Map && (id.containsKey('4oid') || id.containsKey('4Id'))) {
        return id['\u00024oid']?.toString() ??
            id['\u00024Id']?.toString() ??
            '';
      }
      return '';
    }

    DateTime parseDate(dynamic date) {
      if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      if (date is Map && date.containsKey('4date')) {
        return DateTime.tryParse(date['\u00024date'].toString()) ??
            DateTime.now();
      }
      return DateTime.now();
    }

    return LoginHistoryEntry(
      id: parseId(json['_id']),
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      timestamp: parseDate(json['timestamp']),
      ip: json['ip']?.toString(),
      userAgent: json['user_agent']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }

  String formatDate() {
    return '${timestamp.year.toString().padLeft(4, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
