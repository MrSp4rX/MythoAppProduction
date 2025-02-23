import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mytho_app/dashboard.dart';
import 'package:mytho_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "assets/.env");
    print("\n\n\n\n");
    print("DotEnv Loaded Successfully");
    print("\n\n\n\n");
  } catch (e) {
    print("\n\n\n\n");
    print("Error loading assets/.env file: $e");
    print("\n\n\n\n");
  }
  await dotenv.load(fileName: "assets/.env");
  bool isLoggedIn = await checkLoginStatus();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  if (token == null) {
    return false;
  }

  try {
    final secretKey = dotenv.env['SECRET_KEY'] ?? 'default-secret-key';
    JWT.verify(token, SecretKey(secretKey));
    return true;
  } catch (e) {
    await prefs.remove('auth_token');
    await prefs.setBool('isLoggedIn', false);
    return false;
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mytho App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: isLoggedIn ? DashboardScreen() : LoginScreen(),
    );
  }
}
