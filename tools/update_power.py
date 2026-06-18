with open('lib/core/math_engine/ast_render_node.dart', 'r') as f:
    content = f.read()

old_power = """class RenderPower extends RenderProxyBox {
  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(child!.size.width, child!.size.height * 1.5));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double childBaseline = child!.getDistanceToActualBaseline(baseline) ?? child!.size.height;
    return childBaseline + child!.size.height * 0.5;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }
}"""

new_power = """class RenderPower extends RenderProxyBox {
  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(child!.size.width, child!.size.height * 1.8));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    double childBaseline = child!.getDistanceToActualBaseline(baseline) ?? child!.size.height;
    return childBaseline + child!.size.height * 0.8;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }
}"""

content = content.replace(old_power, new_power)

with open('lib/core/math_engine/ast_render_node.dart', 'w') as f:
    f.write(content)
