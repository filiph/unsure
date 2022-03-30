import 'dart:math';

import 'package:t_stats/t_stats.dart';
import 'package:unsure/src/formatter.dart';
import 'package:unsure/src/histogram.dart';

class Confidence {
  final num probability;

  final double lower;

  final double upper;

  const Confidence(this.probability, this.lower, this.upper);

  @override
  String toString() {
    final formatter = Formatter([lower, upper]);

    return "Confidence: We're $probability% sure that the result "
        'is between ${formatter.format(lower)} '
        'and ${formatter.format(upper)}.';
  }
}

class Result {
  /// The ratio of results that must be invalid in order for the whole
  /// calculation to return a [singleInvalidValue] instead of a statistic.
  static const double invalidThreshold = 0.5;

  final Statistic? statistic;

  final List<double>? percentiles;

  final List<Confidence>? confidences;

  final ProbabilityHistogram? histogram;

  final Confidence? with2StandardDeviations;

  final Confidence? with3StandardDeviations;

  final bool hadInvalidValues;

  /// When the result was mostly invalid, for almost any run of the simulation
  /// (like, for example, in the case of `100~101 / 0`), then
  /// this field will hold the most representative value (e.g. [double.infinity]
  /// or [double.nan];
  final double? singleInvalidValue;

  const Result(
    this.statistic,
    this.with2StandardDeviations,
    this.with3StandardDeviations,
    this.hadInvalidValues,
    this.percentiles,
    this.confidences,
    this.histogram,
  ) : singleInvalidValue = null;

  const Result.invalid(this.singleInvalidValue)
      : statistic = null,
        with2StandardDeviations = null,
        with3StandardDeviations = null,
        hadInvalidValues = true,
        percentiles = null,
        confidences = null,
        histogram = null;

  /// This is `true` if most of the results of the calculation were
  /// not-a-number (like, for example, in the case of `100~101 / 0`).
  bool get isInvalid => singleInvalidValue != null;

  String get percentilesString {
    final buf = StringBuffer();

    var printedPercentiles = <int, double>{};
    // Instead of 100 and 0 percentiles, which are often crazy outliers,
    // we show 2-sigma (95% confidence) percentiles.
    printedPercentiles[100] = with2StandardDeviations!.upper;
    for (var i = 95; i > 0; i -= 5) {
      printedPercentiles[i] = percentiles![i];
    }
    printedPercentiles[0] = with2StandardDeviations!.lower;

    final formatter = Formatter(printedPercentiles.values.toList());
    final longest = printedPercentiles.values
        .map(formatter.format)
        .map((s) => s.length)
        .reduce(max);
    for (final key in printedPercentiles.keys) {
      final value = printedPercentiles[key]!;
      if (key == 0) {
        buf.write('2.5 %'.padLeft(10));
      } else if (key == 100) {
        buf.write('97.5 %'.padLeft(10));
      } else {
        buf.write('$key %'.padLeft(10));
      }
      buf.write(' | ');
      buf.writeln(formatter.format(value).padLeft(longest));
    }

    return buf.toString();
  }

  String get simple {
    if (singleInvalidValue != null) {
      return '$singleInvalidValue';
    }

    final formatter = Formatter(
        [with2StandardDeviations!.lower, with2StandardDeviations!.upper]);
    final lower = formatter.format(with2StandardDeviations!.lower);
    final upper = formatter.format(with2StandardDeviations!.upper);

    return '$lower~$upper';
  }

  @override
  String toString() => statistic.toString();
}
