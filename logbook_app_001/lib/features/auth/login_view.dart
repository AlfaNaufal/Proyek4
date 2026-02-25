import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/counter_view.dart';
import 'package:logbook_app_001/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _show = true;
  bool _validateUser = false;
  bool _validatePass = false;
  bool _isActive = true;
  int _count = 1;

  void _handleLogin() {
    Map<String, String> user = {
      "username": _userController.text,
      "password": _passController.text,
    };
    // Map<String, String> pass = {"password": _passController.text};

    bool isSuccess = _controller.login(user);

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogView(username: user['username']!),
          // builder: (context) => CounterView(username: user['username']!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Gagal! Pastikan username dan password benar."),
        ),
      );
      _count += 1;
      print("Percobaan login: $_count");
      if (_count > 3) {
        print("masuk");
        _count = 1;
        setState(() => _isActive = false);
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terlalu banyak percobaan! Coba lagi nanti.")),
        );
      }
    }
  }

  int _second = 10;
  bool _isRunning = false;
  Timer? _timer;

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_second > 0) {
          _second--;
        } else {
          _isRunning = false;
          _isActive = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login gateKeeper")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                labelText: "Username",
                errorText: _validateUser ? "Username tidak boleh kosong" : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: _show,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: IconButton(
                  onPressed: () => setState(() => _show = !_show),
                  icon: Icon(_show ? Icons.visibility : Icons.visibility_off),
                ),
                labelText: "Password",
                errorText: _validatePass ? "Password tidak boleh kosong" : null,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isActive
                  ? () {
                      if (_userController.text.isEmpty &&
                          _passController.text.isEmpty) {
                        setState(() => _validateUser = true);
                        setState(() => _validatePass = true);
                      } else if (_userController.text.isEmpty) {
                        setState(() => _validateUser = true);
                        setState(() => _validatePass = false);
                      } else if (_passController.text.isEmpty) {
                        setState(() => _validateUser = false);
                        setState(() => _validatePass = true);
                      } else {
                        _handleLogin();
                        setState(() => _validateUser = false);
                        setState(() => _validatePass = false);
                      }
                    }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Masuk"), Text(_isActive ? "" : "($_second)")],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
