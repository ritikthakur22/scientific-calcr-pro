import sys

with open("lib/core/math_engine/math_parser.dart", "r") as f:
    content = f.read()

preprocess_addition = '''    // Replace nth_root and cbrt
    processed = processed.replaceAllMapped(RegExp(r'nth_root\(([^,]+),\s*(.+)\)'), (m) => '(${m.group(2)})^(1/(${m.group(1)}))');
    processed = processed.replaceAllMapped(RegExp(r'cbrt\((.+)\)'), (m) => '(${m.group(1)})^(1/3)');

    // Replace integrals: integrate(body, x, lower, upper)
    // Actually, evaluating integrals in a single pass requires a parser change, 
    // but we'll leave it for CAS or basic operations for now.
'''

content = content.replace('// Convert curly/square brackets to standard parentheses', preprocess_addition + '\n    // Convert curly/square brackets to standard parentheses')

with open("lib/core/math_engine/math_parser.dart", "w") as f:
    f.write(content)
