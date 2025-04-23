import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stories_for_kids/screens/onboarding_screen.dart';
import 'package:stories_for_kids/screens/bottomnav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
     with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    checkOnboardingScreen();   
  }

  void checkOnboardingScreen() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    bool isFirstTime=prefs.getBool('first_time') ?? true;
    await Future.delayed(const Duration(seconds: 2));

     if (!mounted) return;
     if (isFirstTime) {
      prefs.setBool('first_time', false);
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const OnboardingScreen()));
    } else {
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const BottomNavigationPage()));
   }
  }
    
 @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double textSize =
        screenWidth > 600 ? 120 : 98; 
    double padding =
        screenWidth > 600 ? 50 : 30; 

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensures full screen usage
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(248, 57, 165, 1), Colors.deepOrangeAccent],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: padding), // Responsive padding
              child: Text(
                'English \n Stories',
                textAlign: TextAlign.center, // Centering text
                style: GoogleFonts.tangerine(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: textSize, // Responsive text size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
                height:
                    screenHeight * 0.05), // Vertical spacing for larger screens
            // Any other widgets can be added below with responsive adjustments
          ],
        ),
      ),
    );
  }
}
