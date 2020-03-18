import 'package:dorker/dorker.dart';
import 'package:unsure/unsure.dart';
import 'package:unsure_angular_dart/unsure_result_message.dart';

class UnsureDorker {
  final Dorker _dorker;

  UnsureDorker(this._dorker) {
    _dorker.onMessage.listen(_compute);
  }

  void _compute(dynamic event) {
    var formulaString = event as String;
    var formula = parseString(formulaString);

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

      var message = FailureResultMessage(buf.toString());
      _dorker.postMessage.add(message.toData());
      return;
    }

    if (!formula.isStochastic) {
      var value = formula.emit();
      final formatter = Formatter([value, value * 0.95, value * 1.05]);
      final valueString = formatter.format(value);
      var message = NonStochasticResultMessage(valueString);
      _dorker.postMessage.add(message.toData());
      return;
    }

    var calculation = Calculation(formula.emit, iterations: 250000);
    var result = calculation.run();
    var message = StochasticResultMessage(
        result.simple, result.histogram.toString(), result.percentilesString);
    _dorker.postMessage.add(message.toData());
  }
}
