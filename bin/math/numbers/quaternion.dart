import "../functions/real_math.dart" as rmath;
import "../matrix.dart";

class Quaternion extends NumberLike<Quaternion> {
  static const Quaternion zero = Quaternion(0, 0, 0, 0);
  static const Quaternion one = Quaternion(1, 0, 0, 0);
  static const Quaternion two = Quaternion(2, 0, 0, 0);
  static const Quaternion nan = Quaternion(double.nan, double.nan, double.nan, double.nan);

  static Quaternion rotate(Quaternion vector, Quaternion axis, num angle) {
    Quaternion normalizedAxis = axis.normalize();
    Quaternion rotationQuaternion = rmath.cos(angle / 2).w + rmath.sin(angle / 2).w * normalizedAxis;
    Quaternion inverseQuaternion = rmath.cos(-angle / 2).w + rmath.sin(-angle / 2).w * normalizedAxis;

    return rotationQuaternion * (vector * inverseQuaternion);
  }

  final ComplexMember real;
  final ComplexMember imaginaryI;
  final ComplexMember imaginaryJ;
  final ComplexMember imaginaryK;

  const Quaternion(this.real, this.imaginaryI, this.imaginaryJ, this.imaginaryK);
  const Quaternion.from(this.real)
      : imaginaryI = 0,
        imaginaryJ = 0,
        imaginaryK = 0;
  const Quaternion.imaginaryIFrom(this.imaginaryI)
      : real = 0,
        imaginaryJ = 0,
        imaginaryK = 0;
  const Quaternion.imaginaryJFrom(this.imaginaryJ)
      : real = 0,
        imaginaryI = 0,
        imaginaryK = 0;
  const Quaternion.imaginaryKFrom(this.imaginaryK)
      : real = 0,
        imaginaryI = 0,
        imaginaryJ = 0;

  ComplexMember imaginaryAbsSquared() => imaginaryI * imaginaryI + imaginaryJ * imaginaryJ + imaginaryK * imaginaryK;
  ComplexMember absSquared() => real * real + imaginaryAbsSquared();
  ComplexMember get norm => absSquared().pow(0.5);
  ComplexMember get vectorNorm => imaginaryAbsSquared().pow(0.5);

  @override
  Quaternion abs() => norm.q;

  @override
  Quaternion add(Quaternion other) {
    ComplexMember real = this.real + other.real;
    ComplexMember imaginaryI = this.imaginaryI + other.imaginaryI;
    ComplexMember imaginaryJ = this.imaginaryJ + other.imaginaryJ;
    ComplexMember imaginaryK = this.imaginaryK + other.imaginaryK;

    return Quaternion(real, imaginaryI, imaginaryJ, imaginaryK);
  }

  @override
  Quaternion get additiveInverse => Quaternion(-real, -imaginaryI, -imaginaryJ, -imaginaryK);

  @override
  Quaternion ceil() => Quaternion(real.ceil(), imaginaryI.ceil(), imaginaryJ.ceil(), imaginaryK.ceil());

  @override
  Quaternion collapse() => Quaternion(
        real.collapsed,
        imaginaryI.collapsed,
        imaginaryJ.collapsed,
        imaginaryK.collapsed,
      );

  @override
  Quaternion get collapsed => collapse();

  @override
  int compareTo(Quaternion other) => projection.compareTo(other.projection);

  Quaternion get conjugate => Quaternion(real, -imaginaryI, -imaginaryJ, -imaginaryK);

  @override
  Quaternion divide(Quaternion other) {
    Quaternion otherConjugate = Quaternion(other.real, -other.imaginaryI, -other.imaginaryJ, -other.imaginaryK);

    ComplexMember otherAbs = absSquared();
    ComplexMember conjugateReal = otherConjugate.real / otherAbs;
    ComplexMember conjugateImaginaryI = otherConjugate.imaginaryI / otherAbs;
    ComplexMember conjugateImaginaryJ = otherConjugate.imaginaryJ / otherAbs;
    ComplexMember conjugateImaginaryK = otherConjugate.imaginaryK / otherAbs;

    Quaternion otherMultiplicativeInverse = Quaternion(
      conjugateReal,
      conjugateImaginaryI,
      conjugateImaginaryJ,
      conjugateImaginaryK,
    );

    ComplexMember a1 = this.real;
    ComplexMember a2 = otherMultiplicativeInverse.real;
    ComplexMember b1 = this.imaginaryI;
    ComplexMember b2 = otherMultiplicativeInverse.imaginaryI;
    ComplexMember c1 = this.imaginaryJ;
    ComplexMember c2 = otherMultiplicativeInverse.imaginaryJ;
    ComplexMember d1 = this.imaginaryK;
    ComplexMember d2 = otherMultiplicativeInverse.imaginaryK;

    ComplexMember real = a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2;
    ComplexMember imaginaryI = a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2;
    ComplexMember imaginaryJ = a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2;
    ComplexMember imaginaryK = a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2;

    return Quaternion(real, imaginaryI, imaginaryJ, imaginaryK);
    // return this * other.multiplicativeInverse;
  }

  @override
  Quaternion floor() => Quaternion(real.floor(), imaginaryI.floor(), imaginaryJ.floor(), imaginaryK.floor());

