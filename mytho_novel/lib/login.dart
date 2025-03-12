import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'signup.dart';
import 'mongo_service.dart';
import 'helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late SharedPreferences _prefs;
  final MongoService _mongoService = MongoService();

  // Google Sign-In instance with correct client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        "270709673571-f4f0eiifp4kujje94qbmj6uksut5bs9d.apps.googleusercontent.com",
  );

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _initializeFirebase();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ToastService.showToast(context, "Please fill all the fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _mongoService.login(email, password);
      if (response != null && response.containsKey('access_token')) {
        await _prefs.setString('auth_token', response['access_token']);
        await _prefs.setBool('isLoggedIn', true);
        ToastService.showToast(context, "Login Successful!");
        _navigateToDashboard();
      } else {
        ToastService.showToast(
            context, response?['error'] ?? "Invalid Credentials!");
      }
    } catch (e) {
      ToastService.showToast(context, "An error occurred. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("\n\n\n");
      print(googleUser);
      print("\n\n\n");
      if (googleUser == null) {
        ToastService.showToast(context, "Google Sign-In canceled.");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print("\n\n\n");
      print(googleAuth.accessToken);
      print(googleAuth.idToken);
      print("\n\n\n");
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print("\n\n\n");
      print(credential);
      print("\n\n\n");
      if (userCredential.user != null) {
        ToastService.showToast(context, "Google Sign-In Successful!");
        _navigateToDashboard();
      }
    } catch (e) {
      ToastService.showToast(context, "Google Sign-In failed: ${e.toString()}");
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: const Text(
            'Mytho Novel',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40.0),
                  const Text("Login",
                      style: TextStyle(
                          fontSize: 26.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12.0),
                  _buildTextField(_emailController, 'Username or Email', false),
                  const SizedBox(height: 12.0),
                  _buildTextField(_passwordController, 'Password', true),
                  const SizedBox(height: 20.0),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.blue)
                      : _buildLoginButton(),
                  const SizedBox(height: 10.0),
                  _buildGoogleSignInButton(),
                  _buildSignupRow(),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10.0)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 12.0)),
        child: const Text('Log In',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _signInWithGoogle,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0)),
        icon: const Icon(Icons.login, color: Colors.black),
        label: const Text('Sign in with Google',
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
    );
  }

  Widget _buildSignupRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: TextStyle(color: Colors.white)),
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignupScreen())),
          child: const Text('Sign up here',
              style: TextStyle(color: Colors.blue, fontSize: 14.0)),
        ),
      ],
    );
  }
}
