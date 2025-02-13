import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytho_app/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  OTPVerificationScreen({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _serverOtp;
  bool _isLoading = false;
  bool _isVerifying = false; // New state for verification loading

  Future<void> sendOtp() async {
    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('https://mythoapp.netflixcity.shop/send-otp'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": widget.email}),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['otp'] != null) {
        setState(() {
          _serverOtp = data['otp'].toString();
        });
        _showToast("OTP sent successfully!");
      } else {
        _showToast("Failed to send OTP. Try again.");
      }
    } else {
      _showToast("Error: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('https://mythoapp.netflixcity.shop/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"username": widget.username, "password": widget.password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String? token = responseData["access_token"];
        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setBool('isLoggedIn', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else {
          _showToast("Error: SignUp successful but can't log in!");
        }
      } else {
        _showToast("Login failed. Invalid credentials.");
      }
    } catch (e) {
      _showToast("Login failed. Check your connection.");
      print("Error: $e");
    }
  }

  void _verifyOTP() async {
    setState(() => _isVerifying = true); // Start loading

    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    if (_otpController.text == _serverOtp) {
      _login();
    } else {
      _showToast("Invalid OTP! Please try again.");
    }

    setState(() => _isVerifying = false); // Stop loading
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("OTP Verification", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fixed: Email visibility issue
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    "Enter the OTP sent to:",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  SelectableText(
                    widget.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter OTP",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Verify OTP Button with Loading Effect
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: _isVerifying
                  ? CircularProgressIndicator(
                      color: Colors.white) // Loading Spinner
                  : Text("Verify OTP", style: TextStyle(fontSize: 16)),
            ),

            SizedBox(height: 10),
            TextButton(
              onPressed: _isLoading ? null : sendOtp,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Resend OTP", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
