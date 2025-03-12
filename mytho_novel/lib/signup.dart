import 'package:flutter/material.dart';
import 'package:mytho_novel/mongo_service.dart';
import 'otp_verification.dart';
import 'helper.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  final MongoService _mongoService = MongoService();

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ToastService.showToast(context, "Please fill all the fields!");
      return;
    }

    if (password != confirmPassword) {
      ToastService.showToast(context, "Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response =
          await _mongoService.signup(name, email, password, phoneNumber);
      if (response != null &&
          response['message'] == 'User registered successfully') {
        ToastService.showToast(context, "Sign Up Successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                  email: email, password: password, username: name)),
        );
      } else {
        ToastService.showToast(
            context, response?['error'] ?? "Signup failed. Please try again.");
      }
    } catch (e) {
      ToastService.showToast(context, "Error: Something went wrong.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: const Text(
          'Mytho Novel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30.0),
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20.0),
            _buildTextField(_nameController, "Username", TextInputType.text,
                false, TextInputAction.next),
            const SizedBox(height: 12.0),
            _buildTextField(_emailController, "Email ID",
                TextInputType.emailAddress, false, TextInputAction.next),
            const SizedBox(height: 12.0),
            _buildTextField(_phoneNumberController, "Phone Number",
                TextInputType.phone, false, TextInputAction.next),
            const SizedBox(height: 12.0),
            _buildTextField(_passwordController, "Password",
                TextInputType.visiblePassword, true, TextInputAction.next),
            const SizedBox(height: 12.0),
            _buildTextField(_confirmPasswordController, "Confirm Password",
                TextInputType.visiblePassword, true, TextInputAction.done),
            const SizedBox(height: 20.0),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.blue)
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? ",
                    style: TextStyle(color: Colors.white)),
                TextButton(
                  onPressed: !_isLoading ? () => Navigator.pop(context) : null,
                  child: const Text(
                    'Login here',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType type, bool obscure, TextInputAction action) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      textInputAction: action,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}
