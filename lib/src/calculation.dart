import 'package:t_stats/t_stats.dart';
import 'package:uncertainty/src/result.dart';

/// A function that can be called repeatedly and it returns a number.
typedef Formula = double Function();

class Calculation {
  final Formula formula;

  final int iterations;

  const Calculation(this.formula, {this.iterations = 1000000});

  Result run() {
    var results =
        List<double>.generate(iterations, (_) => formula(), growable: false);
    results.sort();

    var stat = Statistic.from(results);

    const percentileCount = 101 /* 0 - 100 */;
    var percentiles = List<double>(percentileCount);
    for (var p = 0; p < percentileCount; p++) {
      percentiles[p] = results[(iterations * p / percentileCount).floor()];
    }

    var histogram = _computeHistogram(results, percentiles);

    var confidences = _computeConfidences(results);

    return Result(stat, percentiles, confidences, histogram);
  }

  static ProbabilityHistogram _computeHistogram(
      List<double> results, List<double> percentiles) {
    final lower = percentiles[2];
    final upper = percentiles[98];

    const bandsCount = 20;
    var bandSize = (upper - lower) / bandsCount;

    final occurrences = List<int>.generate(bandsCount, (_) => 0);
    var belowLower = 0;
    var aboveUpper = 0;

    for (final n in results) {
      if (!n.isFinite) {
        // Just ignore NaNs and infinities.
        continue;
      }

      if (n < lower) {
        belowLower++;
        continue;
      }

      if (n >= upper) {
        aboveUpper++;
        continue;
      }

      final band = (n - lower) ~/ bandSize;
      occurrences[band]++;
    }

    return ProbabilityHistogram(lower, upper, bandSize, bandsCount, occurrences,
        belowLower, aboveUpper);
  }

  List<Confidence> _computeConfidences(List<double> results) {
    return List<Confidence>.generate(101, (confidence) {
      if (confidence == 100) {
        return Confidence(100, double.negativeInfinity, double.infinity);
      }

      var padding = (1 - confidence / 100) / 2;
      var minimum = results[(iterations * padding).round()];
      var maximum = results[(iterations * (1 - padding)).round()];

      return Confidence(confidence, minimum, maximum);
    });
  }
}
