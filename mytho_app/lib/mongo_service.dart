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

      _isDbInitialized = true;
      print("✅ Connected to MongoDB successfully!");
    } catch (e) {
      print("❌ MongoDB Connection Error: $e");
      _isDbInitialized = false;
    }
  }

  String generateToken(String userId) {
    final jwt = JWT({
      'sub': userId,
      'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch
    });
    return jwt.sign(SecretKey(secretKey));
  }

  /// Fetches all users from the database
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    await ensureDbConnection();

    final users = await usersCollection.find().toList();
    print("📌 Found ${users.length} users in DB.");

    return users.map((user) {
      return {
        "id": user['_id'].toString(),
        "username": user['username'],
        "email": user['email'],
        "phone_number": user['phone_number'],
        "isVerified": user['isVerified'],
        "created_at": user['created_at'],
      };
    }).toList();
  }

  /// Registers a new user
  Future<Map<String, dynamic>?> signup(String username, String email,
      String password, String phoneNumber) async {
    await ensureDbConnection();

    final existingUser = await usersCollection.findOne({'username': username});

    if (existingUser != null) {
      print("❌ Signup failed: Username already taken.");
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
    print("✅ User registered successfully: $username");

    return {'message': 'User registered successfully'};
  }

  /// Handles user login
  Future<Map<String, dynamic>?> login(String username, String password) async {
    await ensureDbConnection();

    print("📌 Searching for user: $username");
    final user = await usersCollection.findOne(where.eq('username', username));

    if (user == null) {
      print("❌ Login failed: User not found in DB.");
      return {'error': 'Invalid credentials'};
    }

    print("✅ User found: $user");

    if (password != user['password']) {
      print("❌ Login failed: Incorrect password.");
      return {'error': 'Invalid credentials'};
    }

    final token = generateToken(user['_id'].toString());
    print("✅ Login successful! Token generated.");

    return {'access_token': token, 'token_type': 'bearer'};
  }

  /// Sends OTP and stores it in MongoDB
  Future<void> sendOtp(String email) async {
    await ensureDbConnection();

    String generatedOtp = _generateOtp();
    await otpCollection.insertOne({
      'email': email,
      'otp': generatedOtp,
      'expires_at': DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
    });

    print("\n\nOTP Sent: $generatedOtp\n\n");
  }

  /// Fetches all books from the database
  Future<List<Map<String, dynamic>>> getBooks() async {
    await ensureDbConnection();

    final books = await booksCollection.find().toList();
    print("📚 Found ${books.length} books in DB.");

    return books
        .map((book) => {
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

  /// Ensures the database is connected before executing queries
  Future<void> ensureDbConnection() async {
    if (!_isDbInitialized) {
      print("🔄 Attempting to reconnect to MongoDB...");
      await connectToDatabase();
    } else if (db.state != State.open) {
      print("🔄 Reopening MongoDB connection...");
      await db.open();
    }
  }

  /// Generates a random 6-digit OTP
  String _generateOtp() {
    final Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}
