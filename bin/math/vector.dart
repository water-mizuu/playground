import "shared.dart";

export "shared.dart";

part "parts/vector/numerical_vector.dart";

class Vector<E> {
  final List<E> data;

  const Vector(this.data);

  Vector<E> subvector({int top = 0, int bottom = 0}) =>
      Vector<E>(<E>[for (int y = top; y < data.length - bottom; y++) data[y]]);

  int get degree => data.length;

  E operator [](int index) => data[index];
  void operator []=(int index, E val) => data[index] = val;

  @override
  String toString() => "<${data.join(", ")}>";

  String toMatrixString() {
    const int horizontalLength = 1;

    List<String> components = data.map((E v) => "$v").toList();
    int maxLength = components.map((String v) => v.length).max();

    List<String> padded = components.map((String v) => "${" " * (maxLength - v.length)}$v").toList();
    StringBuffer buffer = StringBuffer();

    int fullWidth = maxLength * horizontalLength + 2;

    buffer
      ..write("┌")
      ..write(" " * fullWidth)
      ..writeln("┐");

    for (String value in padded) {
      buffer.write("│");

      StringBuffer rowBuffer = StringBuffer();
      rowBuffer.write(value);
      String row = rowBuffer.toString().padCenter(fullWidth);

      buffer
        ..write(row)
        ..writeln("│");
    }

    buffer
      ..write("└")
      ..write(" " * fullWidth)
      ..writeln("┘");

    return buffer.toString();
  }
}
