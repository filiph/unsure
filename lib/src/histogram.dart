import 'dart:math';

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

    /// The highest of any of the bars.
    final maxCount = counts.fold<int>(0, max);

    /// The scale of the highest bar in the output.
    const maxSize = 30;

    /// Adds a line to [buf]. You can specify a different character
    /// for the bar, such as '░' or '▓'.
    void addLine(
      String label,
      int count, {
      String trailing,
      String char = '▒',
    }) {
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

    for (var i = bandCount -1; i >= 0; i--) {
      var count = counts[i];
      var bandStart = lowerBound + i * bandSize;

      String trailing;
      if (bandStart < median && median < bandStart + bandSize) {
        trailing = ' (${median.toStringAsFixed(2)})';
      }

      var bandLabel = bandStart + bandSize / 2;
      addLine(bandLabel.toStringAsFixed(precision), count, trailing: trailing);
    }

    addLine('below', cumulativeCountBelow);

    return buf.toString();
  }
}