  @override
  Quaternion floorDivide(Quaternion other) => divide(other).floor();

  @override
  bool isEqualTo(Quaternion other) =>
      real == other.real &&
      imaginaryI == other.imaginaryI &&
      imaginaryJ == other.imaginaryJ &&
      imaginaryK == other.imaginaryK;

  @override
  bool get isNaN => real.isNaN || imaginaryI.isNaN || imaginaryJ.isNaN || imaginaryK.isNaN;

  @override
  Quaternion modulo(Quaternion other) {
    return this + other * (-this / other).ceil();
  }

  @override
  // q^-1 = q'/(q*q')
  //      = q'/|q|
  Quaternion get multiplicativeInverse {
    Quaternion conjugate = this.conjugate;

    ComplexMember abs = absSquared();
    ComplexMember real = conjugate.real / abs;
    ComplexMember imaginaryI = conjugate.imaginaryI / abs;
    ComplexMember imaginaryJ = conjugate.imaginaryJ / abs;
    ComplexMember imaginaryK = conjugate.imaginaryK / abs;

    return Quaternion(real, imaginaryI, imaginaryJ, imaginaryK);
  }

  @override
  Quaternion multiply(Quaternion other) {
    ComplexMember a1 = this.real;
    ComplexMember a2 = other.real;
    ComplexMember b1 = this.imaginaryI;
    ComplexMember b2 = other.imaginaryI;
    ComplexMember c1 = this.imaginaryJ;
    ComplexMember c2 = other.imaginaryJ;
    ComplexMember d1 = this.imaginaryK;
    ComplexMember d2 = other.imaginaryK;

    ComplexMember real = a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2;
    ComplexMember imaginaryI = a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2;
    ComplexMember imaginaryJ = a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2;
    ComplexMember imaginaryK = a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2;

    return Quaternion(real, imaginaryI, imaginaryJ, imaginaryK);
  }

  @override
  Quaternion normalize() {
    num magnitude = abs().real;

    return Quaternion(
      real / magnitude,
      imaginaryI / magnitude,
      imaginaryJ / magnitude,
      imaginaryK / magnitude,
    );
  }

  @override
  Quaternion get normalized => normalize();

  ComplexMember get projection => abs().real * real.sign;

  @override
  Quaternion pow(Quaternion other) {
    throw UnimplementedError();
  }

  @override
  Quaternion round() => Quaternion(real.round(), imaginaryI.round(), imaginaryJ.round(), imaginaryK.round());

  @override
  Quaternion get sign => this / abs();

  String _writeToString(String Function(ComplexMember) function) {
    StringBuffer buffer = StringBuffer();
    ComplexMember absW = real * real.sign;
    ComplexMember absI = imaginaryI * imaginaryI.sign;
    ComplexMember absJ = imaginaryJ * imaginaryJ.sign;
    ComplexMember absK = imaginaryK * imaginaryK.sign;

    if (absW > 0) {
      buffer
        ..write((real < 0) ? " - " : "")
        ..write(function(absW));
    }
    if (absI > 0) {
      buffer
        ..write(buffer.isNotEmpty ? (imaginaryI < 0 ? " - " : " + ") : (imaginaryI < 0 ? "-" : ""))
        ..write(function(absI))
        ..write(" i");
    }
    if (absJ > 0) {
      buffer
        ..write(buffer.isNotEmpty ? (imaginaryJ < 0 ? " - " : " + ") : (imaginaryJ < 0 ? "-" : ""))
        ..write(function(absJ))
        ..write(" j");
    }
    if (absK > 0) {
      buffer
        ..write(buffer.isNotEmpty ? (imaginaryK < 0 ? " - " : " + ") : (imaginaryK < 0 ? "-" : ""))
        ..write(function(absK))
        ..write(" k");
    }

    if (buffer.isEmpty) {
      return function(0);
    }

    return buffer.toString();
  }

  @override
  String get str => _writeToString((ComplexMember v) => v.toString());

  @override
  String get strLong => collapsed._writeToString((ComplexMember v) => v.strLong);

  @override
  String get strRat => collapsed._writeToString((ComplexMember v) => v.strRat);

  @override
  String get strShort => collapsed._writeToString((ComplexMember v) => v.strShort);

  @override
  Quaternion subtract(Quaternion other) {
    ComplexMember real = this.real - other.real;
    ComplexMember imaginaryI = this.imaginaryI - other.imaginaryI;
    ComplexMember imaginaryJ = this.imaginaryJ - other.imaginaryJ;
    ComplexMember imaginaryK = this.imaginaryK - other.imaginaryK;

    return Quaternion(real, imaginaryI, imaginaryJ, imaginaryK);
  }
}

extension QuaternionNumExtension on ComplexMember {
  Quaternion get q => Quaternion.from(this);
  Quaternion get qi => Quaternion.imaginaryIFrom(this);
  Quaternion get qj => Quaternion.imaginaryJFrom(this);
  Quaternion get qk => Quaternion.imaginaryKFrom(this);

  Quaternion get qre => q;
  Quaternion get imI => qi;
  Quaternion get imJ => qj;
  Quaternion get imK => qk;

  Quaternion get w => q;
  Quaternion get vi => qi;
  Quaternion get vj => qj;
  Quaternion get vk => qk;
}
