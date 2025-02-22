import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  String mongoUri =
      "mongodb+srv://sshourya948:SwatiLovesShaurya@otpbot.bfy6u.mongodb.net/mytho_app_database";

  try {
    print("🔄 Connecting to MongoDB...");
    var db = await Db.create(mongoUri);
    await db.open();

    print("✅ Connected Successfully!");

    var collections = await db.getCollectionNames();
    print("📁 Collections: $collections");

    var usersCollection = db.collection("users");

    // If users collection does not exist, insert a test user
    if (!collections.contains("users")) {
      print("⚠️ 'users' collection not found. Creating one now...");

      await usersCollection.insertOne({
        "username": "testuser",
        "email": "test@example.com",
        "password": "password123",
      });

      print("✅ Test user added!");
    }

    var users = await usersCollection.find().toList();
    print("👥 Users Found: $users");

    await db.close();
    print("🔒 Connection Closed.");
  } catch (e) {
    print("❌ Error Connecting to MongoDB: $e");
  }
}
