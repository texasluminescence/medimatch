import 'package:flutter/material.dart';
import 'colors.dart';

class SymptomDetailsPage extends StatefulWidget {
  final List<String> symptoms;

  const SymptomDetailsPage({Key? key, required this.symptoms}) : super(key: key);

  @override
  _SymptomDetailsPageState createState() => _SymptomDetailsPageState();
}

class _SymptomDetailsPageState extends State<SymptomDetailsPage> {
  final Map<String, int> _daysMap = {};
  final Map<String, int> _severityMap = {};
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _diagnosisKey = GlobalKey(); 
  bool _showDiagnosis = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _getDiagnosis() {
    setState(() {
      _showDiagnosis = true; 
    });

    // Ensure UI updates first, then scroll smoothly
    Future.delayed(const Duration(milliseconds: 300), () {
      Scrollable.ensureVisible(
        _diagnosisKey.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.1, // Ensures "Here are your test results" is at the top
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Describe Your Symptoms"),
        backgroundColor: AppColors.mintColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                // Doctor Picture
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      image: const DecorationImage(
                        image: AssetImage("lib/assets/doctor.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Symptoms input containers
                for (String symptom in widget.symptoms) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How long have you had $symptom?",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _daysMap[symptom],
                          items: List.generate(30, (index) => index + 1)
                              .map((days) => DropdownMenuItem(
                                    value: days,
                                    child: Text("$days day${days > 1 ? 's' : ''}"),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              if (value != null) _daysMap[symptom] = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Select 1-30",
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "How severe is your $symptom?",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _severityMap[symptom],
                          items: List.generate(10, (index) => index + 1)
                              .map((severity) => DropdownMenuItem(
                                    value: severity,
                                    child: Text("$severity"),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _severityMap[symptom] = value;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Select 1-10",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Get Diagnosis button
                Center(
                  child: ElevatedButton(
                    onPressed: _getDiagnosis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mintColor,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Get Diagnosis",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Diagnosis details section
                if (_showDiagnosis) ...[
                  const Divider(thickness: 2),
                  const SizedBox(height: 20),

                  // Doctor's response section
                  Container(
                    key: _diagnosisKey, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              image: const DecorationImage(
                                image: AssetImage("lib/assets/doctor.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Here are your test results:",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                       const SizedBox(height: 16),
                        const Text(
                          "Based on your test results, you have a cold.",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Here are your symptom details:",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Diagnosis Details
                  for (String symptom in widget.symptoms)
                    _buildDiagnosisCard(symptom),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(String symptom) {
    final days = _daysMap[symptom] ?? 0;
    final severity = _severityMap[symptom] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              symptom,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Days Experienced: $days", style: const TextStyle(fontSize: 16)),
            Text("Severity Level: $severity", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}