import 'dart:math' as math;

import 'package:unsure/src/normal_distribution.dart';
import 'package:unsure/src/range.dart';

class AdditionNode extends MathOperationNode {
  AdditionNode(super.a, super.b);

  @override
  double compute(double a, double b) => a + b;
}

abstract class AstNode {
  /// This is here so that subclasses can be const.
  const AstNode();

  /// This is `true` if the node can emit different values randomly.
  ///
  /// For example, a [NumberNode] (such as: `5`) is not stochastic, because
  /// it always evaluates to 5. On the other hand, a [NormalDistributionNode] will
  /// be stochastic.
  ///
  /// Nodes can defer to their children to find out if they are stochastic
  /// or not.
  bool get isStochastic;

  /// Generates a number.
  ///
  /// For example, a random [NormalDistribution] will generate numbers given by its
  /// probability distribution. A constant will always emit its own value.
  /// A multiplication node will ask its children to emit a number, then
  /// returns the product of those numbers. And so on.
  double emit();
}

/// Nodes such as `10%` (where the `%` means "divide by 100") or
/// `10M` (where the `M` means "multiply by a million").
class ConstantMultipleNode extends AstNode {
  final AstNode a;

  final double k;

  ConstantMultipleNode(this.a, this.k);

  @override
  bool get isStochastic => k != 0 && a.isStochastic;

  @override
  double emit() {
    if (k == 0) return 0;
    return a.emit() * k;
  }
}

class CosineFunctionNode extends MathFunctionNode {
  CosineFunctionNode(super.a);

  @override
  double compute(double a) => math.cos(a / 180 * math.pi);
}

class DivisionNode extends MathOperationNode {
  DivisionNode(super.a, super.b);

  @override
  bool get isStochastic {
    if (!a.isStochastic && a.emit() == 0) return false;
    return a.isStochastic || b.isStochastic;
  }

  @override
  double compute(double a, double b) => a / b;

  @override
  double emit() {
    if (!a.isStochastic) {
      final aVal = a.emit();
      if (aVal == 0) return 0;
      return compute(aVal, b.emit());
    }
    return super.emit();
  }
}

class FormulaAst implements AstNode {
  final AstNode? rootNode;

  /// The name of the variable, if any, that this formula represents.
  final String? name;

  final bool wasFailure;

  final String? failureMessage;

  final String failureBuffer;

  final int failurePosition;

  const FormulaAst(this.rootNode, this.wasFailure, this.failureMessage,
      this.failureBuffer, this.failurePosition,
      {this.name});

  @override
  bool get isStochastic => rootNode!.isStochastic;

  @override
  double emit() => rootNode!.emit();
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
  bool get isStochastic {
    if (!exponent.isStochastic && exponent.emit() == 0) return false;
    if (!x.isStochastic) {
      final xVal = x.emit();
      if (xVal == 1 || xVal == 0) return false;
    }
    return x.isStochastic || exponent.isStochastic;
  }

  @override
  double emit() {
    if (!exponent.isStochastic) {
      final expVal = exponent.emit();
      if (expVal == 0) return 1;
    }
    if (!x.isStochastic) {
      final xVal = x.emit();
      if (xVal == 1) return 1;
      if (xVal == 0) return 0;
    }
    return math.pow(x.emit(), exponent.emit()) as double;
  }
}

class MultiplicationNode extends MathOperationNode {
  MultiplicationNode(super.a, super.b);

  @override
  bool get isStochastic {
    if (!a.isStochastic && a.emit() == 0) return false;
    if (!b.isStochastic && b.emit() == 0) return false;
    return a.isStochastic || b.isStochastic;
  }

  @override
  double compute(double a, double b) => a * b;

  @override
  double emit() {
    if (!a.isStochastic) {
      final aVal = a.emit();
      if (aVal == 0) return 0;
      return compute(aVal, b.emit());
    }
    if (!b.isStochastic) {
      final bVal = b.emit();
      if (bVal == 0) return 0;
      return compute(a.emit(), bVal);
    }
    return super.emit();
  }
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

class NormalDistributionNode extends AstNode {
  final NormalDistribution range;

  const NormalDistributionNode(this.range);

  @override
  bool get isStochastic => range.standardDeviation != 0;

  @override
  double emit() => range.next();
}

class RangeNode extends AstNode {
  final Range range;

  const RangeNode(this.range);

  @override
  bool get isStochastic => range.minimum != range.maximum;

  @override
  double emit() => range.emit();
}

class SineFunctionNode extends MathFunctionNode {
  SineFunctionNode(super.a);

  @override
  double compute(double a) => math.sin(a / 180 * math.pi);
}

class SquareRootFunctionNode extends MathFunctionNode {
  SquareRootFunctionNode(super.a);

  @override
  double compute(double a) => math.sqrt(a);
}

class SubtractionNode extends MathOperationNode {
  SubtractionNode(super.a, super.b);

  @override
  double compute(double a, double b) => a - b;
}

class TangentFunctionNode extends MathFunctionNode {
  TangentFunctionNode(super.a);

  @override
  double compute(double a) => math.tan(a / 180 * math.pi);
}

class VariableNode extends AstNode {
  final String variableName;

  final FormulaAst formula;

  const VariableNode(this.variableName, this.formula);

  @override
  bool get isStochastic => formula.isStochastic;

  @override
  double emit() => formula.emit();
}
