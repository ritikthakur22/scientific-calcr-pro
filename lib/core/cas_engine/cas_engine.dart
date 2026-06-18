import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

class CasEngine {
  static String? _nerdamerCode;

  static Future<String> getNerdamerCode() async {
    if (_nerdamerCode != null) return _nerdamerCode!;
    try {
      // Try loading through rootBundle
      _nerdamerCode = await rootBundle.loadString('assets/js/all.min.js');
    } catch (_) {
      // Fallback for tests or offline filesystems
      final file = File('assets/js/all.min.js');
      if (file.existsSync()) {
        _nerdamerCode = file.readAsStringSync();
      } else {
        final alternative = File('scratch_cas/node_modules/nerdamer/all.min.js');
        if (alternative.existsSync()) {
          _nerdamerCode = alternative.readAsStringSync();
        }
      }
    }
    return _nerdamerCode ?? '';
  }

  /// Evaluates Nerdamer command directly in a local JS runtime.
  /// Note: Use this only when already running inside an Isolate or for quick non-blocking calls.
  static String evaluateDirect(String jsCode, String command) {
    try {
      final javascriptRuntime = getJavascriptRuntime();
      try {
        javascriptRuntime.evaluate(jsCode);
        final JsEvalResult result = javascriptRuntime.evaluate(command);
        return result.stringResult;
      } finally {
        javascriptRuntime.dispose();
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('Failed to load dynamic library') ||
          errorStr.contains('cannot open shared object file') ||
          errorStr.contains('libquickjs_c_bridge_plugin')) {
        try {
          // Resolve absolute path to assets/js/all.min.js
          var path = File('assets/js/all.min.js').absolute.path;
          if (!File(path).existsSync()) {
            path = File('scratch_cas/node_modules/nerdamer/all.min.js').absolute.path;
          }
          final escapedPath = path.replaceAll('\\', '/');
          final script = "const nerdamer = require('$escapedPath'); console.log($command);";
          final result = Process.runSync('node', ['-e', script]);
          if (result.exitCode == 0) {
            return result.stdout.toString().trim();
          } else {
            throw Exception('Node.js fallback script failed: ${result.stderr}');
          }
        } catch (nodeError) {
          throw Exception('Native JS failed to load, and Node.js fallback failed: $nodeError\nOriginal: $e');
        }
      }
      rethrow;
    }
  }
}
