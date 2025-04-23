import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stories_for_kids/models/theme_model.dart';

class ThemeProvider extends ChangeNotifier {
  late Color _themeColor;
  bool _isDarkMode = false;

  Color get themeColor => _themeColor;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  final Box<ThemeModel> _box = Hive.box<ThemeModel>('themeBox');

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    if (_box.containsKey('themeData')) {
      final model = _box.get('themeData')!;
      _themeColor = model.color;
      _isDarkMode = model.isDarkMode;
    } else {
      _themeColor = Colors.pink;
      _isDarkMode = false;
    }
    notifyListeners();
  }

  void setThemeColor(Color color) {
    _themeColor = color;
    _saveToBox();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    _saveToBox();
  }

  void _saveToBox() {
    _box.put(
      'themeData',
      ThemeModel(
        // ignore: deprecated_member_use
        colorValue: _themeColor.value,
        isDarkMode: _isDarkMode,
      ),
    );
    notifyListeners();
  }
}
