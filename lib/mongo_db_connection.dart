import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
    print("$data");

    await db.close();
  } catch (e) {
    print("Error connecting to MongoDB: $e");
  }
}