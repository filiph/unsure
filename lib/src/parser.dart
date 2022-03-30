import 'package:petitparser/petitparser.dart';
import 'package:unsure/src/ast.dart';
import 'package:unsure/src/range.dart';

// ignore_for_file: omit_local_variable_types

/// The cached instance of the parser.
Parser? _formulaParser;

/// Construct the parser, with caching.
Parser get formulaParser {
  if (_formulaParser != null) return _formulaParser!;

  final Parser<AstNode> numberParser = digit()
      .plus()
      .seq(char('.').seq(digit().plus()).optional())
      .flatten()
      .trim()
      .map((a) => NumberNode(double.tryParse(a)!));

  // Start the arithmetic parser.
  // The following is taken from `package:petitparser` README.
  final builder = ExpressionBuilder();

  builder.group()
    ..primitive(numberParser)
    ..wrapper<String, String>(
      char('(').trim(),
      char(')').trim(),
      (l, a, r) => ParensNode(a),
    );

  // negation is a prefix operator
  builder.group().prefix<String>(
        char('-').trim(),
        (op, a) => NegativeNode(a),
      );

  // The range operator is left associative and very high-priority.
  builder.group().left(char('~').trim(), (a, dynamic op, b) {
    // TODO: actually throw when a or b are not stochastic
    assert(!(a as AstNode).isStochastic);
    assert(!(b as AstNode).isStochastic);
    final aValue = (a as AstNode).emit();
    final bValue = (b as AstNode).emit();
    if (aValue == bValue) {
      print('Warning: range $aValue~$bValue is auto-converted to just '
          'the value $aValue.');
      return NumberNode(aValue);
    }
    final range = Range(aValue, bValue);
    return RangeNode(range);
  });

  builder.group()
    ..wrapper(stringIgnoreCase('sqrt(').trim(), char(')').trim(),
        (dynamic l, a, dynamic r) => SquareRootFunctionNode(a))
    ..wrapper(stringIgnoreCase('sin(').trim(), char(')').trim(),
        (dynamic l, a, dynamic r) => SineFunctionNode(a))
    ..wrapper(stringIgnoreCase('cos(').trim(), char(')').trim(),
        (dynamic l, a, dynamic r) => CosineFunctionNode(a))
    ..wrapper(stringIgnoreCase('tan(').trim(), char(')').trim(),
        (dynamic l, a, dynamic r) => TangentFunctionNode(a));

  // power is right-associative
  builder.group().right<dynamic>(
        char('^').or(string('**')).trim(),
        (a, op, b) => MathPowerNode(a, b),
      );

  // multiplication and addition are left-associative
  builder.group()
    ..left<dynamic>(
      char('*').or(char('x')).or(char('X')).trim(),
      (a, op, b) => MultiplicationNode(a, b),
    )
    ..left<String>(
      char('/').trim(),
      (a, op, b) => DivisionNode(a, b),
    );
  builder.group()
    ..left<String>(
      char('+').trim(),
      (a, op, b) => AdditionNode(a, b),
    )
    ..left<String>(
      char('-').trim(),
      (a, op, b) => SubtractionNode(a, b),
    );

  _formulaParser = builder.build().end();
  return _formulaParser!;
}

FormulaAst parseString(String string) {
  final result = formulaParser.parse(string);

  return FormulaAst(result.isFailure ? null : result.value, result.isFailure,
      result.isFailure ? result.message : null, result.buffer, result.position);
}
