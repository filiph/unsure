import 'dart:math';

/// A simple range, in which every value is as likely as any other
/// (the distribution is flat).
///
/// For the bell curve, use [NormalDistribution] instead.
class Range {
  static final Random _reusableRandom = Random();

  /// The minimum and maximum are the 95% range of the numbers.
  final double minimum, maximum;

  /// The distance between [minimum] and [maximum].
  final double distance;

  final Random _random;

  Range(this.minimum, this.maximum, {Random? random})
      : assert(
            minimum < maximum,
            'Minimum must be lower than maximum: '
            'minimumum=$minimum, maximum=$maximum'),
        distance = maximum - minimum,
        _random = random ?? _reusableRandom;

  double emit() {
    return minimum + distance * _random.nextDouble();
  }
}
