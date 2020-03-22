# Unsure Calculator

[![Build Status - Cirrus][]][Build status]

If you want to run the Unsure Calculator from source, this repository
is for you. Otherwise, please go to 
[filiph.github.io/unsure][webapp] to learn more
about the Unsure Calculator itself.

### Web example

The web calculator is in `example/`. To run it from source:

    $ cd example/
    $ webdev serve --release

Now, navigating to `http://localhost:8080` will open the page. Changing
code in the project will trigger a rebuild. The `--release` flag is important,
because otherwise the web worker won't work.

To publish the example to 
[filiph.github.io/unsure](https://filiph.github.io/unsure), do the following:

1. Install peanut (only once): `pub global activate peanut`
2. Go to the example directory: `cd example`
3. Run peanut: `peanut`
4. Push the newly updated `gh-pages` branch to github: 
   `git push origin --set-upstream gh-pages`

### Use as a binary

You can compile the binary buy running `dart2native bin/unsure.dart`. Then,
call the binary with a formula, like this:

    $ ./unsure "10~20 * 42"

![An animated gif of the binary in action](https://user-images.githubusercontent.com/919717/77241570-1a216100-6bb1-11ea-8e9d-e10b1aaf2106.gif)

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

### Help needed

There's only so much I (Filip) can do myself. If this is ever going to be
a truly open source project, I need to remove myself from a lot of the
ownership of this thing. 

* Can you help me publish the CLI binary to popular repositories such as
  APT, Homebrew, or Nugget? I know how to compile the tool on each platform,
  but I don't know what to do next.
* Can you come up with more interesting use case or formula, and write 
  an article about it? The companion article at 
  [filiph.github.io/unsure][webapp] is already too long.
* Similarly, can you record a video tutorial explaining the use of this tool?
* Can you help me automate the creation of binaries for each release, for each
  platform? I hear GitHub actions is the way to do it, but I've never done it.
* If you're familiar with `package:petitparser`, can you help me rewrite the
  formula parser so it's more helpful? In particular, I'd like it to give
  more helpful feedback to the user.
* Can you help me automate test coverage reporting?
* Can you help me make the [Unsure Calculator site][webapp] into 
  a true Progressive Web App?
* Can you help me put the range (`~`) notation into more calculators out there?

If you're interested in helping, please see if there's
[an issue](https://github.com/filiph/unsure/issues) you might assign to
yourself, and if not, create it.


### Language

I've done some research on what people generally mean when they say things like
"certainly" in regular speech. This might be useful when talking about
probabilities with untrained statisticians (such as myself).

| Noun | Adverb | Percentage | Sigma |
| -----| ------ | ---------- | ----- |
| All | Certainly | 100 % | - |
| Almost all | Almost certainly | 95 % | 2 |
| Large majority | Quite possibly | 68 % | 1 |
| Bare majority | Possibly | 50+ % | - |


[webapp]: https://filiph.github.io/unsure
[Build Status - Cirrus]: https://api.cirrus-ci.com/github/filiph/unsure.svg
[Build status]: https://cirrus-ci.com/github/filiph/unsure/master