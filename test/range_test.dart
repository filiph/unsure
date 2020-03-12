import 'package:test/test.dart';
import 'package:uncertainty/uncertainty.dart';

void main() {
  group('Range', () {
    test('normal distribution is normal', () {
      var r = Range(3, 7);

      var n = 100000;
      var possibilities = r.generate().take(n);
      var banded = possibilities.map((n) => n.round());
      var occurrences = _countOccurrences(banded);

      expect(occurrences[5], greaterThan(occurrences[1]));
      expect(occurrences[5], greaterThan(occurrences[9]));
      expect(occurrences[4], closeTo(occurrences[6], n / 100));
    });
  });
}

Map<int, int> _countOccurrences(Iterable<int> numbers) {
  final result = <int, int>{};

  for (final n in numbers) {
    final count = result.putIfAbsent(n, () => 0);
    result[n] = count + 1;
  }
  return result;
}
