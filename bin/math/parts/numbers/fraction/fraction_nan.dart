part of "../../../numbers/fraction.dart";

// ignore: avoid_implementing_value_types
class _NotAFraction extends NumberLike<Fraction> implements Fraction {
  Never _conversionError() {
    throw UnsupportedError("Unsupported operation: Infinity or NaN toInt");
  }

  @override
  Fraction abs() => this;

  @override
  Fraction add(Fraction other) => this;

  @override
  Fraction get additiveInverse => this;

  @override
  Fraction ceil() => _conversionError();
  @override
  Fraction collapse() => this;

  @override
  Fraction get collapsed => this;

  @override
  int compareTo(Fraction other) => other.isNaN ? 0 : 1;

  @override
  BigInt get denominator => _conversionError();

  @override
  Fraction divide(Fraction other) => this;

  @override
  Fraction floor() => _conversionError();

  @override
  Fraction floorDivide(Fraction other) => _conversionError();

  @override
  bool isEqualTo(Fraction other) => false;

  @override
  bool get isNaN => true;

  @override
  Fraction modulo(Fraction other) => this;

  @override
  Fraction get multiplicativeInverse => this;

  @override
  Fraction multiply(Fraction other) => this;

  @override
  Fraction normalize() => this;

  @override
  Fraction get normalized => this;

  @override
  BigInt get numerator => _conversionError();

  @override
  Fraction pow(Fraction other) => this;

  @override
  Fraction get reduced => this;

  @override
  BigInt get remainder => _conversionError();

  @override
  Fraction round() => _conversionError();

  @override
  Fraction get sign => this;

  @override
  String get str => "NaN";

  @override
  String get strLong => "NaN/NaN";

  @override
  String get strRat => "NaN/NaN";

  @override
  String get strShort => "NaN/NaN";

  @override
  Fraction subtract(Fraction other) => this;

  @override
  BigInt truncated() => _conversionError();

  @override
  int toInt() => _conversionError();

  @override
  num get value => double.nan;
}
