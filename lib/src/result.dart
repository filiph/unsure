import 'dart:math';

import 'package:t_stats/t_stats.dart';
import 'package:uncertainty/src/histogram.dart';

class Confidence {
  final int probability;

  final double lower;

  final double upper;

  const Confidence(this.probability, this.lower, this.upper);

  @override
  String toString() {
    return "Confidence: We're $probability% sure that the result "
        'is between ${lower.toStringAsFixed(2)} '
        'and ${upper.toStringAsFixed(2)}.';
  }
}

class Result {
  final Statistic statistic;

  final List<double> percentiles;

  final List<Confidence> confidences;

  final ProbabilityHistogram histogram;

  const Result(
      this.statistic, this.percentiles, this.confidences, this.histogram);

  String get simple => '${confidences[95].lower}'
      '~'
      '${confidences[95].upper}';

  // TODO: toRange -- uses percentiles to get a range from this result

  @override
  String toString() => statistic.toString();
}
