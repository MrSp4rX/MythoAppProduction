import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToastHelper {
  static final FToast _fToast = FToast();

  static void showCustomToast(String message, BuildContext context) {
    _fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(221, 252, 250, 250),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15,
            color: const Color.fromARGB(255, 8, 8, 8),
          ),
        ),
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}

Future<void> saveUserSession(String userInfo, String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userInfo', userInfo);
  await prefs.setString('token', token);
  await prefs.setBool('isLoggedIn', true);
}

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token') != null;
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userInfo');
  await prefs.remove('token');
}

void login(String email, String password) async {
  try {
    Response r = await post(
      Uri.parse('https://reqres.in/api/login'),
      body: {'email': email, 'password': password},
    );
    print(r.body);
  } catch (e) {
    print(e);
  }
}
