import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:t_stats/t_stats.dart';
import 'package:uncertainty/src/calculation.dart';
import 'package:uncertainty/src/parser.dart';

Future<int> main(List<String> args) async {
  // TODO: use package:args for this
  if (args.contains('help') ||
      args.contains('-?') ||
      args.contains('-h') ||
      args.contains('--help')) {
    print(_help);
    return 2;
  }
  final machine = args.contains('--machine');

  if (stdout.hasTerminal) {
    stdout.writeln('Write a formula and hit enter. To end the session, '
        'type exit or hit Ctrl-D.');
    stdout.write('> ');
  }

  final lineSplitter = LineSplitter();
  var hintGiven = false;

  final lines =
      await stdin.timeout(const Duration(milliseconds: 500), onTimeout: (sink) {
    if (stdin.hasTerminal || hintGiven) return;
    stderr.writeln('Nothing has come from this pipe for more than 500ms. '
        'Is everything set up properly?');
    hintGiven = true;
  }).map((bytes) {
    final string = utf8.decode(bytes);
    final lines = lineSplitter.convert(string);
    return lines;
  }).expand((lines) => lines);

  // TODO wrap with keyboard interrupt try-catch
  await for (final line in lines) {
    if (line.trim() == 'exit' || line.trim() == 'quit') {
      break;
    }

    final formula = parseString(line);
    final calculation = Calculation(formula);
    final result = calculation.run();
    stdout.writeln(result.simple);
    stdout.writeln(result.histogram);

    if (stdout.hasTerminal) {
      stdout.write('> ');
    }
  }

  return 0;
}

const _help = r'''
Just run this and start typing formulas.
''';
