import 'dart:math';

import 'package:petitparser/petitparser.dart';
import 'package:unsure/src/ast.dart';
import 'package:unsure/src/normal_distribution.dart';
import 'package:unsure/src/range.dart';

// ignore_for_file: omit_local_variable_types

class FormulaParser {
  /// Pre-existing variables. For example, this formula may be merely
  /// `x + 1~2`, where `x` is defined elsewhere.
  final Map<String, FormulaAst> variables;

  /// The cached instance of the parser.
  Parser? _formulaParser;

  /// A [Random] instance that can be injected so that the same formula
  /// always produces the same result.
  final Random? random;

  FormulaParser({Iterable<FormulaAst> variables = const [], this.random})
      : variables = _extractVariableMap(variables);

  /// Construct the parser, with caching.
  Parser get formulaParser {
    if (_formulaParser != null) return _formulaParser!;

    // Start the arithmetic parser.
    // The following is taken from `package:petitparser` README.
    final builder = ExpressionBuilder<AstNode>();

    // Variables have the highest priority.
    // Take every variable and make a string parser from it.
    final variableParsers = variables.keys
        .map((key) => string(key)
            .trim()
            .map((value) => VariableNode(key, variables[key]!)))
        .toList(growable: false);

    // Numbers and parenthesis are just a tad down from variables.
    final Parser<AstNode> numberParser = digit()
        .plus()
        .seq(char('.').seq(digit().plus()).optional())
        .flatten()
        .trim()
        .map((a) => NumberNode(double.parse(a)));

    // Top group
    final topGroup = builder.group();
    topGroup.primitive(numberParser);
    for (final parser in variableParsers) {
      topGroup.primitive(parser);
    }
    topGroup.wrapper<String, String>(
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
    builder.group().left<String>(char('~').trim(), (a, op, b) {
      if (a.isStochastic) {
        throw ArgumentError('Cannot create a range with stochastic start: $a');
      }
      if (b.isStochastic) {
        throw ArgumentError('Cannot create a range with stochastic end: $b');
      }
      final aValue = a.emit();
      final bValue = b.emit();
      if (aValue == bValue) {
        print('Warning: range $aValue~$bValue is auto-converted to just '
            'the value $aValue.');
        return NumberNode(aValue);
      }
      final range = Range(aValue, bValue, random: random);
      return RangeNode(range);
    });

    // The normal distribution operator is left associative
    // and very high-priority. Example: 10+-2
    builder.group().left<String>(
        [string('+-'), char('±')].toChoiceParser().trim(), (a, op, b) {
      if (a.isStochastic) {
        throw ArgumentError('Cannot create a range with stochastic start: $a');
      }
      if (b.isStochastic) {
        throw ArgumentError('Cannot create a range with stochastic end: $b');
      }
      final aValue = a.emit();
      final bValue = b.emit();
      if (aValue == bValue) {
        print('Warning: range $aValue+-$bValue is auto-converted to just '
            'the value $aValue.');
        return NumberNode(aValue);
      }
      final ndist = NormalDistribution(aValue, bValue, random: random);
      return NormalDistributionNode(ndist);
    });

    // The % postfix (just divides by 100).
    builder.group()
      ..postfix(char('%').trim(), (a, op) => ConstantMultipleNode(a, 1 / 100))
      ..postfix(stringIgnoreCase('K').trim(),
          (a, op) => ConstantMultipleNode(a, 1000))
      ..postfix(stringIgnoreCase('M').trim(),
          (a, op) => ConstantMultipleNode(a, 1000000));

    // TODO: add a +- parser

    // Math functions.
    // TODO: take more from Excel / Google Spreadsheets: MOD(), POWER(),
    //       CEILING(), FLOOR(), LOG(), LN(), LOG10() EXP(), SIGN(), POW(),
    //       ABS(), CLAMP()
    //       FV(), PV(), PMT(), PPMT(), NPER(), RATE(), EFFECT(),
    //       NOMINAL(), SLN()
    //       PI, E, TAU
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
    builder.group().right<String>(
          [char('^'), string('**')]
              .toChoiceParser(failureJoiner: selectFarthestJoined)
              .trim(),
          (a, op, b) => MathPowerNode(a, b),
        );

    // multiplication and addition are left-associative
    builder.group()
      ..left<String>(
        [char('*'), char('×'), char('·')]
            .toChoiceParser(failureJoiner: selectFarthestJoined)
            .trim(),
        (a, op, b) => MultiplicationNode(a, b),
      )
      ..left<String>(
        [char('/'), char('÷')]
            .toChoiceParser(failureJoiner: selectFarthestJoined)
            .trim(),
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

  /// Parses [string] (a mathematical formula) and returns the [FormulaAst].
  ///
  /// If [variables] are provided, their names can be used in the formula.
  /// The variables are other, formerly parsed [FormulaAst]s. They should
  /// be provided in definition order, so that later definitions of a formula
  /// with the same name will override earlier ones.
  ///
  /// If the formula should be its own variable, provide its [name].
  FormulaAst parseString(String string, {String? name}) {
    if (name != null) {
      if (name.isEmpty) {
        throw ArgumentError('Name of variable cannot be empty');
      }

      if (name.contains(' ')) {
        throw ArgumentError('Name of variable cannot have spaces in it: $name');
      }
    }

    final result = formulaParser.parse(string);

    return FormulaAst(
        result.isFailure ? null : result.value,
        result.isFailure,
        result.isFailure ? result.message : null,
        result.buffer,
        result.position,
        name: name);
  }

  /// Extracts [FormulaParser.variables] (a map) from the given [variables].
  /// If [variables] contains several formulas with the same [FormulaAst.name],
  /// then the latest one is use (later definitions override previous ones).
  ///
  /// This throws an [ArgumentError] if any of the [variables] has no name.
  static Map<String, FormulaAst> _extractVariableMap(
      Iterable<FormulaAst> variables) {
    final result = <String, FormulaAst>{};
    for (final variable in variables) {
      if (variable.name == null) {
        throw ArgumentError.notNull(
            'FormulaParser was constructed with a variable with '
            'no name: $variable');
      }
      if (variable.name!.isEmpty) {
        throw ArgumentError(
            'FormulaParser was constructed with a variable with '
            'an empty name');
      }

      result[variable.name!] = variable;
    }
    return result;
  }
}
