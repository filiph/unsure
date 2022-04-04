import 'package:test/test.dart';
import 'package:unsure/src/formatter.dart';

void main() {
  group('thousands separator', () {
    test('125 stays 125', () {
      var result = addThousandsSeparator('125');

      expect(result, '125');
    });

    test('-1255 becomes -1,255', () {
      var result = addThousandsSeparator('-1255');

      expect(result, '-1,255');
    });

    test('12125 becomes 12,125', () {
      var result = addThousandsSeparator('12125');

      expect(result, '12,125');
    });

    test('12125.99 becomes 12,125.99', () {
      var result = addThousandsSeparator('12125.99');

      expect(result, '12,125.99');
    });
  });

  test('1000 and 2000 become 1K and 2K', () {
    var formatter = Formatter([1000, 2000]);

    expect(formatter.format(1000), '1K');
    expect(formatter.format(2000), '2K');
  });

  test('1000.1 and 1001.1', () {
    var formatter = Formatter([1000.1, 1001.1]);

    expect(formatter.format(1000.1), '1,000');
    expect(formatter.format(1001.1), '1,001');
  });

  test('2000 and 200', () {
    var formatter = Formatter([2000, 200]);

    expect(formatter.format(2000), '2,000');
    expect(formatter.format(200), '200');
  });

  test('3000 and 4400', () {
    var formatter = Formatter([3000, 4400]);

    expect(formatter.format(3000), '3,000');
    expect(formatter.format(4400), '4,400');
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

    expect(formatter.format(10000), '10,000');
    expect(formatter.format(5000), '5,000');
    expect(formatter.format(5020), '5,020');
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
    expect(formatter.format(0.00000002), '0.000000');
    expect(formatter.format(5300000000), '5,300,000,000.000000');
  });
}
