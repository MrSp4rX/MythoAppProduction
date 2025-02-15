import 'package:flutter/material.dart';
import 'package:mytho_app/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Added loading state

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showToast("Please fill all the fields");
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://f059-2409-40e3-18f-61b6-352e-4ed5-570f-6846.ngrok-free.app/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String? token = responseData["access_token"];

        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setBool('isLoggedIn', true);

          _showToast("Login Successful!");

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => DashboardScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          _showToast("Error: Token is null");
        }
      } else {
        _showToast("Invalid Credentials!");
      }
    } catch (e) {
      _showToast("Login failed. Check your connection.");
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          title: Text(
            'Mytho App',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: _emailController,
                  // enabled: !_isLoading,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username or Email ID',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _passwordController,
                  // enabled: !_isLoading,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 15.0),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.blue)
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('Log In',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold)),
                      ),
                TextButton(
                  onPressed: !_isLoading
                      ? () {
                          _showToast(
                              "Forgot Password functionality not implemented yet.");
                        }
                      : null,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: TextStyle(color: Colors.white)),
                    TextButton(
                      onPressed: !_isLoading
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupScreen()),
                              );
                            }
                          : null,
                      child: Text(
                        'Sign up here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
