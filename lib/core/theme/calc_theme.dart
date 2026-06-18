import 'package:flutter/material.dart';

enum CalcThemeType {
  light,
  dark,
  oledBlack,
  retroLcd,
  classWizBlue,
  esPlusGray,
}

class CalcTheme {
  final Color backgroundColor;
  final Color displayBackgroundColor;
  final Color displayTextColor;
  final Color keyboardBackgroundColor;
  final Color numberKeyColor;
  final Color numberKeyTextColor;
  final Color operatorKeyColor;
  final Color operatorKeyTextColor;
  final Color functionKeyColor;
  final Color functionKeyTextColor;
  final Color shiftKeyColor;
  final Color alphaKeyColor;
  final TextStyle displayInputStyle;
  final TextStyle displayResultStyle;

  const CalcTheme({
    required this.backgroundColor,
    required this.displayBackgroundColor,
    required this.displayTextColor,
    required this.keyboardBackgroundColor,
    required this.numberKeyColor,
    required this.numberKeyTextColor,
    required this.operatorKeyColor,
    required this.operatorKeyTextColor,
    required this.functionKeyColor,
    required this.functionKeyTextColor,
    required this.shiftKeyColor,
    required this.alphaKeyColor,
    required this.displayInputStyle,
    required this.displayResultStyle,
  });

  static CalcTheme getTheme(CalcThemeType type) {
    switch (type) {
      case CalcThemeType.light:
        return CalcTheme(
          backgroundColor: Colors.white,
          displayBackgroundColor: const Color(0xFFF3F4F6),
          displayTextColor: Colors.black,
          keyboardBackgroundColor: const Color(0xFFE5E7EB),
          numberKeyColor: Colors.white,
          numberKeyTextColor: Colors.black,
          operatorKeyColor: const Color(0xFFD1D5DB),
          operatorKeyTextColor: Colors.black,
          functionKeyColor: const Color(0xFFF59E0B),
          functionKeyTextColor: Colors.white,
          shiftKeyColor: const Color(0xFFEAB308),
          alphaKeyColor: const Color(0xFFEC4899),
          displayInputStyle: const TextStyle(fontSize: 24, color: Colors.black87),
          displayResultStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        );
      case CalcThemeType.dark:
        return CalcTheme(
          backgroundColor: const Color(0xFF111827),
          displayBackgroundColor: const Color(0xFF1F2937),
          displayTextColor: Colors.white,
          keyboardBackgroundColor: const Color(0xFF111827),
          numberKeyColor: const Color(0xFF374151),
          numberKeyTextColor: Colors.white,
          operatorKeyColor: const Color(0xFF4B5563),
          operatorKeyTextColor: Colors.white,
          functionKeyColor: const Color(0xFFD97706),
          functionKeyTextColor: Colors.white,
          shiftKeyColor: const Color(0xFFEAB308),
          alphaKeyColor: const Color(0xFFEC4899),
          displayInputStyle: const TextStyle(fontSize: 24, color: Colors.white70),
          displayResultStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        );
      case CalcThemeType.oledBlack:
        return CalcTheme(
          backgroundColor: Colors.black,
          displayBackgroundColor: const Color(0xFF0D0D0D),
          displayTextColor: Colors.white,
          keyboardBackgroundColor: Colors.black,
          numberKeyColor: const Color(0xFF1A1A1A),
          numberKeyTextColor: Colors.white,
          operatorKeyColor: const Color(0xFF262626),
          operatorKeyTextColor: Colors.white,
          functionKeyColor: const Color(0xFFD97706),
          functionKeyTextColor: Colors.white,
          shiftKeyColor: const Color(0xFFCA8A04),
          alphaKeyColor: const Color(0xFFDB2777),
          displayInputStyle: const TextStyle(fontSize: 24, color: Colors.white70),
          displayResultStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        );
      case CalcThemeType.retroLcd:
        return CalcTheme(
          backgroundColor: const Color(0xFF4B5320),
          displayBackgroundColor: const Color(0xFF8FBC8F),
          displayTextColor: const Color(0xFF1E2F1E),
          keyboardBackgroundColor: const Color(0xFF2F4F4F),
          numberKeyColor: const Color(0xFF3E3E3E),
          numberKeyTextColor: Colors.white,
          operatorKeyColor: const Color(0xFF4A4A4A),
          operatorKeyTextColor: Colors.white,
          functionKeyColor: const Color(0xFFB8860B),
          functionKeyTextColor: Colors.white,
          shiftKeyColor: const Color(0xFFCA8A04),
          alphaKeyColor: const Color(0xFFC71585),
          displayInputStyle: const TextStyle(fontSize: 24, fontFamily: 'monospace', color: Color(0xFF0F1B0F)),
          displayResultStyle: const TextStyle(fontSize: 30, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF0F1B0F)),
        );
      case CalcThemeType.classWizBlue:
        return CalcTheme(
          backgroundColor: const Color(0xFF0F172A),
          displayBackgroundColor: const Color(0xFFE0F2FE),
          displayTextColor: const Color(0xFF0369A1),
          keyboardBackgroundColor: const Color(0xFF1E293B),
          numberKeyColor: const Color(0xFF334155),
          numberKeyTextColor: Colors.white,
          operatorKeyColor: const Color(0xFF475569),
          operatorKeyTextColor: Colors.white,
          functionKeyColor: const Color(0xFF0284C7),
          functionKeyTextColor: Colors.white,
          shiftKeyColor: const Color(0xFFCA8A04),
          alphaKeyColor: const Color(0xFFBE185D),
          displayInputStyle: const TextStyle(fontSize: 24, color: Colors.black87),
          displayResultStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
        );
      case CalcThemeType.esPlusGray:
        return CalcTheme(
          backgroundColor: const Color(0xFFE5E7EB),
          displayBackgroundColor: const Color(0xFFCCD6CE),
          displayTextColor: const Color(0xFF2C3531),
          keyboardBackgroundColor: const Color(0xFF9CA3AF),
          numberKeyColor: const Color(0xFFF3F4F6),
          numberKeyTextColor: Colors.black,
          operatorKeyColor: const Color(0xFFD1D5DB),
          operatorKeyTextColor: Colors.black,
          functionKeyColor: const Color(0xFF78350F),
          functionKeyTextColor: Colors.white,
          shiftKeyColor: const Color(0xFFCA8A04),
          alphaKeyColor: const Color(0xFF9D174D),
          displayInputStyle: const TextStyle(fontSize: 24, color: Colors.black87),
          displayResultStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E2F1F)),
        );
    }
  }
}
