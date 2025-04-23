import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'theme_model.g.dart';

@HiveType(typeId: 1)
class ThemeModel extends HiveObject {
  @HiveField(0)
  int colorValue;

  @HiveField(1)
  bool isDarkMode;

  ThemeModel({
    required this.colorValue,
    required this.isDarkMode,
  });

  Color get color => Color(colorValue);
}
