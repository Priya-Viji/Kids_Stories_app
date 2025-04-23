import 'package:flutter/material.dart';
import 'package:stories_for_kids/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:stories_for_kids/screens/about_page.dart';
import 'package:stories_for_kids/screens/privacy_policy_page.dart';
//import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
 
   // Default selected color
  Color selectedColor = Colors.pink;

  final List<Color> colors = [
    Colors.green,
    Colors.purple,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.blueGrey,
    Colors.teal
  ];

  @override
  Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: themeProvider.themeColor,
        foregroundColor: Colors.white, // White text
      ),
     body: ListView(
        children: [
          buildSettingItem(
            themeProvider,
            Icons.dark_mode,
            "Day Night Mode",
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: themeProvider.isDarkMode,
                activeColor: themeProvider.themeColor,
                onChanged: (value) {
                  themeProvider.toggleDarkMode(value);
                },
              ),
            ),
          ),

          buildSettingItem(
            themeProvider,
            Icons.color_lens,
            "Theme",
            onTap: () {
              _showColorPicker(context, themeProvider);
            },
          ),
         
          buildSettingItem(themeProvider, 
          Icons.privacy_tip, 
          "Privacy Policy",
          onTap: () {    
                         Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
       
            },
          ),
         
          buildSettingItem(themeProvider, Icons.info, "About",
          onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
          }),
        ],
      ),
    );
  }

  Widget buildSettingItem(
    ThemeProvider themeProvider,
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: themeProvider.themeColor,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge, // ✅ dynamic color
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 65, right: 15),
          child: Divider(thickness: 1, color: Colors.grey.shade300),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)), // Rounded dialog
        title: const Text("Select a color"),
        content: Wrap(
          spacing: 15,
          runSpacing: 15,
          children: colors.map((color) {
            bool isSelected = themeProvider.themeColor == color;
            return GestureDetector(
              onTap: () {
                themeProvider.setThemeColor(color);
                //Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 30)
                    : null,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

}
