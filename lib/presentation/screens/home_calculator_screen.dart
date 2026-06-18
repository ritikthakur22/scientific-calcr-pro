import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/calculator_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/calc_theme.dart';
import '../widgets/textbook_display.dart';
import '../widgets/casio_keyboard.dart';
import 'history_screen.dart';
import 'graph_screen.dart';
import 'unit_converter_screen.dart';
import 'constants_screen.dart';
import 'equation_screen.dart';
import 'matrix_screen.dart';
import 'vector_screen.dart';
import 'statistics_screen.dart';
import 'table_screen.dart';
import 'base_n_screen.dart';
import 'cas_screen.dart';
import 'formula_vault_screen.dart';

import "about_screen.dart";
import "privacy_policy_screen.dart";
import "package:url_launcher/url_launcher.dart";

class HomeCalculatorScreen extends ConsumerWidget {
  const HomeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcState = ref.watch(calculatorProvider);
    final calcNotifier = ref.read(calculatorProvider.notifier);
    final themeType = ref.watch(themeProvider);
    final calcTheme = CalcTheme.getTheme(themeType);

    String modeName = calcState.mode.toString().split('.').last.toUpperCase();
    if (calcState.isExamMode) {
      modeName += " (EXAM MODE)";
    }

    return Scaffold(
      backgroundColor: calcTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Scientific CalcR Pro'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'Graphing Engine',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GraphScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          PopupMenuButton<CalcThemeType>(
            icon: const Icon(Icons.palette),
            onSelected: (selectedTheme) {
              ref.read(themeProvider.notifier).setTheme(selectedTheme);
            },
            itemBuilder: (context) => CalcThemeType.values.map((type) {
              return PopupMenuItem<CalcThemeType>(
                value: type,
                child: Text(type.toString().split('.').last.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase()),
              );
            }).toList(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: calcTheme.displayBackgroundColor,
              ),
              child: Text(
                'Scientific CalcR Pro',
                style: TextStyle(
                  color: calcTheme.displayTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Formula Vault'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormulaVaultScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Constants Library'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConstantsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Unit Converter'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UnitConverterScreen()),
                );
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Exam Mode'),
              subtitle: const Text('Locks history and converter for exams'),
              value: calcState.isExamMode,
              onChanged: (val) {
                calcNotifier.setExamMode(val);
                Navigator.pop(context); // Close drawer
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Scientific CalcR Pro'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Contact Developer'),
              onTap: () async {
                Navigator.pop(context);
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'ritikthakur@duck.com',
                  queryParameters: {
                    'subject': 'Scientific CalcR Pro Feedback'
                  },
                );
                if (!await launchUrl(emailLaunchUri)) {
                  // Handle error if needed
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Theme'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: CalcThemeType.values.map((type) {
                        return ListTile(
                          title: Text(type.toString().split('.').last.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase()),
                          onTap: () {
                            ref.read(themeProvider.notifier).setTheme(type);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Dual-Display natural textbook display
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextbookDisplay(
                expression: calcState.expression,
                mathAst: calcState.mathAst,
                onCursorChanged: (cursor) => calcNotifier.setCursor(cursor),
                result: calcState.result,
                theme: calcTheme,
                isShift: calcState.isShift,
                isAlpha: calcState.isAlpha,
                modeName: modeName,
                cursorPosition: calcState.cursorPosition,
              ),
            ),
          ),

          // 2. Calculator Keyboard (Casio keypad system)
          Expanded(
            flex: 5,
            child: CasioKeyboard(
              theme: calcTheme,
              isShift: calcState.isShift,
              isAlpha: calcState.isAlpha,
              onKeyPressed: (char) => calcNotifier.append(char),
              onClear: () => calcNotifier.clear(),
              onBackspace: () => calcNotifier.backspace(),
              onEvaluate: () => calcNotifier.evaluate(),
              onShiftPressed: () => calcNotifier.toggleShift(),
              onAlphaPressed: () => calcNotifier.toggleAlpha(),
              onModePressed: () => _showModeSelection(context, ref),
              onNavUp: () => calcNotifier.undo(), // Use UP for undo as a smartphone enhancement
              onNavDown: () => calcNotifier.redo(), // Use DOWN for redo
              onNavLeft: () => calcNotifier.moveCursorLeft(),
              onNavRight: () => calcNotifier.moveCursorRight(),
              onHistory: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
              onGraph: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GraphScreen()),
                );
              },
              onSetMode: (mode) => calcNotifier.setMode(mode),
              onConst: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConstantsScreen()),
                );
              },
              onConv: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UnitConverterScreen()),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showModeSelection(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: CalculatorMode.values.map((mode) {
            String name = mode.toString().split('.').last.toUpperCase();
            return ListTile(
              title: Text(name),
              onTap: () {
                ref.read(calculatorProvider.notifier).setMode(mode);
                Navigator.pop(context);
                
                // Route to dedicated workspace if needed
                Widget? nextScreen;
                switch (mode) {
                  case CalculatorMode.equation:
                    nextScreen = const EquationScreen();
                    break;
                  case CalculatorMode.matrix:
                    nextScreen = const MatrixScreen();
                    break;
                  case CalculatorMode.vector:
                    nextScreen = const VectorScreen();
                    break;
                  case CalculatorMode.statistics:
                    nextScreen = const StatisticsScreen();
                    break;
                  case CalculatorMode.table:
                    nextScreen = const TableScreen();
                    break;
                  case CalculatorMode.baseN:
                    nextScreen = const BaseNScreen();
                    break;
                  case CalculatorMode.graph:
                    nextScreen = const GraphScreen();
                    break;
                  case CalculatorMode.unitConverter:
                    nextScreen = const UnitConverterScreen();
                    break;
                  case CalculatorMode.cas:
                    nextScreen = const CasScreen();
                    break;
                  default:
                    // COMP, COMPLEX use the main screen workspace
                    break;
                }
                
                if (nextScreen != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => nextScreen!),
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }
}
