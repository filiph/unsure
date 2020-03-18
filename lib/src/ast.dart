import 'dart:math' as math;

import 'package:unsure/src/range.dart';

class AdditionNode extends MathOperationNode {
  AdditionNode(AstNode a, AstNode b) : super(a, b);

  @override
  double compute(double a, double b) => a + b;
}

abstract class AstNode {
  /// This is here so that subclasses can be const.
  const AstNode();

  /// This is `true` if the node can emit different values randomly.
  ///
  /// For example, a [NumberNode] (such as: `5`) is not stochastic, because
  /// it always evaluates to 5. On the other hand, a [RangeNode] will
  /// be stochastic.
  ///
  /// Nodes can defer to their children to find out if they are stochastic
  /// or not.
  bool get isStochastic;

  /// Generates a number.
  ///
  /// For example, a random [Range] will generate numbers given by its
  /// probability distribution. A constant will always emit its own value.
  /// A multiplication node will ask its children to emit a number, then
  /// returns the product of those numbers. And so on.
  double emit();
}

class CosineFunctionNode extends MathFunctionNode {
  CosineFunctionNode(AstNode a) : super(a);

  @override
  double compute(double a) => math.cos(a / 180 * math.pi);
}

class DivisionNode extends MathOperationNode {
  DivisionNode(AstNode a, AstNode b) : super(a, b);

  @override
  double compute(double a, double b) => a / b;
}

class FormulaAst implements AstNode {
  final AstNode rootNode;

  final bool wasFailure;

  final String failureMessage;

  final String failureBuffer;

  final int failurePosition;

  const FormulaAst(this.rootNode, this.wasFailure, this.failureMessage,
      this.failureBuffer, this.failurePosition);

  @override
  bool get isStochastic => rootNode.isStochastic;

  @override
  double emit() => rootNode.emit();
}

abstract class MathFunctionNode extends AstNode {
  final AstNode a;

  MathFunctionNode(this.a);

  @override
  bool get isStochastic => a.isStochastic;

  double compute(double a);

  @override
  double emit() => compute(a.emit());
}

abstract class MathOperationNode extends AstNode {
  final AstNode a;

  final AstNode b;

  MathOperationNode(this.a, this.b);

  @override
  bool get isStochastic => a.isStochastic || b.isStochastic;

  double compute(double a, double b);

  @override
  double emit() => compute(a.emit(), b.emit());
}

class MathPowerNode extends AstNode {
  final AstNode x;

  final AstNode exponent;

  const MathPowerNode(this.x, this.exponent);

  @override
  bool get isStochastic => x.isStochastic || exponent.isStochastic;

  @override
  double emit() => math.pow(x.emit(), exponent.emit());
}

class MultiplicationNode extends MathOperationNode {
  MultiplicationNode(AstNode a, AstNode b) : super(a, b);

  @override
  double compute(double a, double b) => a * b;
}

class NegativeNode extends AstNode {
  final AstNode child;

  const NegativeNode(this.child);

  @override
  bool get isStochastic => child.isStochastic;

  @override
  double emit() => -child.emit();
}

class NumberNode extends AstNode {
  final double value;

  const NumberNode(this.value);

  @override
  bool get isStochastic => false;

  @override
  double emit() => value;
}

/// Simple parenthesis wrapper. Just returns child's value.
class ParensNode extends AstNode {
  final AstNode child;

  const ParensNode(this.child);

  @override
  bool get isStochastic => child.isStochastic;

  @override
  double emit() => child.emit();
}

class RangeNode extends AstNode {
  final Range range;

  const RangeNode(this.range);

  @override
  bool get isStochastic => true;

  @override
  double emit() => range.next();
}

class SineFunctionNode extends MathFunctionNode {
  SineFunctionNode(AstNode a) : super(a);

  @override
  double compute(double a) => math.sin(a / 180 * math.pi);
}

class SquareRootFunctionNode extends MathFunctionNode {
  SquareRootFunctionNode(AstNode a) : super(a);

  @override
  double compute(double a) => math.sqrt(a);
}

class SubtractionNode extends MathOperationNode {
  SubtractionNode(AstNode a, AstNode b) : super(a, b);

  @override
  double compute(double a, double b) => a - b;
}

class TangentFunctionNode extends MathFunctionNode {
  TangentFunctionNode(AstNode a) : super(a);

  @override
  double compute(double a) => math.tan(a / 180 * math.pi);
}
