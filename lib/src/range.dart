import 'dart:math';

class Range {
  static final Random _reusableRandom = Random();

  /// The minimum and maximum are the 95% range of the numbers.
  final double minimum, maximum;

  final Random _random;

  final double mean;

  final double standardDeviation;

  Iterator<double> _iterator;

  Range(this.minimum, this.maximum, {Random random})
      : assert(minimum != null),
        assert(maximum != null),
        assert(minimum < maximum, 'Minimum must be lower than maximum: '
            'minimumum=$minimum, maximum=$maximum'),
        // In normal distribution, the mean is simply half-way between
        // the minimum and the maximum.
        mean = minimum + (maximum - minimum) / 2,
        // Both the minimum and the maximum are 2 standard deviations
        // from the mean. That means their total distance is 4 standard
        // deviations.
        standardDeviation = (maximum - minimum) / 4,
        _random = random ?? _reusableRandom {
    _iterator = generate().iterator;
  }

  double get variance => standardDeviation * standardDeviation;

  /// An adaptation of the code in `package:normal`, with tighter types,
  /// better performance and a lazy iterable instead of a List.
  /// Generates random data drawn from a normal distribution through
  /// the Box-Muller algorithm.
  Iterable<double> generate() sync* {
    _Pair makePair() {
      final u1 = _random.nextDouble(),
          u2 = _random.nextDouble(),
          r = sqrt(-2 * log(u1)),
          t = 2 * pi * u2;
      return _Pair(r * cos(t), r * sin(t));
    }

    while (true) {
      final pair = makePair();
      yield pair.a * standardDeviation + mean;
      yield pair.b * standardDeviation + mean;
    }
  }

  double next() {
    _iterator.moveNext();
    return _iterator.current;
  }
}

/// A simple wrapper of two [double] values. Better than building a [List].
class _Pair {
  final double a, b;

  const _Pair(this.a, this.b);
}
