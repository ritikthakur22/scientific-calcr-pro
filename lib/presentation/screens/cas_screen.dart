import 'package:flutter/material.dart';
import '../../core/cas_engine/cas_engine.dart';
import '../../core/theme/calc_theme.dart';

class CasScreen extends StatefulWidget {
  const CasScreen({super.key});

  @override
  State<CasScreen> createState() => _CasScreenState();
}

class _CasScreenState extends State<CasScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _jsCode;
  bool _isEngineReady = false;
  
  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  Future<void> _initEngine() async {
    _jsCode = await CasEngine.getNerdamerCode();
    if (mounted) {
      setState(() {
        _isEngineReady = true;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _executeOperation(String opName, String Function(String) buildCommand) {
    if (!_isEngineReady || _jsCode == null) return;
    
    final expr = _inputController.text.trim();
    if (expr.isEmpty) return;

    final command = buildCommand(expr);
    try {
      final result = CasEngine.evaluateDirect(_jsCode!, command);
      setState(() {
        _history.add({
          "expr": expr,
          "result": result,
          "operation": opName,
        });
      });
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildOperationButton(String label, String opName, String Function(String) buildCommand, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          foregroundColor: theme.colorScheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _executeOperation(opName, buildCommand),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calcTheme = CalcTheme.getTheme(CalcThemeType.dark);
    final theme = Theme.of(context).copyWith(
      scaffoldBackgroundColor: calcTheme.backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: Colors.blueAccent,
        secondary: Colors.tealAccent,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CAS Engine'),
          backgroundColor: calcTheme.displayBackgroundColor,
          elevation: 0,
          actions: [
            if (_history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear History',
                onPressed: () {
                  setState(() {
                    _history.clear();
                  });
                },
              ),
          ],
        ),
        body: Column(
          children: [
            // History Area
            Expanded(
              child: !_isEngineReady
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return Card(
                          color: calcTheme.displayBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                          ),
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['operation']!,
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 20),
                                      color: Colors.grey,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        _inputController.text = item['result']!;
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item['expr']!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '= ${item['result']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Input and Controls Area
            Container(
              decoration: BoxDecoration(
                color: calcTheme.displayBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 16.0,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _inputController,
                    style: const TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'Enter expression...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: calcTheme.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _inputController.clear(),
                      ),
                    ),
                    onSubmitted: (value) => _executeOperation(
                      'Simplify',
                      (expr) => "nerdamer('$expr').toString()",
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: [
                      _buildOperationButton(
                        'Simplify',
                        'Simplify',
                        (expr) => "nerdamer('$expr').toString()",
                        theme,
                      ),
                      _buildOperationButton(
                        'Expand',
                        'Expand',
                        (expr) => "nerdamer('expand($expr)').toString()",
                        theme,
                      ),
                      _buildOperationButton(
                        'Factor',
                        'Factor',
                        (expr) => "nerdamer('factor($expr)').toString()",
                        theme,
                      ),
                      _buildOperationButton(
                        'Solve (x)',
                        'Solve',
                        (expr) => "nerdamer('solve($expr, x)').toString()",
                        theme,
                      ),
                      _buildOperationButton(
                        'd/dx',
                        'Differentiate',
                        (expr) => "nerdamer('diff($expr, x)').toString()",
                        theme,
                      ),
                      _buildOperationButton(
                        '∫ dx',
                        'Integrate',
                        (expr) => "nerdamer('integrate($expr, x)').toString()",
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
