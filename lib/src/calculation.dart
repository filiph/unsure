import 'package:t_stats/t_stats.dart';
import 'package:unsure/src/histogram.dart';
import 'package:unsure/src/result.dart';
import 'package:unsure/unsure.dart';

/// A function that can be called repeatedly and it returns a number.
typedef Formula = double Function();

class Calculation {
  final Formula formula;

  final int iterations;

  const Calculation(this.formula, {this.iterations = 1000000});

  Result run() {
    // TODO: count invalid results. If most results are invalid, return
    //       a non-stochastic result. Test: sqrt(-100~-1) => NaN.
    var results =
        List<double>.generate(iterations, (_) => formula(), growable: false);
    results.sort();

    var invalidValuesCount = 0;
    double representativeInvalidValue;
    for (final result in results) {
      if (result.isNaN || result.isInfinite) {
        invalidValuesCount += 1;
        representativeInvalidValue = result;
      }
    }

    if (invalidValuesCount / iterations > Result.invalidThreshold) {
      // Bail out early.
      return Result.invalid(representativeInvalidValue);
    }

    var hadInvalidValues = invalidValuesCount > 0;

    if (hadInvalidValues) {
      results = List<double>.from(
          results.where((r) => !r.isNaN && !r.isInfinite),
          growable: false);
    }

    var length = results.length;

    var stat = Statistic.from(results);

    // https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule
    const percentage2Standard = 95.45;
    const padding2Standard = (100 - percentage2Standard) / 2;
    var with2StandardDeviations = Confidence(
      percentage2Standard,
      results[(length * padding2Standard / 100).floor()],
      results[(length * (100 - padding2Standard) / 100).floor()],
    );

    const percentage3Standard = 99.73;
    const padding3Standard = (100 - percentage3Standard) / 2;
    var with3StandardDeviations = Confidence(
      percentage3Standard,
      results[(length * padding3Standard / 100).floor()],
      results[(length * (100 - padding3Standard) / 100).floor()],
    );

    const percentileCount = 101 /* 0 - 100 */;
    var percentiles = List<double>(percentileCount);
    for (var p = 0; p < percentileCount - 1; p++) {
      percentiles[p] = results[(length * p / 100).floor()];
    }
    percentiles[100] = results.last;

    var histogram = _computeHistogram(results, percentiles);

    var confidences = _computeConfidences(results);

    return Result(stat, with2StandardDeviations, with3StandardDeviations,
        hadInvalidValues, percentiles, confidences, histogram);
  }

  List<Confidence> _computeConfidences(List<double> results) {
    return List<Confidence>.generate(101, (confidence) {
      if (confidence == 100) {
        return Confidence(100, double.negativeInfinity, double.infinity);
      }

      var padding = (1 - confidence / 100) / 2;
      var minimum = results[(results.length * padding).round()];
      var maximum = results[(results.length * (1 - padding)).round()];

      return Confidence(confidence, minimum, maximum);
    });
  }

  static ProbabilityHistogram _computeHistogram(
      List<double> results, List<double> percentiles) {
    final lower = percentiles[1];
    final median = percentiles[50];
    final upper = percentiles[99];

    const bandsCount = 21;
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

    return ProbabilityHistogram(lower, median, upper, bandSize, bandsCount,
        occurrences, belowLower, aboveUpper);
  }
}
