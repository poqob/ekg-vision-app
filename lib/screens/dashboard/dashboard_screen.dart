import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../state/app_state.dart';
import '../../widgets/large_action_button.dart';
import '../../constants/app_config.dart';
import '../../constants/api_endpoints.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String serviceUrl = AppConfig.modelServiceUrl; // Add this to AppConfig
  List<String> models = [];
  String? selectedModel;
  File? imageFile;
  bool loading = false;
  String? error;
  List<Map<String, dynamic>> boxes = [];
  String? resultImageUrl;
  List<Map<String, dynamic>> patients = [];
  Map<String, dynamic>? selectedPatient;

  @override
  void initState() {
    super.initState();
    fetchModels();
    fetchPatients();
  }

  Future<void> fetchModels() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res =
          await http.get(Uri.parse('$serviceUrl${ApiEndpoints.models}'));
      final data = json.decode(res.body);
      setState(() {
        models = List<String>.from(data['models'] ?? []);
        if (models.isNotEmpty) selectedModel = models.first;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch models';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchPatients() async {
    try {
      final res = await http
          .get(Uri.parse('${AppConfig.apiBaseUrl}${ApiEndpoints.patients}'));
      final List<dynamic> data = json.decode(res.body);
      setState(() {
        patients = List<Map<String, dynamic>>.from(data);
        if (patients.isNotEmpty) selectedPatient = patients.first;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch patients';
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> detect() async {
    // Get logged in user id from AppStateProvider
    final appState = AppStateProvider.of(context);
    final userId = appState.currentUser?.id;
    if (imageFile == null ||
        selectedModel == null ||
        selectedPatient == null ||
        userId == null) {
      return;
    }
    setState(() {
      loading = true;
      error = null;
      boxes = [];
      resultImageUrl = null;
    });
    try {
      final req = http.MultipartRequest(
          'POST', Uri.parse('$serviceUrl${ApiEndpoints.detect}'));
      req.fields['model_name'] = selectedModel!;
      req.fields['patient_id'] = selectedPatient!['id'];
      req.fields['user_id'] = appState.currentUser?.id ?? '';
      req.files
          .add(await http.MultipartFile.fromPath('image', imageFile!.path));
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          boxes = List<Map<String, dynamic>>.from(data['boxes'] ?? []);
          resultImageUrl = data['image_url'] != null
              ? '$serviceUrl${data['image_url']}'
              : null;
        });
      } else {
        setState(() {
          error = json.decode(res.body)['error'] ?? 'Detection failed';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Detection failed: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Patient Selection',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedPatient,
            items: patients
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p['username']} (${p['tc_no']})'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => selectedPatient = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Text('Model Selection',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedModel,
            items: models
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => selectedModel = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Text('Select Image', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LargeActionButton(
                icon: const Icon(Icons.photo),
                label: 'Gallery',
                onPressed: () => pickImage(ImageSource.gallery),
              ),
              const SizedBox(width: 16),
              LargeActionButton(
                icon: const Icon(Icons.camera_alt),
                label: 'Camera',
                onPressed: () => pickImage(ImageSource.camera),
              ),
            ],
          ),
          if (imageFile != null) ...[
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: InteractiveViewer(
                        child: Image.file(imageFile!, fit: BoxFit.contain),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(imageFile!, height: 180),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Custom Detect button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: LargeActionButton(
                  icon: const Icon(Icons.search),
                  label: 'Detect',
                  onPressed:
                      (!loading && imageFile != null && selectedModel != null)
                          ? detect
                          : () {},
                  enabled:
                      !loading && imageFile != null && selectedModel != null,
                ),
              ),
            ],
          ),
          if (loading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          if (resultImageUrl != null) ...[
            const SizedBox(height: 24),
            Text('Annotated Image:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: InteractiveViewer(
                        child:
                            Image.network(resultImageUrl!, fit: BoxFit.contain),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(resultImageUrl!,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Text('Image not available')),
                ),
              ),
            ),
          ],
          if (boxes.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Detections:', style: Theme.of(context).textTheme.titleMedium),
            ...boxes.asMap().entries.map((entry) {
              final b = entry.value;
              final isAnormal = b['class'] == 0;
              final classLabel = b['class'] == 0 ? 'Anormal' : 'Normal';
              final color = isAnormal ? Colors.red : Colors.green;
              return Card(
                color: color.withOpacity(0.07),
                child: ListTile(
                  leading: isAnormal
                      ? const Text('!',
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.red,
                              fontWeight: FontWeight.bold))
                      : Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text(
                    'Class: $classLabel',
                    style: TextStyle(
                      color: color,
                      fontWeight:
                          isAnormal ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'Confidence: ${(b['confidence'] * 100).toStringAsFixed(1)}%',
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
