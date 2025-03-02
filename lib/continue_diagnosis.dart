import 'package:flutter/material.dart';
import 'colors.dart'; // Ensure this file contains your mint color constant

class SymptomDetailsPage extends StatefulWidget {
  final List<String> symptoms;

  const SymptomDetailsPage({
    Key? key,
    required this.symptoms,
  }) : super(key: key);

  @override
  _SymptomDetailsPageState createState() => _SymptomDetailsPageState();
}

class _SymptomDetailsPageState extends State<SymptomDetailsPage> {
  // store the user's days and severity of each symptom
  // key: Symptom name, Value: days/severity chosen.
  final Map<String, int> _daysMap = {};
  final Map<String, int> _severityMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Describe Your Symptoms"),
        backgroundColor: AppColors.mintColor,
      ),
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // System "containers"
            for (String symptom in widget.symptoms) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 24), // space between containers
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // white background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "How long have you had a $symptom?",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      // days dropdown config
                      isExpanded: false,
                      value: _daysMap[symptom],
                      items: List.generate(30, (index) => index + 1)
                          .map((days) => DropdownMenuItem(
                                value: days,
                                child: Text("$days day${days > 1 ? 's' : ''}"),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            _daysMap[symptom] = value;
                          }
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
                      // severity dropdown config
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

            // get diagnosis  button
            Center(
              child: ElevatedButton(
                onPressed: _getDiagnosis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
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
          ],
        ),
      ),
    );
  }

  void _getDiagnosis() {
    //TODO:
    for (String symptom in widget.symptoms) {
      final days = _daysMap[symptom];
      final severity = _severityMap[symptom];
      print("Symptom: $symptom, Days: $days, Severity: $severity");
    }
  }
}
