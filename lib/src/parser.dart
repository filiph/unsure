import 'dart:math' as math;

import 'package:petitparser/petitparser.dart';
import 'package:uncertainty/src/calculation.dart';
import 'package:uncertainty/src/range.dart';

class ParsedCalculation {
  /// A map from string representations of ranges (like `4~5`) to their
  /// [Range] instances.
  Map<String, Range> ranges;
}

Formula parseString(String string) {
  final builder = ExpressionBuilder();

  // TODO: skip the string and gather ranges and instantiate them

  // The following is taken from `package:petitparser` README.
  builder.group()
    ..primitive(digit()
        .plus()
        .seq(char('.').seq(digit().plus()).optional())
        .flatten()
        .trim()
        .map((a) => double.tryParse(a)))
    ..wrapper(char('(').trim(), char(')').trim(), (l, a, r) => a);

  // negation is a prefix operator
  builder.group()..prefix(char('-').trim(), (op, a) => -a);

  // power is right-associative
  builder.group()..right(char('^').trim(), (a, op, b) => math.pow(a, b));

  // multiplication and addition are left-associative
  builder.group()
    ..left(char('*').trim(), (a, op, b) => a * b)
    ..left(char('/').trim(), (a, op, b) => a / b);
  builder.group()
    ..left(char('+').trim(), (a, op, b) => a + b)
    ..left(char('-').trim(), (a, op, b) => a - b);

  final parser = builder.build().end();

  return () => parser.parse(string).value as double;
}
