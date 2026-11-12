import 'dart:js_interop';

import 'package:logging/logging.dart';
import 'package:unsure/unsure.dart';
import 'package:unsure_example/models/result_message.dart';
import 'package:web/web.dart' as web;

final _logger = Logger('Worker');

@JS('self')
external web.DedicatedWorkerGlobalScope get _self;

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '[Worker] [${record.level.name}] ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('[Worker] Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('[Worker] StackTrace: ${record.stackTrace}');
    }
  });

  _logger.info('Web worker starting...');

  try {
    _self.onmessage = (web.MessageEvent event) {
      try {
        final rawData = event.data;
        final formulaString =
            (rawData as JSString?)?.toDart ?? (rawData?.toString() ?? '');
        _logger.info('Worker received formula: "$formulaString"');
        _compute(formulaString, _self);
      } catch (e, stack) {
        _logger.severe('Error processing message in worker: $e', e, stack);
        final message = FailureResultMessage('Worker exception: $e');
        _self.postMessage(message.toData().toJS);
      }
    }.toJS;

    _logger.info('Worker listener attached, sending ready signal');
    _self.postMessage('{"type":"ready"}'.toJS);
  } catch (e, stack) {
    _logger.severe('Failed to initialize worker: $e', e, stack);
  }
}

void _compute(String formulaString, web.DedicatedWorkerGlobalScope scope) {
  _logger.info('Parsing formula: "$formulaString"');
  // The inline formulas allow 'x' as a synonym for '*'.
  final normalizedFormula = formulaString.replaceAll(RegExp(r'[xX]'), '*');
  var parser = FormulaParser();
  var formula = parser.parseString(normalizedFormula);

  if (formula.wasFailure) {
    var buf = StringBuffer();
    if (formula.failurePosition > 0) {
      buf.write('after "');
      buf.write(formula.failureBuffer.substring(0, formula.failurePosition));
      buf.write('"');
    }
    if (formula.failurePosition > 0 &&
        formula.failurePosition < formula.failureBuffer.length - 1) {
      buf.write(' and ');
    }
    if (formula.failurePosition < formula.failureBuffer.length - 1) {
      buf.write('before "');
      buf.write(formula.failureBuffer
          .substring(formula.failurePosition, formula.failureBuffer.length));
      buf.write('"');
    }
    buf.write(' (');
    buf.write(formula.failureMessage);
    buf.write(')');

    _logger.warning('Formula parse failure: ${buf.toString()}');
    var message = FailureResultMessage(buf.toString());
    scope.postMessage(message.toData().toJS);
    return;
  }

  if (!formula.isStochastic) {
    _logger.info('Formula is deterministic, evaluating directly');
    var value = formula.emit();
    final formatter = Formatter(
        value == 0 ? [0.0, 1.0] : [value, value * 0.95, value * 1.05]);
    final valueString = formatter.format(value);
    _logger.info('Deterministic result: $valueString');
    var message = NonStochasticResultMessage(valueString);
    scope.postMessage(message.toData().toJS);
    return;
  }

  _logger.info(
      'Formula is stochastic, running Monte Carlo (250,000 iterations)...');
  var calculation = Calculation(formula.emit, iterations: 250000);
  var result = calculation.run();

  if (result.isInvalid) {
    _logger.warning('Calculation result is invalid: ${result.simple}');
    var message = InvalidResultMessage(result.simple);
    scope.postMessage(message.toData().toJS);
    return;
  }

  _logger.info('Calculation complete: ${result.simple}');
  var message = StochasticResultMessage(result.simple,
      result.histogram?.toString() ?? '', result.percentilesString);
  scope.postMessage(message.toData().toJS);
}
