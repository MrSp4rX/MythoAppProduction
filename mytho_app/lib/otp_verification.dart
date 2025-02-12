import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytho_app/test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  OTPVerificationScreen(
      {required this.email, required this.password, required this.username});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _serverOtp; // Stores OTP received from the server
  bool _isLoading = false;

  // ✅ Function to send OTP request to the backend
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
          _serverOtp = data['otp'].toString(); // Store OTP for verification
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP sent successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send OTP. Try again.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.statusCode}")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    sendOtp(); // Auto-send OTP when screen loads
  }

  // ✅ Function to login after OTP verification
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
            MaterialPageRoute(builder: (context) => TestScreen()),
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

  // ✅ Function to verify OTP
  void _verifyOTP() async {
    if (_otpController.text == _serverOtp) {
      _login(); // ✅ Call _login() after OTP verification
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP! Please try again.")),
      );
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OTP Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter the OTP sent to ${widget.email}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text("Verify OTP"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _isLoading ? null : sendOtp, // ✅ Enable Resend OTP
              child:
                  _isLoading ? CircularProgressIndicator() : Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
