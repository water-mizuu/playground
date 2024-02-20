import "../shared.dart";
import "real_math.dart" as r_math;

final r_math.Random _random = r_math.Random.secure();

const Complex pi = Complex.from(r_math.pi);
const Complex e = Complex.from(r_math.e);
final Complex phi = Complex.from(r_math.phi);

/// Returns the principal log of [z].
Complex log(Complex z) {
  /// ln (a + bi) = ln(sqrt(a^2 + b^2)) + i*atan(b/a)
  /// ln (a + bi) = 0.5 ln (a^2 + b^2) + i * atan(b/a)

  num absoluteSquared = z.absSquared();
  num real = 0.5 * r_math.log(absoluteSquared);
  num imaginary = r_math.acos(z.real / r_math.pow(absoluteSquared, 0.5));

  return Complex(real, imaginary);
}

Complex exp(Complex z) {
  var Complex(real: num a, imaginary: num theta) = z;

  num gamma = r_math.exp(a);
  num real = gamma * r_math.cos(theta);
  num imaginary = gamma * r_math.sin(theta);

  return Complex(real, imaginary);
}

Complex sin(Complex z) {
  var Complex(real: num a, imaginary: num b) = z;
  num real = r_math.sin(a) * r_math.cosh(b);
  num imaginary = r_math.cos(a) * r_math.sinh(b);

  return Complex(real, imaginary);
}

Complex cos(Complex z) {
  var Complex(real: num a, imaginary: num b) = z;

  num real = r_math.cos(a) * r_math.cosh(b);
  num imaginary = r_math.sin(a) * r_math.sinh(b);

  return Complex(real, -imaginary);
}

Complex tan(Complex z) {
  var Complex(real: num a, imaginary: num b) = z;

  num denominator = r_math.cos(2 * a) + r_math.cosh(2 * b);
  num real = r_math.sin(2 * a) / denominator;
  num imaginary = r_math.sinh(2 * b) / denominator;

  return Complex(real, imaginary);
}

Complex sinh(Complex z) => 0.5.re * (exp(z) - exp(-z));
Complex cosh(Complex z) => 0.5.re * (exp(z) + exp(-z));
Complex tanh(Complex z) {
  Complex posX = exp(z);
  Complex negX = exp(-z);

  return (posX - negX) / (posX + negX);
}

Complex cis(Complex theta) {
  Complex real = cos(theta);
  Complex imaginary = sin(theta) * 1.im;

  return real + imaginary;
}

// credits: https://mathworld.wolfram.com/ComplexExponentiation.html
//   (╥﹏╥ )
//
// Since exp(z) and ln(z) are well defined,
//   we can use them instead.
Complex pow(Complex z, Complex exponent) => z == 0.re
    ? z
    : exponent == 0.re
        ? 1.re
        : exp(log(z) * exponent);

Iterable<Complex> rootsOfUnity(int degree, [Complex start = Complex.one]) sync* {
  double angle = 2 * r_math.pi / degree;
  for (int i = 0; i < degree; ++i) {
    yield start * exp(angle.im * i.re);
  }
}

Complex randomDouble() => Complex(_random.nextDouble(), _random.nextDouble());
Complex randomInt(int realMax, [int? imaginaryMax]) =>
    Complex(_random.nextInt(realMax), _random.nextInt(imaginaryMax ?? realMax));
