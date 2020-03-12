import 'dart:math';

import 'package:t_stats/t_stats.dart';

class ProbabilityHistogram {
  final double lowerBound;

  final double upperBound;

  final double bandSize;

  final int bandCount;

  static const precision = 2;

  final List<int> counts;

  final int cumulativeCountBelow;

  final int cumulativeCountAbove;

  const ProbabilityHistogram(
    this.lowerBound,
    this.upperBound,
    this.bandSize,
    this.bandCount,
    this.counts,
    this.cumulativeCountBelow,
    this.cumulativeCountAbove,
  );

  @override
  String toString() {
    final buf = StringBuffer();

    /// The highest of any of the bars.
    final maxCount = counts.fold<int>(0, max);

    /// The scale of the highest bar in the output.
    const maxSize = 30;

    void addLine(String label, int count) {
      buf.write(label.padLeft(10));
      buf.write(' | ');
      for (var i = 0; i < (count / maxCount * maxSize); i++) {
        buf.write('▒');
      }
      buf.writeln();
    }

    addLine('below', cumulativeCountBelow);

    for (var i = 0; i < bandCount; i++) {
      var count = counts[i];
      var bandStart = lowerBound + i * bandSize;

      addLine(bandStart.toStringAsFixed(precision), count);
    }

    addLine('above', cumulativeCountAbove);

    return buf.toString();
  }
}

class Result {
  final Statistic statistic;

  final List<double> percentiles;

  final List<Confidence> confidences;

  final ProbabilityHistogram histogram;

  const Result(
      this.statistic, this.percentiles, this.confidences, this.histogram);

  // TODO: toRange -- uses percentiles to get a range from this result

  @override
  String toString() => statistic.toString();
}

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
