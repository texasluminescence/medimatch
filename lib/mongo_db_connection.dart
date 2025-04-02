import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

List<String> diseaseList = [];

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

    // print("$data");
    // print all diseases
    // for (var test in data) {
    //     print(test['Disease']);
    // }
    // print('list length: ${data.length}');

    // extract diseases, only keep unique values, sort it
    diseaseList = data.map((doc) => doc['Disease'].toString().trim())
        .toSet().toList()..sort();


    await db.close();
  } catch (e) {
    print("Error connecting to MongoDB: $e");
  }
}
