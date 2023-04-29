import "dart:math" as math;

import "matrix.dart";
import "vector.dart";

export "matrix.dart";
export "numbers/complex.dart";
export "numbers/fraction.dart";
export "numbers/number_like.dart";
export "numbers/quaternion.dart";
export "vector.dart";

typedef ComplexMember = num;
typedef Scalar = Complex;
typedef NumericalVector = Vector<Scalar>;
typedef NumericalMatrix = Matrix<Scalar>;

extension IntegerListExtension on Iterable<int> {
  num mean() => sum() / length;

  int sum() => fold(0, (int a, int b) => a + b);
  int product() => fold(1, (int a, int b) => a * b);

  int max() => reduce(math.max);
  int min() => reduce(math.min);

  String get sup {
    const String table = "⁰¹²³⁴⁵⁶⁷⁸⁹";
    List<String> chars = toString().split("");

    return chars.map(int.parse).map((int i) => table[i]).join();
  }

  String get sub {
    const String table = "₀₁₂₃₄₅₆₇₈₉";
    List<String> chars = toString().split("");

    return chars.map(int.parse).map((int i) => table[i]).join();
  }
}

extension ScalarListExtension on Iterable<Scalar> {
  Scalar mean() => sum() / Scalar.from(length);

  Scalar sum() => fold(Scalar.from(0), (Scalar a, Scalar b) => a + b);
  Scalar product() => fold(Scalar.from(1), (Scalar a, Scalar b) => a * b);

  Scalar max() => reduce((Scalar a, Scalar b) => a > b ? a : b);
  Scalar min() => reduce((Scalar a, Scalar b) => a < b ? a : b);
}

extension StringPadExtension on String {
  String padCenter(int value, [String padding = " "]) {
    int padCount = (value - length).clamp(0, math.max(length, value));
    int left = (padCount / 2).ceil();
    int right = (padCount / 2).floor();

    return "${padding * left}$this${padding * right}";
  }
}

extension IterableExtension on int {
  Iterable<int> to(int end) sync* {
    for (int i = this; i < end; i++) {
      yield i;
    }
  }
}
