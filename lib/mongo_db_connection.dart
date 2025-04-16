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
Future<void> updateUserProfile({
  required String email,
  DateTime? dob,
  required int feet,
  required int inches,
  required int? weight,
  required List<String> conditions,
}) async {
  await dotenv.load();

  String? mongoUrl = dotenv.env['MONGO_URL'];
  if (mongoUrl == null) {
    print("Missing MongoDB URL");
    return;
  }

  var db = await Db.create(mongoUrl);
  await db.open();
  var collection = db.collection('users');

  try {
    final updateResult = await collection.updateOne(
      where.eq('email', email),
      modify.set('dob', dob?.toIso8601String())
            .set('feet', feet)
            .set('inches', inches)
            .set('weight', weight)
            .set('conditions', conditions),
    );

    if (updateResult.isSuccess) {
      print("User profile updated successfully");
    } else {
      print("Failed to update profile");
    }
  } catch (e) {
    print("MongoDB update error: $e");
  } finally {
    await db.close();
  }
}

Future<Map<String, dynamic>?> getUserProfile(String email) async {
  await dotenv.load();

  String? mongoUrl = dotenv.env['MONGO_URL'];
  if (mongoUrl == null) {
    print("Missing MongoDB URL");
    return null;
  }

  var db = await Db.create(mongoUrl);
  await db.open();
  var collection = db.collection('users');

  try {
    var userDoc = await collection.findOne(where.eq('email', email));
    return userDoc;
  } catch (e) {
    print("MongoDB fetch error: $e");
    return null;
  } finally {
    await db.close();
  }
}
