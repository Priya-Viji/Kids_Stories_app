import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stories_for_kids/screens/bottomnav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
  }

  final PageController _controller = PageController();
  bool isLastPage = false;
  int _currentIndex = 0;
  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/Onboarding_images/onboarding_1.jpg",
      "text": "Perfect for bedtime, car trips or sunny days!"
    },
    {
      "image": "assets/images/Onboarding_images/onboarding_2.jpg",
      "text": "Inspirational Stories for Young Hearts!"
    },
    {
      "image": "assets/images/Onboarding_images/onboarding_3.jpg",
      "text": "Discover Short & Sweet Stories for your kids"
    },
  ];

  void nextPage() {
    if (_currentIndex < pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      // Navigate to home screen
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const BottomNavigationPage()));
    }
  }

  void skip() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const BottomNavigationPage()));
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose PageController first
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double textSize =
        screenWidth > 600 ? 28 : 22; // Adjust text size based on screen width
    double imageHeight = screenHeight > 700
        ? 250
        : 200; // Adjust image height for smaller screens
    double buttonPadding = screenWidth > 600 ? 40 : 30; // Adjust button padding

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.pinkAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        _controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease);
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white),
                      child: const Text("Back"),
                    ),
                  TextButton(
                    onPressed: skip,
                    child: const Text("Skip",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        pages[index]["image"]!,
                        height: imageHeight, // Responsive image size
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          pages[index]["text"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: textSize, // Responsive text size
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.white : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: nextPage,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    horizontal: buttonPadding, // Responsive padding
                    vertical: screenHeight * 0.02, // Adjust vertical padding
                  )),
              child: Text(
                "Let's Go",
                style: TextStyle(fontSize: textSize, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
