import "dart:math" as math;

import "number_like.dart";

part "../parts/numbers/fraction/fraction_nan.dart";

class Fraction extends NumberLike<Fraction> {
  factory Fraction(BigInt numerator, [BigInt? denominator]) {
    denominator ??= BigInt.one;

    if (denominator == BigInt.zero) {
      return Fraction.nan;
    }

    BigInt gcf = _computeGcf(numerator, denominator);

    return Fraction._(numerator ~/ gcf, denominator ~/ gcf);
  }
  factory Fraction.fromInts(int numerator, [int denominator = 1]) => Fraction._(numerator.n, denominator.n);
  factory Fraction.from(num value, [num error = 1e-9]) {
    int base = value.floor();
    num decimal = value - base;

    if (decimal < error) {
      return Fraction.fromInts(base);
    } else if (1 - error < decimal) {
      return Fraction.fromInts(base + 1);
    }

    int lowerN = 0;
    int lowerD = 1;
    int upperN = 1;
    int upperD = 1;
    for (;;) {
      int middleN = lowerN + upperN;
      int middleD = lowerD + upperD;

      if (middleD * (decimal + error) < middleN) {
        upperN = middleN;
        upperD = middleD;
      } else if (middleN < (decimal - error) * middleD) {
        lowerN = middleN;
        lowerD = middleD;
      } else {
        return Fraction.fromInts(base * middleD + middleN, middleD);
      }
    }
  }
  const Fraction._(this.numerator, this.denominator);
  static final Fraction zero = Fraction(BigInt.zero);
  static final Fraction one = Fraction(BigInt.one);
  static final Fraction two = Fraction(BigInt.two);
  static final Fraction nan = _NotAFraction();

  static BigInt _euclidGcf(BigInt big, BigInt small) {
    BigInt b = big;
    BigInt s = small;

    while (s != BigInt.zero) {
      BigInt temp = s;
      s = b % s;
      b = temp;
    }
    return b;
  }

  static BigInt _computeGcf(BigInt left, BigInt right) {
    if (left == BigInt.zero && right == BigInt.zero) {
      return BigInt.one;
    }

    BigInt leftAbs = left.abs();
    BigInt rightAbs = right.abs();

    BigInt big = leftAbs > rightAbs ? leftAbs : rightAbs;
    BigInt small = leftAbs > rightAbs ? rightAbs : leftAbs;

    return _euclidGcf(big, small);
  }

  final BigInt numerator;
  final BigInt denominator;

  @override
  Fraction abs() {
    BigInt numerator = this.numerator.abs();
    BigInt denominator = this.denominator.abs();

    return Fraction(numerator, denominator);
  }

  @override
  Fraction add(Fraction other) {
    /// (a / b) + (c / d) = (ad + bc) / (cd)

    BigInt numerator = this.numerator * other.denominator + other.numerator * this.denominator;
    BigInt denominator = this.denominator * other.denominator;

    return Fraction(numerator, denominator);
  }

  @override
  Fraction get additiveInverse => Fraction(-numerator, denominator);

  @override
  Fraction ceil() {
    BigInt remainder = this.numerator.remainder(this.denominator);
    BigInt decimal = (remainder / this.denominator).ceil().toBigInt();

    BigInt numerator = decimal + this.numerator ~/ this.denominator;
    BigInt denominator = 1.n;

    return Fraction(numerator, denominator);
  }

  @override
  Fraction collapse() {
    const double threshold0 = 1000000000;
    BigInt threshold = threshold0.n;
    // If the numbers get too large, be willing to lose some accuracy.

    if (this.numerator.abs() < threshold || this.denominator.abs() < threshold) {
      return this;
    }

    BigInt numerator = this.numerator.abs();
    BigInt denominator = this.denominator.abs();
    while (numerator.abs() >= threshold || denominator.abs() >= threshold) {
      numerator = (numerator ~/ threshold) + (numerator.remainder(threshold) == 0.n ? 1.n : 0.n);
      denominator = (denominator ~/ threshold) + (denominator.remainder(threshold) == 0.n ? 1.n : 0.n);
    }

    return Fraction(numerator, denominator);
  }

  @override
  Fraction get collapsed => collapse();

