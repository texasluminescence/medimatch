import 'package:flutter/material.dart';
import 'colors.dart';

class DiagnosisPage extends StatelessWidget {
  final List<String> symptoms;

  const DiagnosisPage({Key? key, required this.symptoms}) : super(key: key);

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
            // Doctor picture
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
            const Text(
              "Based on your test results, you have a cold.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              "Your selected symptoms:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: symptoms.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.check),
                  title: Text(symptoms[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}