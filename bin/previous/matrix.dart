import "dart:math" as math;

typedef Matrix<T> = List<List<T>>;

extension VectorExtension<E extends num> on List<E> {
  num? operator *(List<num> right) => //
      0
          .to(math.min(length, right.length))
          .map((index) => this[index] * right[index])
          .reduce((value, element) => value + element);
}

extension IterableExtension on int {
  Iterable<int> to(int end) sync* {
    for (int i = this; i < end; i++) {
      yield i;
    }
  }
}

extension MatrixMethods<E> on Matrix<E> {
  Map<String, int> get dimensions => <String, int>{"x": horizontalLength, "y": verticalLength};

  Matrix<E> get columns => transpose();
  Matrix<E> get rows => this;

  Matrix<E> removeColumnsWhereEvery(bool Function(E) handler) => //
      transpose().removeRowsWhereEvery(handler).transpose();

  Matrix<E> removeRowsWhereEvery(bool Function(E) handler) => //
      where((item) => !item.every(handler)).toList();

  Matrix<E> submatrix({int top = 0, int bottom = 0, int left = 0, int right = 0}) => [
        for (int y = top; y < length - bottom; y++) //
          [for (int x = left; x < this[y].length - right; x++) this[y][x]]
      ];

  Matrix<E> removed({Set<int> x = const {}, Set<int> y = const {}}) => [
        for (int _y = 0; _y < verticalLength; _y++)
          if (!y.contains(_y))
            [
              for (int _x = 0; _x < horizontalLength; _x++)
                if (!x.contains(_x)) this[_y][_x]
            ]
      ];

  Matrix<E> transpose() => [
        for (int y = 0; y < verticalLength; y++) //
          [for (int x = 0; x < horizontalLength; x++) this[x][y]]
      ];

  Matrix<E> expandColumn(int at, List<E> Function(E element) handler, {E? filler}) {
    Matrix<E> expanded = [for (int i = 0; i < length; i++) handler(this[i][at])];
    Set<int> resultLengths = expanded.map((list) => list.length).toSet();
    if (filler == null && resultLengths.length > 1) {
      throw StateError("The resulting matrix shape is uneven and there was no filler provided.");
    }

    int max = resultLengths.reduce(math.max);
    Matrix<E> filled = [
      for (List<E> row in expanded)
        [
          ...row,
          if (filler != null)
            for (int i = row.length; i < max; i++) filler
        ]
    ];
    Matrix<E> matrix = [
      for (int i = 0; i < length; i++)
        [
          for (int j = 0; j < this[i].length; j++)
            if (j == at) ...filled[i] else this[i][j]
        ]
    ];

    return matrix;
  }

  // I got lazy lmao
  Matrix<E> expandRow(int index, List<E> Function(E element) handler, {E? filler}) =>
      transpose().expandColumn(index, handler, filler: filler).transpose();

  Matrix<E> mapColumn(int index, E Function(E element) handler) => [
        for (List<E> row in this)
          [
            for (int i = 0; i < row.length; i++)
              if (i == index) handler(row[i]) else row[i]
          ],
      ];

  Matrix<E> mapRow<R extends E>(int index, E Function(E element) handler) => [
        for (int i = 0; i < length; i++)
          [
            for (E item in this[i])
              if (i == index) handler(item) else item
          ],
      ];

  Matrix<R> matrixMap<R>(R Function(E element) handler) =>
      map((row) => row.map((item) => handler(item)).toList()).toList();

  int get verticalLength => length;
  int get horizontalLength => _safeLength;

  int get _safeLength => map((row) => row.length).reduce(math.min);

  String toMatrixString() => str;
  String toCsvString() => csv;

  String get str {
    List<int> profile = transpose() //
        .map((c) => c.map((i) => "$i".length).reduce(math.max))
        .toList();

    StringBuffer buffer = StringBuffer();
    for (List<String> row in matrixMap((e) => e.toString())) {
      for (int i = 0; i < row.length; i++) {
        buffer.write("${row[i]}${" " * (profile[i] - row[i].length)} ");
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  String get csv {
    List<int> profile = transpose() //
        .map((rows) => rows.map((c) => "$c".length).reduce(math.max))
        .toList();

    StringBuffer buffer = StringBuffer();
    for (List<E> row in this) {
      for (int i = 0; i < row.length; i++) {
        String cell = row[i].toString();
        String toWrite = i + 1 < row.length //
            ? "$cell${" " * (profile[i] - cell.length)},"
            : cell;

        buffer.write(toWrite);
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}

extension on num {
  num fix() => this < 1e-12
      ? 0
      : this - roundToDouble() < 1e-12
          ? roundToDouble()
          : this;
}

extension MathematicalMatrix<E extends num> on Matrix<E> {
  // This is O(n!). Change this to O(n^3) (LU Factorization) later.
  num? get determinant {
    if (verticalLength != horizontalLength) {
      return null;
    }

    if (verticalLength == 1) {
      return this[0][0];
    }

    num sum = 0;
    for (int x = 0; x < horizontalLength; x++) {
      Matrix<E> submatrix = removed(y: <int>{0}, x: <int>{x});
      num determinant = submatrix.determinant!;
      num multiplier = math.pow(-1, 0 /* row */ + x /* column */);
      num cell = this[0][x];

      sum += cell * multiplier * determinant;
    }

    return sum;
  }

  String get str {
    List<int> profile = transpose() //
        .map((c) => c.map((i) => "$i".length).reduce(math.max))
        .toList();

    StringBuffer buffer = StringBuffer();
    for (List<String> row in matrixMap((e) => "$e")) {
      for (int i = 0; i < row.length; i++) {
        buffer.write("${" " * (profile[i] - row[i].length)}${row[i]} ");
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  Matrix<num>? get inverse {
    num? determinant = this.determinant;
    if (determinant == null) {
      return null;
    }

    Matrix<num?> cofactorMatrix = [
      for (int y = 0; y < verticalLength; y++)
        [
          for (int x = 0; x < horizontalLength; x++) //
            removed(x: <int>{x}, y: <int>{y}).determinant
        ],
    ];
    if (cofactorMatrix.any((r) => r.any((e) => e == null))) {
      return null;
    }

    Matrix<num> adjoint = [
      for (int y = 0; y < verticalLength; y++)
        [
          for (int x = 0; x < horizontalLength; x++) //
            math.pow(-1, x + y) * cofactorMatrix[x][y]!
        ],
    ];

    return adjoint / determinant;
  }

  Matrix<num>? matrixMultiply(Matrix<num> other) {
    Matrix<num> transmuted = other.transpose();
    if (horizontalLength != transmuted.horizontalLength) {
      return null;
    }

    Matrix<num> applied = map(
      (r) => transmuted //
          .map((t) => (r * t)!.fix())
          .toList(), //
    ).toList();

    return applied;
  }

  num call(int y, int x) => this[y][x];

  Matrix<num>? operator *(Object other) => other is num
      ? matrixMap((e) => e * other)
      : other is Matrix<num>
          ? matrixMultiply(other)
          : null;

  Matrix<num>? operator /(Object other) => other is num
      ? matrixMap((e) => e / other)
      : other is Matrix<num>
          ? ((Matrix<num>? inverse) => inverse == null ? null : matrixMultiply(inverse))(other.inverse)
          : null;

  Matrix<num>? operator ~/(Object other) => other is num //
      ? matrixMap((e) => e ~/ other)
      : (this / other)?.matrixMap((e) => e.floor());
}
