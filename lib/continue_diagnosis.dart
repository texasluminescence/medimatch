// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colors.dart';
// ignore: unused_import
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DiagnosisPage extends StatefulWidget {
  final List<String> symptoms;
  const DiagnosisPage({super.key, required this.symptoms});

  @override
  DiagnosisPageState createState() => DiagnosisPageState();
}

class DiagnosisPageState extends State<DiagnosisPage> {
  String diagnosis = "Loading...";
  String votes = "";

  @override
  void initState() {
    super.initState();
    getDiagnosis();
  }

  Future<void> getDiagnosis() async {
    final url = Uri.parse("http://<your-lan-ip>/predict"); // TODO: use your LAN IP
    final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "symptoms": widget.symptoms.join(','),
    }),
  );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
        setState(() {
          diagnosis = result['final_prediction'] ?? 'Unknown';
          votes = result['votes'] ?? '';
        });
    } else {
      setState(() {
        diagnosis = "Failed to get diagnosis";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis"),
        backgroundColor: AppColors.mintColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            const Text(
              "Here are your test results:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "$votes models predict: $diagnosis",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              "Your selected symptoms:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: widget.symptoms.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.check),
                  title: Text(widget.symptoms[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}