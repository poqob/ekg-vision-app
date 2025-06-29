import 'dart:convert';
import 'package:flutter/material.dart';
import 'analysis_screen.dart';

class ScanDetailScreen extends StatelessWidget {
  final Scan scan;
  final String? patientName;
  const ScanDetailScreen({super.key, required this.scan, this.patientName});

  @override
  Widget build(BuildContext context) {
    // Assume scan.date is always DateTime
    final d = scan.date;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String formattedDate =
        '${twoDigits(d.day)}/${twoDigits(d.month)}/${d.year.toString().substring(2)}   ${twoDigits(d.hour)}:${twoDigits(d.minute)}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Scan Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // ECG heading and image
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'ECG',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
              ),
            ),
            if (scan.image.isNotEmpty)
              Center(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: InteractiveViewer(
                          child: Image.memory(
                            base64Decode(scan.image),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Image.memory(
                    base64Decode(scan.image),
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Patient heading
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'Patient',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
            // Modernized Patient/Model/Date section with clickable functionality
            GestureDetector(
              onTap: () {
                _showPatientDetailsDialog(
                    context, patientName, scan.modelName, formattedDate);
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blueAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Patient',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              patientName != null
                                  ? _splitName(patientName!)
                                  : 'Unknown',
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.memory, color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Model',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              scan.modelName,
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Date',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              formattedDate,
                              style: Theme.of(context).textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Info hint
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap for details',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Detection Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
              ),
            ),
            _buildNormalAnormalCounts(scan.boxes),
            const SizedBox(height: 16),
            // Result heading and annotated image
            if (scan.resultImage.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Result',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: InteractiveViewer(
                              child: Image.memory(
                                base64Decode(scan.resultImage),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.memory(
                        base64Decode(scan.resultImage),
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            // List boxes and confidence scores
            if (scan.boxes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Detected Boxes',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scan.boxes.length,
                    separatorBuilder: (context, idx) =>
                        const Divider(height: 8),
                    itemBuilder: (context, i) {
                      final box = scan.boxes[i];
                      final isAnormal = (box is Map && box.containsKey('class'))
                          ? box['class'] == 0
                          : false;
                      final classLabel =
                          (box is Map && box.containsKey('class'))
                              ? (isAnormal ? 'Anormal' : 'Normal')
                              : 'Unknown';
                      final confidence =
                          (box is Map && box.containsKey('confidence'))
                              ? box['confidence'].toString()
                              : 'N/A';
                      return ListTile(
                        leading: isAnormal
                            ? const Text('!',
                                style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold))
                            : Icon(Icons.check_circle_outline,
                                color: Colors.green),
                        title: Text(
                          'Box #${i + 1}: $classLabel',
                          style: isAnormal
                              ? const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)
                              : const TextStyle(color: Colors.green),
                        ),
                        subtitle: Text('Confidence: $confidence'),
                        tileColor: isAnormal
                            ? Colors.red.withOpacity(0.05)
                            : Colors.green.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Show dialog with full patient, model, and date information
  void _showPatientDetailsDialog(BuildContext context, String? patientName,
      String modelName, String formattedDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient details
              Text(
                'Patient',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                patientName != null ? patientName : 'Unknown',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Model details
              Text(
                'Model',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                modelName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Date details
              Text(
                'Date',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                formattedDate,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _splitName(String name) {
    if (name.isEmpty) return name;
    int upperCount = 0;
    for (int i = 0; i < name.length; i++) {
      if (name[i].toUpperCase() == name[i] &&
          name[i].toLowerCase() != name[i]) {
        upperCount++;
        if (upperCount == 2) {
          return '${name.substring(0, i)} ${name.substring(i)}';
        }
      }
    }
    return name;
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

    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      final anormalColor = isDark ? Colors.red.shade300 : Colors.red;
      final normalColor = isDark ? Colors.green.shade300 : Colors.green;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Normal count with icon
              Column(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Normal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$normal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: normalColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Divider
              Container(
                height: 60,
                width: 1,
                color: theme.dividerColor,
              ),

              // Anormal count with icon
              Column(
                children: [
                  Text('!',
                      style: TextStyle(
                          fontSize: 32,
                          color: anormalColor,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Anormal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$anormal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: anormalColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
