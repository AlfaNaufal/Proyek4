import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _step = 1;
  String pict = 'lib/assets/ichigo.jpg';
  List<String> text = [
    "Selamat datang di Counter!!!",
    "Counter siap menghitung!!",
    "Anda bisa menambah dan mengurangi angka!!",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Aplikasi Counter", style: TextStyle(fontSize: 20)),
            SizedBox(
              width: MediaQuery.widthOf(context) / 2,
              child: Image.asset(pict, fit: BoxFit.contain),
            ),
            Text('${text[_step - 1]}', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () {
                if (_step < 3) {
                  if (_step == 1) {
                    pict = 'lib/assets/Nigo.jpg';
                  }
                  if (_step == 2) {
                    pict = 'lib/assets/both.jpg';
                  }
                  setState(() {
                    _step++;
                  });
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginView()),
                  );
                }
              },
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}

