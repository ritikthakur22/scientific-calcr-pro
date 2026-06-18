import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home_calculator_screen.dart';
import 'providers/theme_provider.dart';
import 'core/theme/calc_theme.dart';

import 'core/execution/math_isolate.dart';
import 'core/execution/calculation_job.dart';
import 'core/cas_engine/cas_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Asynchronously pre-warm the CAS background isolate to eliminate first-use latency.
  // This executes concurrently with the UI frame build.
  _prewarmCasIsolate();

  runApp(
    const ProviderScope(
      child: ScientificCalcrProApp(),
    ),
  );
}

void _prewarmCasIsolate() async {
  try {
    final jsCode = await CasEngine.getNerdamerCode();
    if (jsCode.isNotEmpty) {
      final warmJob = CalculationJob(
        id: 'prewarm-cas-${DateTime.now().millisecondsSinceEpoch}',
        type: JobType.casSimplify,
        expression: '0',
        extra: {'jsCode': jsCode},
      );
      await MathIsolate.executeJob(warmJob);
      debugPrint("CAS Isolate successfully pre-warmed.");
    }
  } catch (e) {
    debugPrint("Warning: CAS Isolate pre-warming failed: $e");
  }
}

class ScientificCalcrProApp extends ConsumerWidget {
  const ScientificCalcrProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    final calcTheme = CalcTheme.getTheme(themeType);

    return MaterialApp(
      title: 'Scientific CalcR Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: (themeType == CalcThemeType.light || themeType == CalcThemeType.esPlusGray)
            ? Brightness.light
            : Brightness.dark,
        scaffoldBackgroundColor: calcTheme.backgroundColor,
        useMaterial3: true,
      ),
      home: const HomeCalculatorScreen(),
    );
  }
}
