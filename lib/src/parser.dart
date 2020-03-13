import 'dart:math' as math;

import 'package:petitparser/petitparser.dart';
import 'package:unsure/src/calculation.dart';
import 'package:unsure/src/range.dart';

final numberParser = digit()
    .plus()
    .seq(char('.').seq(digit().plus()).optional())
    .flatten()
    .trim()
    .map((a) => double.tryParse(a));

final rangeGatherer = rangeParser.map<Range>((a) {
  assert(a.length == 3);
  return Range(a.first, a.last);
});

// Instantiate all the ranges we'll need, so that we only do this once.
final rangeParser = numberParser.seq(char('~').trim()).seq(numberParser);

Formula parseString(String string) {
  // Gather them from the string, skipping over everything else.
  final rangesList = rangeGatherer.matchesSkipping(string);

  // Put all the ranges in a map, accessible by a string.
  final ranges = <String, Range>{};
  for (final range in rangesList) {
    ranges['${range.minimum}~${range.maximum}'] = range;
  }

  // Load the range back from our map, and call `.next()` to get a random
  // number from it.
  final rangeExecutor = rangeParser.map((a) {
    assert(a.length == 3);
    final minimum = a.first, maximum = a.last;
    final range = ranges['$minimum~$maximum'];
    return range.next();
  });

  // Start the arithmetic parser.
  // The following is taken from `package:petitparser` README.
  final builder = ExpressionBuilder();

  builder.group()
    // Range is at the top. We give it more importance than anything else.
    ..primitive(rangeExecutor)
    ..primitive(numberParser)
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

  // TODO: instead of parsing every time, return a tree of nodes that
  //       can execute themselves and emit a value
  return () => parser.parse(string).value as double;
}
