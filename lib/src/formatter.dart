import 'dart:math';

/// The list of precision. The [Formatter] algorithm goes from
/// top to bottom, and tries each precision until it finds a good match.
final _precisions = <_Precision>[
  _Precision(
    '5B',
    (n) => _divide(n, 1000000000) + 'B',
    (s) => double.tryParse(s.substring(0, s.length - 1)) * 1000000000,
  ),
  _Precision(
    '4.2B',
    (n) => (n / 1000000000).toStringAsFixed(1) + 'B',
    (s) => double.tryParse(s.substring(0, s.length - 1)) * 1000000000,
  ),
  _Precision(
    '5M',
    (n) => _divide(n, 1000000) + 'M',
    (s) => double.tryParse(s.substring(0, s.length - 1)) * 1000000,
  ),
  _Precision(
    '4.2M',
    (n) => (n / 1000000).toStringAsFixed(1) + 'M',
    (s) => double.tryParse(s.substring(0, s.length - 1)) * 1000000,
  ),
  _Precision(
    '52K',
    (n) => _divide(n, 1000) + 'K',
    (s) => double.tryParse(s.substring(0, s.length - 1)) * 1000,
  ),
  _Precision(
    '350',
    (n) => _quantize(n, 50),
  ),
  _Precision(
    '340',
    (n) => _quantize(n, 10),
  ),
  _Precision(
    '345',
    (n) => _quantize(n, 5),
  ),
  _Precision(
    '343',
    (n) => n.round().toString(),
  ),
  _Precision(
    '324.3',
    (n) => n.toStringAsFixed(1),
  ),
  _Precision(
    '324.34',
    (n) => n.toStringAsFixed(2),
  ),
  _Precision(
    '324.341',
    (n) => n.toStringAsFixed(3),
  ),
  _Precision(
    '324.3410',
    (n) => n.toStringAsFixed(4),
  ),
];

/// Returns a string representation of the [number] divided by [divisor].
/// For example, `_divide(40344, 1000)` becomes `"40"`.
String _divide(double number, int divisor) {
  return (number / divisor).round().toString();
}

/// Returns a string representation of the [number] quantized by [step].
/// For example, `_quantize(40344, 50)` becomes `"40350"`.
String _quantize(double number, int step) {
  return ((number / step).round() * step).toString();
}

/// This class will figure out the best way to format a set of numbers
/// so that they are not overly specific (1000 and 2000 become 1K and 2K)
/// and that they still maintain their differences (1000.1 and 1001.1 become
/// 1000 and 1001).
class Formatter {
  _Precision _precision;

  Formatter(List<double> numbers) {
    // The default is the Dart automatic precision.
    var best = _Precision(
      '324.34143423',
      (n) => n.toString(),
    );

    var largestValue = numbers.fold<double>(0, (prev, e) => max(prev, e.abs()));

    final representations = <String>{};
    // For each precision, in order of "vagueness" ...
    for (final precision in _precisions) {
      var cumulativeError = 0.0;
      representations.clear();
      for (final n in numbers) {
        // ... try the precision on each number ...
        final r = precision.formatFunction(n);
        if (representations.contains(r)) break;
        representations.add(r);
        cumulativeError += (n - precision.parseBack(r)).abs();
      }
      // ... discard the ones that accrue too large of an error ...
      if (cumulativeError > 0.05 * largestValue) {
        // (0.05 is an arbitrary constant. It _feels_ weird when the cumulative
        // error is more than 5% of the largest value in the set.)
        continue;
      }
      // ... and see if it results in a set of unique representations.
      if (representations.length == numbers.length) {
        best = precision;
        // No need to continue, we've found our precision.
        break;
      }
    }

    _precision = best;
  }

  String format(double number) {
    return _precision.formatFunction(number);
  }
}

class _Precision {
  final String example;

  final String Function(double) formatFunction;

  final double Function(String) parseBack;

  const _Precision(this.example, this.formatFunction,
      [this.parseBack = double.tryParse]);
}
