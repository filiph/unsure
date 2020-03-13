import 'package:unsure/uncertainty.dart';

void main() {
  var r = Range(3, 7);

  var n = 10000;
  var possibilities = r.generate().take(n);
  var banded = possibilities.map((n) => n.round());
  var occurrences = _countOccurrences(banded);

  for (final key in occurrences.keys.toList()..sort()) {
    var count = occurrences[key];
    print(key.toString().padLeft(4) + ' | ' + '%' * (count / n * 20).round());
  }
}

Map<int, int> _countOccurrences(Iterable<int> numbers) {
  final result = <int, int>{};

  for (final n in numbers) {
    final count = result.putIfAbsent(n, () => 0);
    result[n] = count + 1;
  }
  return result;
}
