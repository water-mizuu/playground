import "../functions/complex_math.dart" as c_math;
import "../functions/real_math.dart" as r_math;
import "../shared.dart";

class Complex extends NumberLike<Complex> {
  static const Complex zero = Complex(0, 0);
  static const Complex one = Complex(1, 0);
  static const Complex two = Complex(2, 0);
  static const Complex nan = Complex(double.nan, double.nan);

  final ComplexMember real;
  final ComplexMember imaginary;

  const Complex(this.real, this.imaginary);
  const Complex.fromNum(this.real, this.imaginary);
  const Complex.from(this.real) : imaginary = 0;
  const Complex.imaginaryFrom(this.imaginary) : real = 0;

  // Knowing how fractions work, this seems like it'll be a nightmare. :(
  ComplexMember absSquared() => real.pow(2) + imaginary.pow(2);

  @override
  Complex abs() => Complex(absSquared().pow(0.5), 0);

  @override
  Complex add(Complex other) => Complex(real + other.real, imaginary + other.imaginary);

  @override
  Complex get additiveInverse => Complex(-real, -imaginary);

  num get argument => r_math.atan2(imaginary, real);

  @override
  Complex ceil() => Complex(real.ceil(), imaginary.ceil());

  @override
  Complex collapse() => collapsed;

  @override
  Complex get collapsed => Complex(real.collapsed, imaginary.collapsed);

  @override
  int compareTo(Complex other) => projection.compareTo(other.projection);

  @override
  Complex divide(Complex other) {
    /// (a + bi)/(c + di)
    ///   = (a + bi)(c - di)/(c² + d²)
    ///   = (ac + bci - adi - bdi²)/(c² + d²)
    ///   = (ac + bci - adi + bd)/(c² + d²)
    ///   = [(ac + bd) + (bc - ad) i]/(c² + d²)
    ///   = (ac + bd)/(c² + d²) + (bc - ad)/(c² + d²) i
    ComplexMember denominator = other.real.pow(2) + other.imaginary.pow(2);
    ComplexMember real = (this.real * other.real + this.imaginary * other.imaginary) / denominator;
    ComplexMember imaginary = (this.imaginary * other.real - this.real * other.imaginary) / denominator;

    return Complex(real, imaginary);
  }

  @override
  Complex floor() => Complex(real.floor(), imaginary.floor());

  @override
  Complex floorDivide(Complex other) => divide(other).floor();

  Complex get inverseConjugate => Complex(real, -imaginary);

  @override
  bool isEqualTo(Complex other) => real == other.real && imaginary == other.imaginary;

  @override
  bool get isNaN => real.isNaN || imaginary.isNaN;

  @override
  Complex modulo(Complex other) {
    /// (a + bi) % (c + di)
    ///     = (a + bi) + (c + di)⌈-(a + bi)/(c + di)⌉
    ///     = α + β
    /// α = this
    /// β = other * ceil(-self/other)

    return this + other * (-this / other).ceil();
  }

  @override
  Complex get multiplicativeInverse {
    ComplexMember denominator = this.real.pow(2) + this.imaginary.pow(2);
    ComplexMember real = this.real / denominator;
    ComplexMember imaginary = -(this.imaginary / denominator);

    return Complex(real, imaginary);
  }

  @override
  Complex multiply(Complex other) {
    /// (a + bi)(c + di)
    ///   = ac + bci + adi + bdi²
    ///   = ac + bci + adi - bd
    ///   = (ac - bd) + (ad + bc) i
    ComplexMember real = this.real * other.real - this.imaginary * other.imaginary;
    ComplexMember imaginary = this.real * other.imaginary + this.imaginary * other.real;

    return Complex(real, imaginary);
  }

  @override
  Complex normalize() => this;

  @override
  Complex get normalized => normalize();

  @override
  Complex pow(Complex other) => c_math.pow(this, other);

  ComplexMember get projection => abs().real * real.sign;

  @override
  Complex round() => Complex(real.round(), imaginary.round());

  @override
  Complex get sign => this == 0.re ? 1.re : this / abs();

  String _writeToString(String Function(ComplexMember) function) {
    StringBuffer buffer = StringBuffer();
    ComplexMember absW = real * real.sign;
    ComplexMember absI = imaginary * imaginary.sign;

    if (absW > 0) {
      buffer
        ..write(buffer.isNotEmpty ? (real < 0 ? " - " : " + ") : (real < 0 ? "-" : ""))
        ..write(function(absW));
    }
    if (absI > 0) {
      buffer
        ..write(buffer.isNotEmpty ? (imaginary < 0 ? " - " : " + ") : (imaginary < 0 ? "-" : ""))
        ..write(function(absI))
        ..write(" i");
    }

    if (buffer.isEmpty) {
      return function(0);
    }

    return buffer.toString();
  }

  @override
  String get str => _writeToString((v) => v.toString());

  @override
  String get strLong => collapsed._writeToString((v) => v.strLong);

  @override
  String get strRat => collapsed._writeToString((v) => v.strRat);

  @override
  String get strShort => collapsed._writeToString((v) => v.strShort);

  @override
  Complex subtract(Complex other) => Complex(real - other.real, imaginary - other.imaginary);
}

extension ComplexNumExtension on num {
  num pow(num exponent) => r_math.pow(this, exponent);
  num fix([double error = 1e-9]) => rationalize(error).value;

  num get collapsed => fix();
  String get strLong => toStringAsFixed(16);
  String get strShort => toStringAsFixed(4);
  String get strRat => rationalized.strRat;

  Fraction get rationalized => rationalize();
  Fraction rationalize([double error = 1e-9]) {
    if (isNaN) {
      return Fraction(1.n, 0.n);
    }

    int base = floor();
    num decimal = this - base;

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
}

extension ComplexFractionExtension on ComplexMember {
  Complex get c => Complex.from(this);
  Complex get ci => Complex.imaginaryFrom(this);

  Complex get re => c;
  Complex get im => ci;
}