  @override
  int compareTo(Fraction other) {
    /// Normally it should be compared by the difference of the fractions.
    /// i.e compare(a / b , c / d) = (ad - bc)/(bd).
    /// However, only the sign matters, so we can discard the product denominator `bd`.

    return (numerator * other.denominator - other.numerator * denominator).toInt();
  }

  @override
  Fraction divide(Fraction other) {
    /// (a / b) ÷ (c / d) = ad / bc

    BigInt numerator = this.numerator * other.denominator;
    BigInt denominator = this.denominator * other.numerator;

    return Fraction(numerator, denominator);
  }

  @override
  Fraction floor() {
    BigInt remainder = this.numerator.remainder(this.denominator);
    BigInt decimal = (remainder / this.denominator).floor().toBigInt();

    BigInt numerator = decimal + this.numerator ~/ this.denominator;
    BigInt denominator = 1.n;

    return Fraction(numerator, denominator);
  }

  @override
  Fraction floorDivide(Fraction other) {
    /// (a / b) ÷ (c / d) = ad / bc

    BigInt numerator = this.numerator * other.denominator;
    BigInt denominator = this.denominator * other.numerator;

    return Fraction(numerator ~/ denominator, 1.n);
  }

  @override
  bool isEqualTo(Fraction other) => numerator == other.numerator && denominator == other.denominator;

  @override
  bool get isNaN => false;

  @override
  Fraction modulo(Fraction other) {
    /// x % 0 = x
    /// x % y = x - y * floor(x / y)

    if (other.reduced == 0.f) {
      return reduced;
    }

    return this - other * (this ~/ other);
  }

  @override
  Fraction get multiplicativeInverse => denominator == 0.n //
      ? throw StateError("Division by zero")
      : Fraction(denominator, numerator);

  @override
  Fraction multiply(Fraction other) {
    /// (a / b) * (c / d) = ac / bd

    BigInt numerator = this.numerator * other.numerator;
    BigInt denominator = this.denominator * other.denominator;

    return Fraction(numerator, denominator);
  }

  @override
  Fraction normalize() => collapsed;

  @override
  Fraction get normalized => collapsed;

  @override
  Fraction pow(Fraction other) {
    num result = math.pow(collapsed.value, other.collapsed.value);
    if (result.isInfinite) {
      throw Exception(":< It's too large");
    }

    return Fraction.from(result);
  }

  Fraction get reduced {
    BigInt gcf = _computeGcf(numerator, denominator);
    BigInt sign = denominator.isNegative ? -1.n : 1.n;

    return Fraction(sign * numerator ~/ gcf, sign * denominator ~/ gcf);
  }

  BigInt get remainder => numerator.remainder(denominator);

  @override
  Fraction round() {
    BigInt remainder = this.numerator.remainder(this.denominator);
    BigInt decimal = (remainder / this.denominator).round().toBigInt();

    BigInt numerator = decimal + this.numerator ~/ this.denominator;
    BigInt denominator = 1.n;

    return Fraction(numerator, denominator);
  }

  @override
  Fraction get sign => value > 0 ? 1.f : -1.f;

  @override
  String get str => strRat;

  @override
  String get strLong => value.toStringAsFixed(12);

  @override
  String get strRat => denominator == 1.n ? "$numerator" : "$numerator/$denominator";

  @override
  String get strShort => value.toStringAsFixed(4);

  int toInt() => truncated().toInt();

  BigInt truncated() => numerator ~/ denominator;

  @override
  Fraction subtract(Fraction other) {
    /// (a / b) - (c / d) = (ad - bc) / (cd)

    BigInt numerator = this.numerator * other.denominator - other.numerator * this.denominator;
    BigInt denominator = this.denominator * other.denominator;

    return Fraction(numerator, denominator);
  }

  num get value {
    if (numerator.bitLength < 128 && denominator.bitLength < 128) {
      return numerator / denominator;
    }

    BigInt boost = 10.n.pow(64);
    BigInt augmented = numerator * boost ~/ denominator;

    return (augmented ~/ boost).toInt() + (augmented % boost) / boost;
  }
}

extension BigIntNumExtension on num {
  BigInt toBigInt() => BigInt.from(this);
  BigInt get n => toBigInt();

  Fraction toFraction() => Fraction.from(this);
  Fraction get f => toFraction();
}

extension FractionBigIntExtension on BigInt {
  Fraction toFraction() => Fraction(this, 1.n);
  Fraction get f => toFraction();
}
