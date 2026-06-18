import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/calc_theme.dart';

class ThemeNotifier extends StateNotifier<CalcThemeType> {
  ThemeNotifier() : super(CalcThemeType.classWizBlue) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('scientific_calcr_theme_type') ?? CalcThemeType.classWizBlue.index;
    state = CalcThemeType.values[themeIndex];
  }

  Future<void> setTheme(CalcThemeType type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scientific_calcr_theme_type', type.index);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, CalcThemeType>((ref) {
  return ThemeNotifier();
});
