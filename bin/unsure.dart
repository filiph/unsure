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
    print('\n  Histogram:');
    print(result.histogram);
  }

  if (argResults['percentiles']) {
    print('Percentiles:');

    var printedPercentiles = <int, double>{};
    // Instead of 100 and 0 percentiles, which are often crazy outliers,
    // we show 3-sigma (99.73% confidence) percentiles.
    printedPercentiles[100] = result.with3StandardDeviations.upper;
    for (var i = 95; i > 0; i -= 5) {
      printedPercentiles[i] = result.percentiles[i];
    }
    printedPercentiles[0] = result.with3StandardDeviations.lower;

    final formatter = Formatter(printedPercentiles.values.toList());
    final longest = printedPercentiles.values
        .map(formatter.format)
        .map((s) => s.length)
        .reduce(max);
    for (final key in printedPercentiles.keys) {
      final value = printedPercentiles[key];
      print('${(key == 0 || key == 100 ? '~' : '')}$key %'.padLeft(10) +
          ' | ' +
          formatter.format(value).padLeft(longest));
    }
  }

  return 0;
}

const _help = r'''
Run this executable with the formula you're trying to compute. For example:

  $ unsure "4~6 * 1~2"

''';
