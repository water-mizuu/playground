import "dart:math" as r_math;

export "dart:math";

final r_math.Random _random = r_math.Random.secure();
final double phi = 0.5 * (1 + r_math.pow(5, 0.5));

double sinh(num x) => 0.5 * (r_math.exp(x) - r_math.exp(-x));
double cosh(num x) => 0.5 * (r_math.exp(x) + r_math.exp(-x));
double tanh(num x) {
  double posX = r_math.exp(x);
  double negX = r_math.exp(-x);

  return (posX - negX) / (posX + negX);
}

double randomDouble() => _random.nextDouble();
int randomInt(int max) => _random.nextInt(max);
