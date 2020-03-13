import 'dart:math';

import 'package:unsure/uncertainty.dart';

void main() {
  testingSimple();
}

void testingAreaEstimate() {
  // Area of my room.
  var a = Range(3, 4);
  var b = Range(1.5, 2.5);

  var calc = Calculation(() => a.next() * b.next());

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);
}

void testingDivision() {
  // We are splitting a thousand dollars between 3 to 5 people.
  const amount = 1000;
  var people = Range(10, 15);

  var calc = Calculation(() => amount / people.next());

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);
  print('Mean: ${result.statistic.mean}');
}

void testingInterest() {
  // An investment.
  var principal = 1000;
  var interestRate = Range(2, 4);
  var time = Range(10, 12);

  var calc = Calculation(
      () => principal * (1 + interestRate.next() / 100) * time.next());

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);
}

void testingLottery() {
  // Shared.
  const years = 20;
  const yearlyContribution = 1200; // 100 CZK per month

  // Lottery.
  var lotteryWinProbability = Range(1 / 13983816 * 0.8, 1 / 13983816 * 1.2);
  var lotteryWinAmount = 1000000;

  // Savings account.
  var interest = Range(0, 0.01);

  var calc = Calculation(() {
    var atLeastOneWin = 1 - pow(1 - lotteryWinProbability.next(), years * 12);
    var lottery = lotteryWinAmount * atLeastOneWin;

    var z = (1 + interest.next());
    var balance = yearlyContribution * ((pow(z, years + 1) - z) / (z - 1));

    return balance - lottery;
  });

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);

  const prob = 85;
  print('$prob% ^: ${result.confidences[prob].upper * 100} %');
  print('$prob% v: ${result.confidences[prob].lower * 100} %');
}

void testingPlan() {
  // We think that a project will take 2-3 weeks to set up,
  // 10-20 weeks to build, and 1-2 weeks to wrap up.
  var setup = Range(2, 3);
  var build = Range(10, 20);
  var wrapUp = Range(1, 2);

  var calc = Calculation(() => setup.next() + build.next() + wrapUp.next());

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);
  print('Mean: ${result.statistic.mean}');

  print('\nCompare with the naive approach, '
      'where we take minimums and maximums and just combine them:');
  var naiveBestCase = setup.minimum + build.minimum + wrapUp.minimum;
  var naiveWorstCase = setup.maximum + build.maximum + wrapUp.maximum;
  print('   Between $naiveBestCase and $naiveWorstCase weeks.');
  print('Even in the case of simple addition, you get slightly different '
      'results. And of course the naive case doesn\'t give you '
      'any idea of the distribution.');
}

void testingProbability() {
  // Probability of dying from the corona virus

  var morbidity = Range(0.1, 0.7);
  var mortality = Range(0.002, 0.02);

  var calc = Calculation(() => morbidity.next() * mortality.next());

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);

  const prob = 85;
  print('$prob% ^: ${result.confidences[prob].upper * 100} %');
  print('$prob% v: ${result.confidences[prob].lower * 100} %');
}

void testingSimple() {
  const c = 2;
  var u = Range(1.9, 2.1);

  var calc = Calculation(() => c + u.next());

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[68]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);
  print(result.confidences[95].lower.toStringAsFixed(1) +
      '~' +
      result.confidences[95].upper.toStringAsFixed(1));
  print('Mean: ${result.statistic.mean}');
}

void testingSpeed() {
  // A car going by.
  var distance = Range(100, 120);
  var time = Range(3, 4);

  var calc = Calculation(() => distance.next() / time.next() * 3.6);

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);
}

void testingTrigonometry() {
  // Trigonometry
  var distance = Range(900, 1100);
  var angle = Range(10, 20);

  // tan(theta) = opposite / adjacent
  // therefore:
  // opposite = tan(theta) * adjacent

  var calc = Calculation(() => tan(angle.next() / 180 * pi) * distance.next());

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);
}

/// Computes the following formula with uncertainty:
///
/// > (n / m) * (r ^ t)
///
/// This happens to be a simplified, back-of-a-napkin formula for
/// guessing current spread of a deadly disease, given:
///
/// * _n_ - the number of reported deaths
/// * _m_ - the predicted mortality rate
/// * _r_ - the predicted rate of spread per unit of time
/// * _t_ - the predicted time from contracting a disease to death
/// * _n / m_ is therefore the number of ill individuals _t_ ago
void testingVirusSpread() {
  var n = Range(1, 2);
  var m = Range(0.01, 0.03);
  var r = Range(1.5, 1.6);
  var t = Range(2, 4);

  var calc = Calculation(() {
    var nc = n.next();
    var mc = m.next();
    //print('n = $nc, m = $mc');
    var cases = nc / mc;
    //print('cases = $cases');
    var rc = r.next();
    //print('rate of spread = $rc');
    var tc = t.next();
    //print('time units = $tc');
    var multiplication = pow(rc, tc);
    //print('exp = $exponent');
    var current = cases * multiplication;
    //print('===> $current');
    return current;
  });

  var result = calc.run();

  print(result);
  print(result.histogram);
  print(result.confidences[0]);
  print(result.confidences[1]);
  print(result.confidences[50]);
  print(result.confidences[90]);
  print(result.confidences[95]);
  print(result.confidences[99]);
  print(result.confidences[100]);
}
