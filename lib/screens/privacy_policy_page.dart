import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '''
This Privacy Policy explains how your data is handled in the Stories for Kids app.

1. No Personal Data Collection  
We do not collect, store, or share any personal information from users.

2. Offline Use  
The app works entirely offline. No internet connection is required to access content.

3. No Ads or Tracking  
There are no third-party ads or tracking mechanisms within this app.

4. Permissions  
We only request permissions necessary to function (like storage for saving user stories or themes).

5. Kid-Friendly Design  
This app is designed to be safe and fun for children. We follow basic safety and privacy guidelines to protect young users.

If you have questions, feel free to contact us.

Thank you for using Stories for Kids!
                ''',
                style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
              ),
             
              Text(
                'Contact Email: vijimsc92@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
