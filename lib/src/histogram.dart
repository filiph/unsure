import 'dart:math';

import 'package:unsure/src/formatter.dart';

class ProbabilityHistogram {
  static const precision = 2;

  final double lowerBound;

  final double upperBound;

  final double bandSize;

  final double median;

  final int bandCount;

  final List<int> counts;

  final int cumulativeCountBelow;

  final int cumulativeCountAbove;

  const ProbabilityHistogram(
    this.lowerBound,
    this.median,
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

    double bandLabelForIndex(int i) {
      var bandStart = lowerBound + i * bandSize;
      // The "label" is the number in the middle between the band's lower
      // bound and the band's upper bound.
      return bandStart + bandSize / 2;
    }

    final labels = List<double>.generate(bandCount, bandLabelForIndex);

    final formatter = Formatter(labels);

    /// The highest of any of the bars.
    final maxCount = counts.fold<int>(0, max);

    /// The scale of the highest bar in the output.
    const maxSize = 30;

    /// Adds a line to [buf]. You can specify a different character
    /// for the bar, such as '░' or '▓'.
    void addLine(String label, int count,
        {String? trailing, String char = '▒'}) {
      buf.write(label.padLeft(10));
      buf.write(' | ');
      for (var i = 0; i < (count / maxCount * maxSize); i++) {
        buf.write(char);
      }
      if (trailing != null) {
        buf.write(trailing);
      }
      buf.writeln();
    }

    addLine('above', cumulativeCountAbove);

    for (var i = bandCount - 1; i >= 0; i--) {
      var count = counts[i];
      var bandStart = lowerBound + i * bandSize;

      String? trailing;
      if (bandStart < median && median < bandStart + bandSize) {
        trailing = ' (${formatter.format(median)})';
      }

      addLine(formatter.format(labels[i]), count, trailing: trailing);
    }

    addLine('below', cumulativeCountBelow);

    return buf.toString();
  }
}
