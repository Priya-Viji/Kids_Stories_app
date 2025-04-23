import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_for_kids/providers/theme_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("About the App"),
        backgroundColor: themeProvider.themeColor,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stories for Kids is a fun app where you can read different types of stories like moral, adventure, and bedtime stories.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'You can also create your own stories! Just tap the "Add Story" button at the bottom, fill in the title, choose a category, write your story, and add pictures if you want. Then save it.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Your saved stories will appear under "User Stories." You can favorite any story by tapping the heart icon, and all your favorites will be shown in the "Favorites" section.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Want to listen instead of read? Tap the speaker icon to hear the story read aloud.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'You can change the font size, and switch between light or dark mode in the settings to make reading easier for you.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'You can also share stories with friends or download them as PDFs to read offline.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
     
           Text(
              'Thank you for using Stories App. Have fun reading and creating your own stories!',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
