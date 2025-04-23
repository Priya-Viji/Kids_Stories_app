import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:stories_for_kids/screens/add_story_page.dart';
import 'package:stories_for_kids/screens/favorite_page.dart';
import 'package:stories_for_kids/screens/home_page.dart';
import 'package:stories_for_kids/screens/library_page.dart';
import 'package:stories_for_kids/screens/userstories_page.dart';
import '../providers/theme_provider.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _selectedIndex = 2;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const LibraryPage(),
      const UserstoriesPage(),
      const HomePage(),
      AddStoryPage(onStorySaved: _onStorySaved),
      const FavoritePage(),
    ];
  }

  void _onStorySaved() {
    setState(() {
      _selectedIndex = 1; 
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _navBarIcons {
    final screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth > 600 ? 30 : 25;

    return const [
      Icon(Icons.book, color: Colors.white),
      Icon(Icons.person, color: Colors.white),
      Icon(Icons.home, color: Colors.white),
      Icon(Icons.article, color: Colors.white),
      Icon(Icons.favorite, color: Colors.white),
    ]
        .map((icon) => Icon(icon.icon, size: iconSize, color: icon.color))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final navBarHeight = screenWidth > 600 ? 70.0 : 60.0;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: _navBarIcons,
        onTap: _onItemTapped,
        height: navBarHeight,
        backgroundColor: isDark ? Colors.black : Colors.grey[100]!,
        color: themeProvider.themeColor,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
