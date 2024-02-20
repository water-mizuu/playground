import "../shared.dart";
import "real_math.dart" as r_math;

final r_math.Random _random = r_math.Random.secure();

const Quaternion pi = Quaternion.from(r_math.pi);
const Quaternion e = Quaternion.from(r_math.e);
final Quaternion phi = Quaternion.from(r_math.phi);

Quaternion log(Quaternion q) {
  /// Credits: https://math.stackexchange.com/questions/2552/the-logarithm-of-quaternion

  num s = q.real;
  num norm = q.abs().real;
  num vectorNorm = q.vectorNorm;
  num angle = r_math.acos(s / norm);

  if (vectorNorm == 0) {
    num absoluteSquared = q.absSquared();
    num real = 0.5 * r_math.log(absoluteSquared);
    num imaginary = angle;

    return Quaternion(real, imaginary, 0, 0);
  } else {
    num imaginaryScalar = (1 / vectorNorm) * angle;

    num real = r_math.log(norm);
    num imaginaryI = imaginaryScalar * q.imaginaryI;
    num imaginaryJ = imaginaryScalar * q.imaginaryJ;
    num imaginaryK = imaginaryScalar * q.imaginaryK;

    return Quaternion(real, imaginaryI, imaginaryJ, imaginaryK);
  }
}

Quaternion exp(Quaternion q) {
  /// Credits: https://math.stackexchange.com/questions/1030737/exponential-function-of-quaternion-derivation

  num vectorNorm = q.vectorNorm;
  if (vectorNorm == 0) {
    num real = r_math.exp(q.real);

    return Quaternion(real, 0, 0, 0);
  } else {
    num scalar = r_math.exp(q.real);
    num realScalar = r_math.cos(vectorNorm);
    num imaginaryScalar = r_math.sin(vectorNorm) / vectorNorm;

    num real = scalar * realScalar;
    num imaginaryI = scalar * q.imaginaryI * imaginaryScalar;
    num imaginaryJ = scalar * q.imaginaryJ * imaginaryScalar;
    num imaginaryK = scalar * q.imaginaryK * imaginaryScalar;

    return Quaternion(real, imaginaryI, imaginaryJ, imaginaryK);
  }
}

Quaternion pow(Quaternion q, Quaternion exponent) => q == 0.w
    ? q
    : exponent == 0.w
        ? 1.w
        : exp(log(q) * exponent);
Quaternion rpow(Quaternion q, Quaternion exponent) => q == 0.w
    ? q
    : exponent == 0.w
        ? 1.w
        : exp(exponent * log(q));

Quaternion randomDouble() => Quaternion(
      _random.nextDouble(),
      _random.nextDouble(),
      _random.nextDouble(),
      _random.nextDouble(),
    );
Quaternion randomInt(
  int realMax, [
  int? imaginaryIMax,
  int? imaginaryJMax,
  int? imaginaryKMax,
]) =>
    Quaternion(
      _random.nextInt(realMax),
      _random.nextInt(imaginaryIMax ??= realMax),
      _random.nextInt(imaginaryJMax ??= imaginaryIMax),
      _random.nextInt(imaginaryKMax ??= imaginaryJMax),
    );
