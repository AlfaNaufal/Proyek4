import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _step = 1;

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                Container(
                  width: MediaQuery.widthOf(context),
                  height: MediaQuery.heightOf(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/ichigo.png',
                        width: MediaQuery.widthOf(context)/2,
                      ),
                      Text("Selamat Datang!", style: TextStyle(fontSize: 20)),
                      ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: Text("Next"),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsGeometry.only(bottom: 20),
                        child: Image.asset(
                          'lib/assets/Nigo.png',
                          width: MediaQuery.widthOf(context)/2,
                        ),
                      ),
                      Text('Satu langkah kecil hari ini\nadalah lompatan besar besok.\nAyo mulai!', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Text("Prev"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                            child: Text("Next"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/both.png',
                        width: MediaQuery.widthOf(context)/2,
                      ),
                      Text('Kesalahan adalah bukti\nbahwa Anda sedang mencoba.\nJangan takut salah!', 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Text("Prev"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginView(),
                                ),
                              );
                            },
                            child: Text("Next"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController, 
            count: 3,
            effect: JumpingDotEffect(),),
          SizedBox(height: 50),
        ],
      ),

      // Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text("Aplikasi Counter", style: TextStyle(fontSize: 20)),
      //       SizedBox(
      //         width: MediaQuery.widthOf(context) / 2,
      //         child: Image.asset(pict, fit: BoxFit.contain),
      //       ),
      //       Text('${text[_step - 1]}', style: TextStyle(fontSize: 16)),
      //       ElevatedButton(
      //         onPressed: () {
      //           if (_step < 3) {
      //             if (_step == 1) {
      //               pict = 'lib/assets/Nigo.png';
      //             }
      //             if (_step == 2) {
      //               pict = 'lib/assets/both.png';
      //             }
      //             setState(() {
      //               _step++;
      //             });
      //           } else {
      //             Navigator.pushReplacement(
      //               context,
      //               MaterialPageRoute(builder: (context) => LoginView()),
      //             );
      //           }
      //         },
      //         child: Text("Next"),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
