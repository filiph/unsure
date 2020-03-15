import 'package:petitparser/petitparser.dart';
import 'package:unsure/src/ast.dart';
import 'package:unsure/src/range.dart';

// ignore_for_file: omit_local_variable_types

/// The cached instance of the parser.
Parser _formulaParser;

/// Construct the parser, with caching.
Parser get formulaParser {
  if (_formulaParser != null) return _formulaParser;

  final Parser<AstNode> numberParser = digit()
      .plus()
      .seq(char('.').seq(digit().plus()).optional())
      .flatten()
      .trim()
      .map((a) => NumberNode(double.tryParse(a)));

  // Start the arithmetic parser.
  // The following is taken from `package:petitparser` README.
  final builder = ExpressionBuilder();

  builder.group()
    ..primitive<AstNode>(numberParser)
    ..wrapper<String, AstNode>(
      char('(').trim(),
      char(')').trim(),
      (l, a, r) => ParensNode(a),
    );

  // negation is a prefix operator
  builder.group()
    ..prefix<String, AstNode>(
      char('-').trim(),
      (op, a) => NegativeNode(a),
    );

  // The range operator is left associative and very high-priority.
  builder.group()
    ..left(char('~').trim(), (a, op, b) {
      // TODO: actually throw when a or b are not stochastic
      assert(!(a as AstNode).isStochastic);
      assert(!(b as AstNode).isStochastic);
      final range = Range(a.emit(), b.emit());
      return RangeNode(range);
    });

  builder.group()
    ..wrapper(stringIgnoreCase('sqrt(').trim(), char(')').trim(),
        (l, a, r) => SquareRootFunctionNode(a))
    ..wrapper(stringIgnoreCase('sin(').trim(), char(')').trim(),
        (l, a, r) => SineFunctionNode(a))
    ..wrapper(stringIgnoreCase('cos(').trim(), char(')').trim(),
        (l, a, r) => CosineFunctionNode(a))
    ..wrapper(stringIgnoreCase('tan(').trim(), char(')').trim(),
        (l, a, r) => TangentFunctionNode(a));

  // power is right-associative
  builder.group()
    ..right<dynamic, AstNode>(
      char('^').or(string('**')).trim(),
      (a, op, b) => MathPowerNode(a, b),
    );

  // multiplication and addition are left-associative
  builder.group()
    ..left<dynamic, AstNode>(
      char('*').or(char('x')).or(char('X')).trim(),
      (a, op, b) => MultiplicationNode(a, b),
    )
    ..left<String, AstNode>(
      char('/').trim(),
      (a, op, b) => DivisionNode(a, b),
    );
  builder.group()
    ..left<String, AstNode>(
      char('+').trim(),
      (a, op, b) => AdditionNode(a, b),
    )
    ..left<String, AstNode>(
      char('-').trim(),
      (a, op, b) => SubtractionNode(a, b),
    );

  _formulaParser = builder.build().end();
  return _formulaParser;
}

FormulaAst parseString(String string) {
  final result = formulaParser.parse(string);

  return FormulaAst(result.value, result.isSuccess, result.message);
}
