import 'dart:async';
import 'dart:math';

import 'package:args/args.dart';
import 'package:unsure/unsure.dart';

Future<int> main(List<String> args) async {
  final argParser = ArgParser();

  argParser
    ..addFlag('help',
        abbr: 'h', help: 'Print this help information.', negatable: false)
    ..addFlag('percentiles',
        abbr: 'p', help: 'Show a table of percentiles.', negatable: false)
    ..addFlag('histogram', help: 'Show the histogram.', defaultsTo: true);

  final argResults = argParser.parse(args);

  if (argResults['help']) {
    print(_help);
    print(argParser.usage);
    return 2;
  }

  final formulaString = argResults.rest.join(' ');

  final formula = parseString(formulaString);
  final calculation = Calculation(formula);
  final result = calculation.run();
  print(result.simple);

  if (argResults['histogram']) {
    print('\nHistogram:\n');
    print(result.histogram);
  }

  if (argResults['percentiles']) {
    print('Percentiles:\n');

    final format = Formatter(result.percentiles);
    final longest =
        result.percentiles.map(format.format).map((s) => s.length).reduce(max);
    for (var i = 100; i >= 0; i -= 5) {
      final value = result.percentiles[i];
      print('$i %'.padLeft(10) + ' | ' + format.format(value).padLeft(longest));
    }
  }

  return 0;
}

const _help = r'''
Run this executable with the formula you're trying to compute. For example:

  $ unsure "4~6 * 1~2"

''';
