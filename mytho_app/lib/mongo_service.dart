import 'package:mongo_dart/mongo_dart.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  late Db db;
  late DbCollection usersCollection;
  late DbCollection otpCollection;
  late DbCollection booksCollection;
  late DbCollection chaptersCollection;
  late DbCollection reviewsCollection;
  late String secretKey;
  bool _isDbInitialized = false;

  factory MongoService() => _instance;
  MongoService._internal();

  Future<void> connectToDatabase() async {
    if (_isDbInitialized) return;

    await dotenv.load(fileName: "assets/.env");
    final mongoUri = dotenv.env['MONGO_URI'];
    secretKey = dotenv.env['SECRET_KEY'] ?? 'your-secret-key';

    if (mongoUri == null || mongoUri.isEmpty) {
      print("❌ ERROR: MONGO_URI is missing in .env file!");
      return;
    }

    try {
      db = await Db.create(mongoUri);
      await db.open();

      usersCollection = db.collection('users');
      otpCollection = db.collection('otp');
      booksCollection = db.collection('novels');
      chaptersCollection = db.collection('chapters');
      reviewsCollection = db.collection('reviews');

      _isDbInitialized = true;
      print("✅ Connected to MongoDB successfully!");
    } catch (e) {
      print("❌ MongoDB Connection Error: $e");
      _isDbInitialized = false;
    }
  }

  Future<void> ensureDbConnection() async {
    if (!_isDbInitialized) {
      print("🔄 Attempting to reconnect to MongoDB...");
      await connectToDatabase();
    } else if (db.state != State.open) {
      print("🔄 Reopening MongoDB connection...");
      await db.open();
    }
  }

  String generateToken(String userId) {
    final jwt = JWT({
      'sub': userId,
      'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch
    });
    return jwt.sign(SecretKey(secretKey));
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    await ensureDbConnection();
    final users = await usersCollection.find().toList();
    return users
        .map((user) => {
              "id": user['_id'].toString(),
              "username": user['username'],
              "email": user['email'],
              "phone_number": user['phone_number'],
              "isVerified": user['isVerified'],
              "created_at": user['created_at'],
            })
        .toList();
  }

  Future<Map<String, dynamic>?> signup(String username, String email,
      String password, String phoneNumber) async {
    await ensureDbConnection();
    final existingUser = await usersCollection.findOne({'username': username});

    if (existingUser != null) {
      return {'error': 'Username already taken'};
    }

    final newUser = {
      'username': username,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'isVerified': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    await usersCollection.insertOne(newUser);
    return {'message': 'User registered successfully'};
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    await ensureDbConnection();
    final user = await usersCollection.findOne(where.eq('username', username));

    if (user == null || password != user['password']) {
      return {'error': 'Invalid credentials'};
    }

    final token = generateToken(user['_id'].toString());
    return {'access_token': token, 'token_type': 'bearer'};
  }

  Future<void> sendOtp(String email) async {
    await ensureDbConnection();
    String generatedOtp = _generateOtp();
    await otpCollection.insertOne({
      'email': email,
      'otp': generatedOtp,
      'expires_at': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    await ensureDbConnection();
    final books = await booksCollection.find().toList();
    return books
        .map((book) => {
              '_id': book['_id'].toString(),
              'title': book['title'],
              'author': book['author'],
              'description': book['description'],
              'genres': book['genres'],
              'cover_image': book['cover_image'],
              'total_chapters': book['total_chapters'],
              'status': book['status'],
              'views': book['views'],
              'ratings': book['ratings'],
              'created_at': book['created_at']
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getChapters(String novelId) async {
    await ensureDbConnection();
    try {
      final chapters = await chaptersCollection
          .find(where.eq('novel_id', ObjectId.parse(novelId)))
          .toList();
      return chapters
          .map((chapter) => {
                '_id': chapter['_id'].toString(),
                'novel_id': chapter['novel_id'].toString(),
                'chapter_number': chapter['chapter_number'],
                'title': chapter['title'],
                'content': chapter['content'],
                'word_count': chapter['word_count'],
                'published_at': chapter['published_at']
              })
          .toList();
    } catch (e) {
      print("❌ Error fetching chapters: $e");
      return [];
    }
  }

  Future<void> addReview(
      String novelId, String userId, String reviewText, double rating) async {
    try {
      await reviewsCollection.insertOne({
        "novel_id": novelId,
        "user_id": userId,
        "rating": rating,
        "review_text": reviewText,
        "created_at": DateTime.now().toIso8601String(),
      });
      print("✅ Review added successfully!");
    } catch (e) {
      print("❌ Error adding review: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getReviewsByNovelId(String novelId) async {
    try {
      final reviews =
          await reviewsCollection.find({"novel_id": novelId}).toList();

      return reviews
          .map((review) => {
                "_id": review["_id"].toString(),
                "user_id": review["user_id"] ?? "",
                "novel_id": review["novel_id"] ?? "",
                "rating": review["rating"] ?? "0.0",
                "review_text": review["review_text"] ?? "",
                "created_at": review["created_at"] ?? "",
              })
          .toList();
    } catch (e) {
      print("❌ Error fetching reviews: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getChaptersByNovelId(
      String novelId) async {
    try {
      novelId = novelId.substring(10, novelId.length - 2);
      print(novelId);
      ObjectId objectId = ObjectId.parse(novelId);
      print(objectId);
      return await db
          .collection('chapters')
          .find({'novel_id': objectId}).toList();
    } catch (e) {
      print("❌ Error fetching chapters: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getChapterById(String chapterId) async {
    await ensureDbConnection();

    try {
      chapterId = chapterId.substring(10, chapterId.length - 2);
      ObjectId objectId = ObjectId.parse(chapterId);
      var chapter =
          await db.collection('chapters').findOne({'novel_id': objectId});
      var documents = await db.collection('chapters').find().toList();

      print(documents);
      print(chapter);

      if (chapter == null) {
        print("❌ Error: Chapter not found in MongoDB!");
        return null;
      }

      return {
        'id': chapter['_id'],
        'chapter_number': chapter['chapter_number'],
        'title': chapter['title'],
        'content': chapter['content'],
        'word_count': chapter['word_count'],
      };
    } catch (e) {
      print("❌ Error fetching chapter by ID: $e");
      return null;
    }
  }

  String _generateOtp() {
    final Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
