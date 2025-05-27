import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../state/app_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String serviceUrl = 'http://localhost:5000'; // Change if needed
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
      final res = await http.get(Uri.parse('$serviceUrl/models'));
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
      final res = await http.get(Uri.parse('http://localhost:8080/patients'));
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
        userId == null) return;
    setState(() {
      loading = true;
      error = null;
      boxes = [];
      resultImageUrl = null;
    });
    try {
      final req =
          http.MultipartRequest('POST', Uri.parse('$serviceUrl/detect'));
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
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Gallery'),
                onPressed: () => pickImage(ImageSource.gallery),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: () => pickImage(ImageSource.camera),
              ),
            ],
          ),
          if (imageFile != null) ...[
            const SizedBox(height: 12),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(imageFile!, height: 180),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Detect'),
            onPressed: (!loading && imageFile != null && selectedModel != null)
                ? detect
                : null,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
          ),
          if (loading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          if (boxes.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Detections:', style: Theme.of(context).textTheme.titleMedium),
            ...boxes.map((b) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.crop_square),
                    title: Text(
                        'Class: ${b['class']}  Confidence: ${(b['confidence'] * 100).toStringAsFixed(1)}%'),
                    subtitle: Text(
                        'x: ${b['x_center']}, y: ${b['y_center']}, w: ${b['width']}, h: ${b['height']}'),
                  ),
                )),
          ],
          if (resultImageUrl != null) ...[
            const SizedBox(height: 24),
            Text('Annotated Image:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(resultImageUrl!,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) =>
                        const Text('Image not available')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
