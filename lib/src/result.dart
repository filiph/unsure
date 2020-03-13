import 'package:t_stats/t_stats.dart';
import 'package:uncertainty/src/histogram.dart';

class Confidence {
  final num probability;

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

  final Confidence with2StandardDeviations;

  const Result(this.statistic, this.with2StandardDeviations, this.percentiles,
      this.confidences, this.histogram);

  String get simple => '${with2StandardDeviations.lower}'
      '~'
      '${with2StandardDeviations.upper}';

  // TODO: toRange -- uses percentiles to get a range from this result

  @override
  String toString() => statistic.toString();
}
