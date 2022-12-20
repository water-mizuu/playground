part of "../../vector.dart";

extension NumericalVectorMethods on NumericalVector {
  static NumericalVector ones(int width) => Vector([for (int x = 0; x < width; ++x) 1.c]);
  static NumericalVector zeros(int width) => Vector([for (int x = 0; x < width; ++x) 0.c]);

  NumericalVector scale(Scalar scalar) => Vector([for (Scalar val in data) val * scalar]);

  NumericalVector add(NumericalVector other) {
    if (degree != other.degree) {
      throw ArgumentError("Cannot add two incompatible vectors. L:$degree; R:${other.degree}");
    }

    return Vector([for (int i = 0; i < degree; ++i) this[i] + other[i]]);
  }

  Scalar dot(NumericalVector other) {
    if (degree != other.degree) {
      throw ArgumentError("Cannot dot product two incompatible vectors. L:$degree; R:${other.degree}");
    }

    return [for (int i = 0; i < degree; ++i) this[i] * other[i]].sum();
  }

  Scalar get magnitude => (this * this).pow(0.5.re);

  NumericalVector operator +(NumericalVector other) => add(other);
  NumericalVector operator -(NumericalVector other) => add(other.additiveInverse);

  Scalar operator *(NumericalVector other) => dot(other);

  NumericalVector get additiveInverse => Vector([for (Scalar val in data) -val]);
}

extension NumericalVectorPostfixExtension<E extends num> on List<E> {
  Vector<Complex> get vec => Vector(this.map(Scalar.from).toList());
}

extension ComplexNumericalVectorPostfixExtension on List<Complex> {
  Vector<Complex> get vec => Vector(this.toList());
}
