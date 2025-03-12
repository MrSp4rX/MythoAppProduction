import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytho_novel/dashboard.dart';
import 'package:mytho_novel/mongo_service.dart';
import 'dart:math';
import 'helper.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email, password, username;

  const OTPVerificationScreen({
    required this.email,
    required this.password,
    required this.username,
    Key? key,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false, _isVerifying = false;
  String? _serverOtp;
  final _mongoService = MongoService();

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  String _generateOtp() => (100000 + Random().nextInt(900000)).toString();

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);

    final generatedOtp = _generateOtp();
    try {
      final result = await _mongoService.otpCollection.insertOne({
        'email': widget.email,
        'otp': generatedOtp,
        'expires_at':
            DateTime.now().add(Duration(minutes: 5)).toIso8601String(),
      });

      if (result.isSuccess) {
        print("Generated OTP: $generatedOtp");
        setState(() => _serverOtp = generatedOtp);
        ToastService.showToast(context, "OTP sent successfully!");
      } else {
        ToastService.showToast(context, "Failed to send OTP. Try again.");
      }
    } catch (e) {
      ToastService.showToast(context, "Error: Unable to send OTP.");
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ToastService.showToast(context, "Please enter the OTP.");
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(Duration(seconds: 2));

    if (_otpController.text == _serverOtp) {
      _login();
    } else {
      ToastService.showToast(context, "Invalid OTP! Please try again.");
    }

    setState(() => _isVerifying = false);
  }

  Future<void> _login() async {
    try {
      final response =
          await _mongoService.login(widget.username, widget.password);
      if (response != null && response['access_token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['access_token']);
        await prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => DashboardScreen()));
      } else {
        ToastService.showToast(context, "Login failed. Invalid credentials.");
      }
    } catch (e) {
      ToastService.showToast(context, "Login error. Try again.");
      print("Login Error: $e");
    }
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
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
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
              onPressed: _isLoading ? null : _sendOtp,
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
