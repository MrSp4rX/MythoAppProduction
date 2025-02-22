import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytho_app/dashboard.dart';
import 'package:mytho_app/mongo_service.dart';
import 'dart:math';

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
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _serverOtp;
  final MongoService _mongoService = MongoService();

  String _generateOtp() {
    final Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> sendOtp() async {
    setState(() => _isLoading = true);
    String generatedOtp = _generateOtp();

    try {
      var result = await _mongoService.otpCollection.insertOne({
        'email': widget.email,
        'otp': generatedOtp,
        'expires_at':
            DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
      });

      if (result.isSuccess) {
        print("Generated OTP: $generatedOtp");

        // TODO: Send OTP via Email/SMS (integrate service here)

        setState(() {
          _serverOtp = generatedOtp;
        });
        _showToast("OTP sent successfully!");
      } else {
        _showToast("Failed to generate OTP. Try again.");
      }
    } catch (e) {
      print("Error sending OTP: $e");
      _showToast("Error: Unable to send OTP.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  Future<void> _login() async {
    final response =
        await _mongoService.login(widget.username, widget.password);
    if (response != null && response['access_token'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['access_token']);
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      _showToast("Login failed. Invalid credentials.");
    }
  }

  void _verifyOTP() async {
    setState(() => _isVerifying = true);
    await Future.delayed(Duration(seconds: 2));
    if (_otpController.text == _serverOtp) {
      _login();
    } else {
      _showToast("Invalid OTP! Please try again.");
    }
    setState(() => _isVerifying = false);
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
      backgroundColor: Colors.black,
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
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: _isVerifying
                  ? CircularProgressIndicator(color: Colors.white)
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
