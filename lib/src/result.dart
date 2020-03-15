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

  String get simple {
    final formatter = Formatter(
        [with2StandardDeviations.lower, with2StandardDeviations.upper]);
    final lower = formatter.format(with2StandardDeviations.lower);
    final upper = formatter.format(with2StandardDeviations.upper);

    return '$lower~$upper';
  }

  // TODO: toRange -- uses percentiles to get a range from this result

  @override
  String toString() => statistic.toString();
}
