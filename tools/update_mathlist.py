import sys

with open("lib/core/math_engine/ast_render_node.dart", "r") as f:
    content = f.read()

old_build = '''  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    List<Widget> children = [];
    for (int i = 0; i <= nodes.length; i++) {
      int idx = i;
      bool isCursorHere = (cursor.list == this && cursor.index == i);
      
      Widget gap = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onCursorChanged(MathCursor(this, idx));
        },
        child: Container(
          width: isCursorHere ? 2.0 : 0.0,
          color: Colors.transparent,
          child: isCursorHere ? const BlinkingCursor() : null,
        ),
      );
      children.add(gap);

      if (i < nodes.length) {
        children.add(nodes[i].buildWidget(cursor, style, color, onCursorChanged));
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }'''

new_build = '''  Widget buildWidget(MathCursor cursor, TextStyle style, Color color, void Function(MathCursor) onCursorChanged) {
    if (nodes.isEmpty) {
      bool isCursorHere = (cursor.list == this && cursor.index == 0);
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onCursorChanged(MathCursor(this, 0)),
        child: Container(
          width: isCursorHere ? 2.0 : 12.0,
          height: isCursorHere ? 20.0 : 16.0,
          decoration: isCursorHere ? null : BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5), width: 1.0),
            color: color.withOpacity(0.1),
          ),
          child: isCursorHere ? const BlinkingCursor() : null,
        ),
      );
    }

    List<Widget> children = [];
    for (int i = 0; i <= nodes.length; i++) {
      int idx = i;
      bool isCursorHere = (cursor.list == this && cursor.index == i);
      
      Widget gap = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onCursorChanged(MathCursor(this, idx));
        },
        child: Container(
          width: isCursorHere ? 2.0 : 0.0,
          color: Colors.transparent,
          child: isCursorHere ? const BlinkingCursor() : null,
        ),
      );
      children.add(gap);

      if (i < nodes.length) {
        children.add(nodes[i].buildWidget(cursor, style, color, onCursorChanged));
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }'''

content = content.replace(old_build, new_build)

with open("lib/core/math_engine/ast_render_node.dart", "w") as f:
    f.write(content)
