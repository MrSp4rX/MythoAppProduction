import 'package:flutter/material.dart';
import 'otp_verification.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false; // Added loading state

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final phoneNumber = _phoneNumberController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showToast("Please fill all the fields!");
      return;
    }

    if (password != confirmPassword) {
      _showToast("Passwords do not match!");
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final response = await http.post(
        Uri.parse('https://mythoapp.netflixcity.shop/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": name,
          "email": email,
          "password": password,
          "phone_number": phoneNumber,
          "isVerified": false
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String? msg = responseData["message"];

        if (msg == "User registered successfully") {
          _showToast("SignUp Successful!");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(
                    email: email, password: password, username: name)),
          );
        }
      } else {
        _showToast("Signup failed. Please try again.");
      }
    } catch (e) {
      _showToast("Error: Something went wrong.");
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text('Mytho App',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                // enabled: !_isLoading, // Disable input while loading
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                // enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Email ID',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _phoneNumberController,
                // enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                // enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                obscureText: true,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _confirmPasswordController,
                // enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                obscureText: true,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 22.5),

              // Show loading spinner instead of signup button
              _isLoading
                  ? CircularProgressIndicator(color: Colors.blue)
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('Sign Up',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold)),
                    ),

              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: !_isLoading
                        ? () {
                            Navigator.pop(context);
                          }
                        : null,
                    child: Text(
                      'Login here',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
