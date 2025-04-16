// ignore_for_file: avoid_print

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

List<String> diseaseList = [];
List<String> symptomList = [];

Future<void> connectToMongo() async {
  await dotenv.load();
  print("Trying mongo connection");

  String? mongoUrl = dotenv.env['MONGO_URL'];
  String? collectionName = dotenv.env['COLLECTION_NAME'];

  if (mongoUrl == null || collectionName == null) {
    print("Missing credentials");
    return;
  }

  try {
    var db = await Db.create(mongoUrl);
    await db.open();
    print("Connected to MongoDB");

    var collection = db.collection(collectionName);
    var data = await collection.find().toList();

    // Extract and sort unique disease names
    diseaseList = data
        .map((doc) => doc['Disease'].toString().trim())
        .toSet()
        .toList()
      ..sort();

    // Extract and clean symptoms
    Set<String> symptoms = {};
    for (var doc in data) {
      for (var key in doc.keys) {
        if (key.startsWith('Symptom_') && doc[key] != null) {
          String cleaned = doc[key]
              .toString()
              .trim()
              .replaceAll('_', ' ')
              .replaceAll(RegExp(' +'), ' '); // remove double spaces
          if (cleaned.isNotEmpty) {
            symptoms.add(cleaned);
          }
        }
      }
    }

    symptomList = symptoms.toList()..sort();

    print("Diseases found: ${diseaseList.length}");
    print("Symptoms found: ${symptomList.length}");

    await db.close();
  } catch (e) {
    print("Error connecting to MongoDB: $e");
  }
}