import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
  }

  Future<List<Scan>> fetchScanResults() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('User not logged in');
    final res = await http.get(
      Uri.parse('http://localhost:8080/scan_results'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => Scan.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch scan results');
    }
  }

  Future<Map<String, dynamic>> fetchPatient(
      String patientId, String token) async {
    final res = await http.get(
      Uri.parse('http://localhost:8080/patient/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch patient');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              String tempQuery = _searchQuery ?? '';
              return AlertDialog(
                title: const Text('Search patient username'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter patient username...',
                  ),
                  controller: TextEditingController(text: tempQuery),
                  onChanged: (value) {
                    tempQuery = value;
                  },
                  onSubmitted: (value) {
                    Navigator.of(context).pop(value.trim());
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(tempQuery.trim()),
                    child: const Text('Search'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('Clear'),
                  ),
                ],
              );
            },
          );
          setState(() {
            _searchQuery = result ?? '';
          });
        },
        tooltip: 'Search patient',
      ),
      body: FutureBuilder<List<Scan>>(
        future: fetchScanResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No EKG scans found.'));
          } else {
            final scanResults = snapshot.data!;
            return FutureBuilder<List<_ScanWithPatientName>>(
              future: _attachPatientNames(scanResults),
              builder: (context, patientSnapshot) {
                if (patientSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (patientSnapshot.hasError) {
                  return Center(
                    child: Text(
                      patientSnapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!patientSnapshot.hasData ||
                    patientSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No EKG scans found.'));
                } else {
                  final resultsWithNames = patientSnapshot.data!;
                  final filteredResults =
                      _searchQuery == null || _searchQuery!.isEmpty
                          ? resultsWithNames
                          : resultsWithNames
                              .where((s) => (s.patientName ?? '')
                                  .toLowerCase()
                                  .contains(_searchQuery!.toLowerCase()))
                              .toList();
                  return ListView.builder(
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final scanWithName = filteredResults[index];
                      final scan = scanWithName.scan;
                      return ListTile(
                        leading: scan.image.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(
                                  base64Decode(scan.image),
                                ),
                              )
                            : const Icon(Icons.favorite),
                        title:
                            Text(scanWithName.patientName ?? 'Unknown Patient'),
                        subtitle: Text(
                            'Model: ${scan.modelName}\nDate: ${_formatDate(scan.date)}'),
                        trailing: _buildNormalAnormalCounts(scan.boxes),
                        onTap: () {
                          // TODO: Show scan details or open file
                        },
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format as yyyy-MM-dd HH:mm (no milliseconds)
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<List<_ScanWithPatientName>> _attachPatientNames(
      List<Scan> scans) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null)
      return scans
          .map((s) => _ScanWithPatientName(scan: s, patientName: null))
          .toList();
    final Map<String, String> patientNameCache = {};
    List<_ScanWithPatientName> result = [];
    for (final scan in scans) {
      final patientId = scan.patientId;
      if (patientId.isNotEmpty && !patientNameCache.containsKey(patientId)) {
        try {
          final patient = await fetchPatient(patientId, token);
          patientNameCache[patientId] =
              patient['username'] ?? 'Unknown Patient';
        } catch (_) {
          patientNameCache[patientId] = 'Unknown Patient';
        }
      }
      result.add(_ScanWithPatientName(
          scan: scan,
          patientName: patientNameCache[patientId] ?? 'Unknown Patient'));
    }
    return result;
  }

  Widget _buildNormalAnormalCounts(List<dynamic> boxes) {
    int normal = 0;
    int anormal = 0;
    for (final box in boxes) {
      if (box is Map && box.containsKey('class')) {
        if (box['class'] == 0) {
          anormal++;
        } else {
          normal++;
        }
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Normal: $normal',
                style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 2),
            Text('Anormal: $anormal',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _ScanWithPatientName {
  final Scan scan;
  final String? patientName;
  _ScanWithPatientName({required this.scan, required this.patientName});
}

class Scan {
  final String id;
  final String userId;
  final String patientId;
  final String modelName;
  final DateTime date;
  final String image;
  final String resultImage;
  final List<dynamic> boxes;

  Scan({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.modelName,
    required this.date,
    required this.image,
    required this.resultImage,
    required this.boxes,
  });

  factory Scan.fromJson(Map<String, dynamic> json) {
    // Parse _id
    String parseId(dynamic id) {
      if (id is String) return id;
      if (id is Map && (id.containsKey('4oid') || id.containsKey('4Id'))) {
        return id['\u00024oid']?.toString() ??
            id['\u00024Id']?.toString() ??
            '';
      }
      return '';
    }

    // Parse patient_id
    String parsePatientId(dynamic pid) {
      if (pid is String) {
        // Handles ObjectId("...") or ObjectId('...')
        final regex = RegExp(r'ObjectId\((?:\"|\")(.*?)(?:\"|\")\)');
        final match = regex.firstMatch(pid);
        if (match != null) return match.group(1)!;
        return pid;
      }
      if (pid is Map && (pid.containsKey('4oid') || pid.containsKey('4Id'))) {
        return pid['\u00024oid']?.toString() ??
            pid['\u00024Id']?.toString() ??
            '';
      }
      return '';
    }

    // Parse date
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

    return Scan(
      id: parseId(json['_id']),
      userId: json['user_id']?.toString() ?? '',
      patientId: parsePatientId(json['patient_id']),
      modelName: json['model_name']?.toString() ?? '',
      date: parseDate(json['date']),
      image: json['image']?.toString() ?? '',
      resultImage: json['result_image']?.toString() ?? '',
      boxes: json['boxes'] ?? [],
    );
  }
}
