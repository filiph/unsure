import 'dart:async';

import 'package:args/args.dart';
import 'package:unsure/src/calculation.dart';
import 'package:unsure/src/parser.dart';

Future<int> main(List<String> args) async {
  final argParser = ArgParser();

  argParser
    ..addFlag('help',
        abbr: 'h', help: 'Print this help information.', negatable: false)
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

  return 0;
}

const _help = r'''
Run this executable with the formula you're trying to compute. For example:

  $ unsure 4~6 * 1~2

''';
