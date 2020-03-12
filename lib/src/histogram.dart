import 'dart:math';

class ProbabilityHistogram {
  static const precision = 2;

  final double lowerBound;

  final double upperBound;

  final double bandSize;

  final int bandCount;

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

    /// Adds a line to [buf]. You can specify a different character
    /// for the bar, such as '░' or '▓'.
    void addLine(String label, int count, [String char = '▒']) {
      buf.write(label.padLeft(10));
      buf.write(' | ');
      for (var i = 0; i < (count / maxCount * maxSize); i++) {
        buf.write(char);
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
