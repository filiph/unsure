# Unsure Calculator

Just a stub for now. Please go to 
[filiph.github.io/unsure](https://filiph.github.io/unsure) to learn more
about the Unsure Calculator.

### Use as a binary

You can compile the binary buy running `dart2native bin/unsure.dart`. Then,
call the binary with a formula, like this:

    $ ./unsure "10~20 * 42"
    
To get help, run `./unsure --help`.

### Use as a package

Apart from that online tool, this is also a (beginning of a) package. 
Read through `bin/unsure.dart` to see how it might be used.

Here's a more low-level example of use:

```dart
import 'package:unsure/unsure.dart';

void main() {
    var principal = 1000;
    var interestRate = Range(2, 4);
    var time = Range(10, 12);
    
    var calc = Calculation(
      () => principal * (1 + interestRate.next() / 100) * time.next());
    
    var result = calc.run();
    
    print(result.simple);
    print(result.histogram);
    print(result.confidences[99]);
}

```

In this example, we defined one constant (`principal`), two ranges
(`interestRate` and `time`), and a custom callback that computes compound
interest given the above. The callback can be arbitrary Dart code: you are
not limited to the format understandable by `lib/src/parser.dart`.

### Language

Some language to use when talking about statistical probabilities.

* All / certainly - 100%
* Almost all / almost certainly - 95%
* Large majority / quite possibly - 68%
* Bare or small majority / possibly - 50%
