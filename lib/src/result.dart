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
  final Statistic statistic;

  final List<double> percentiles;

  final List<Confidence> confidences;

  final ProbabilityHistogram histogram;

  final Confidence with2StandardDeviations;

  final Confidence with3StandardDeviations;

  final bool hadInvalidValues;

  const Result(
    this.statistic,
    this.with2StandardDeviations,
    this.with3StandardDeviations,
    this.hadInvalidValues,
    this.percentiles,
    this.confidences,
    this.histogram,
  );

  String get percentilesString {
    final buf = StringBuffer();

    var printedPercentiles = <int, double>{};
    // Instead of 100 and 0 percentiles, which are often crazy outliers,
    // we show 3-sigma (99.73% confidence) percentiles.
    printedPercentiles[100] = with3StandardDeviations.upper;
    for (var i = 95; i > 0; i -= 5) {
      printedPercentiles[i] = percentiles[i];
    }
    printedPercentiles[0] = with3StandardDeviations.lower;

    final formatter = Formatter(printedPercentiles.values.toList());
    final longest = printedPercentiles.values
        .map(formatter.format)
        .map((s) => s.length)
        .reduce(max);
    for (final key in printedPercentiles.keys) {
      final value = printedPercentiles[key];
      buf.write('${(key == 0 || key == 100 ? '~' : '')}$key %'.padLeft(10));
      buf.write(' | ');
      buf.writeln(formatter.format(value).padLeft(longest));
    }

    return buf.toString();
  }

  // TODO: toRange -- uses percentiles to get a range from this result

  String get simple {
    final formatter = Formatter(
        [with2StandardDeviations.lower, with2StandardDeviations.upper]);
    final lower = formatter.format(with2StandardDeviations.lower);
    final upper = formatter.format(with2StandardDeviations.upper);

    return '$lower~$upper';
  }

  @override
  String toString() => statistic.toString();
}
