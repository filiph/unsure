import 'package:test/test.dart';
import 'package:uncertainty/src/formatter.dart';
import 'package:uncertainty/src/parser.dart';

void main() {
  test('1000 and 2000 become 1K and 2K', () {
    var formatter = Formatter([1000, 2000]);

    expect(formatter.format(1000), '1K');
    expect(formatter.format(2000), '2K');
  });

  test('1000.1 and 1001.1', () {
    var formatter = Formatter([1000.1, 1001.1]);

    expect(formatter.format(1000.1), '1000');
    expect(formatter.format(1001.1), '1001');
  });

  test('2000 and 200', () {
    var formatter = Formatter([2000, 200]);

    expect(formatter.format(2000), '2000');
    expect(formatter.format(200), '200');
  });

  test('3000 and 4400', () {
    var formatter = Formatter([3000, 4400]);

    expect(formatter.format(3000), '3000');
    expect(formatter.format(4400), '4400');
  });

  test('10000 and 0.0001', () {
    var formatter = Formatter([10000, 0.0001]);

    expect(formatter.format(10000), '10K');
    expect(formatter.format(0.0001), '0K');
  });

  test('10000, 5000 and 0.0001', () {
    var formatter = Formatter([10000, 5000, 0.0001]);

    expect(formatter.format(10000), '10K');
    expect(formatter.format(5000), '5K');
    expect(formatter.format(0.0001), '0K');
  });

  test('10000, 5000, 5020 and 0.0001', () {
    var formatter = Formatter([10000, 5000, 5020, 0.0001]);

    expect(formatter.format(10000), '10000');
    expect(formatter.format(5000), '5000');
    expect(formatter.format(5020), '5020');
    expect(formatter.format(0.0001), '0');
  });

  test('1000000 and 5300000', () {
    var formatter = Formatter([1000000, 5300000]);

    expect(formatter.format(1000000), '1.0M');
    expect(formatter.format(5300000), '5.3M');
  });

  test('1000000000 and 5300000000', () {
    var formatter = Formatter([1000000000, 5300000000]);

    expect(formatter.format(1000000000), '1.0B');
    expect(formatter.format(5300000000), '5.3B');
  });

  test('0.000001 and 0.00000002 and 5300000000 (default)', () {
    var formatter = Formatter([0.000001, 0.00000002, 5300000000]);

    expect(formatter.format(0.000001), '0.000001');
    expect(formatter.format(0.00000002), '2e-8');
    expect(formatter.format(5300000000), '5300000000.0');
  });
}
