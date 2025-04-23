import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stories_for_kids/db/hive_db.dart';
import 'package:stories_for_kids/models/theme_model.dart';
import 'package:stories_for_kids/providers/theme_provider.dart';
import 'package:stories_for_kids/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';

const bool isWeb = kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveDB.init();
  Hive.registerAdapter(ThemeModelAdapter());
  await Hive.openBox<ThemeModel>('themeBox');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kids Stories',
          themeMode:
              themeProvider.themeMode, // ✅ required for dark/light toggle
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: themeProvider.themeColor,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: themeProvider.themeColor,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: themeProvider.themeColor,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: AppBarTheme(
              backgroundColor: themeProvider.themeColor,
              foregroundColor: Colors.white,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
