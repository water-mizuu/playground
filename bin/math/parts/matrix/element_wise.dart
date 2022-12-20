part of "../../matrix.dart";

class ElementWiseNumericalMatrixProxy extends Iterable<Scalar> {
  final NumericalMatrix parent;

  ElementWiseNumericalMatrixProxy(this.parent);

  Iterable<Scalar> get _iterable sync* {
    for (List<Scalar> row in parent.data) {
      yield* row;
    }
  }

  @override
  Iterator<Scalar> get iterator => _iterable.iterator;

  NumericalMatrix operator +(Scalar right) => parent.matrixMap((left) => left + right);
  NumericalMatrix operator -(Scalar right) => parent.matrixMap((left) => left - right);
  NumericalMatrix operator /(Scalar right) => parent.matrixMap((left) => left / right);
  NumericalMatrix operator *(Scalar right) => parent.matrixMap((left) => left * right);
  NumericalMatrix operator %(Scalar right) => parent.matrixMap((left) => left % right);
  NumericalMatrix operator ~/(Scalar right) => parent.matrixMap((left) => left ~/ right);
}
