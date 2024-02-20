import "dart:math" as r_math;

import "functions/complex_math.dart" as c_math;
import "shared.dart";

export "shared.dart";

part "parts/matrix/element_wise.dart";
part "parts/matrix/list_vector_proxy.dart";
part "parts/matrix/numerical_matrix.dart";

typedef _List2d<E> = List<List<E>>;

enum HorizontalDirection { left, right }

enum VerticalDirection { up, down }

class Matrix<E> extends Iterable<E> {
  const Matrix(this.data);
  factory Matrix.fromVectors(List<Vector<E>> columnVectors) {
    Set<int> degrees = columnVectors.map((Vector<E> v) => v.degree).toSet();
    if (degrees.length > 1) {
      throw StateError("Cannot create a matrix with inconsistent degrees!");
    }
    int height = degrees.min();
    List<List<E>> data = <List<E>>[
      for (int y = 0; y < height; ++y) //
        <E>[for (int x = 0; x < columnVectors.length; ++x) columnVectors[x][y]],
    ];

    return Matrix<E>(data);
  }
  final List<List<E>> data;

  Iterable<E> get _iterable sync* {
    for (List<E> row in data) {
      yield* row;
    }
  }

  Matrix<E> horizontalConcatenate({Matrix<E>? left, Matrix<E>? right}) {
    if ((left?.verticalLength ?? verticalLength) != verticalLength ||
        (right?.verticalLength ?? verticalLength) != verticalLength) {
      throw StateError("in horzcat, the matrices must have matching vertical dimensions!");
    }

    return Matrix<E>(<List<E>>[
      for (int y = 0; y < verticalLength; ++y)
        <E>[
          if (left != null) ...left.data[y],
          ...data[y],
          if (right != null) ...right.data[y],
        ],
    ]);
  }

  Matrix<E> verticalConcatenate({Matrix<E>? up, Matrix<E>? down}) {
    if ((up?.horizontalLength ?? horizontalLength) != horizontalLength ||
        (down?.horizontalLength ?? horizontalLength) != horizontalLength) {
      throw StateError("in vrtcat, the matrices must have matching horizontal dimensions!");
    }

    return Matrix<E>(<List<E>>[
      if (up != null) ...up.data,
      ...this.data,
      if (down != null) ...down.data,
    ]);
  }

  Matrix<E> submatrix({int top = 0, int bottom = 0, int left = 0, int right = 0}) => //
      Matrix<E>(<List<E>>[
        for (int y = top; y < data.length - bottom; y++)
          <E>[for (int x = left; x < data[y].length - right; x++) data[y][x]],
      ]);

  Matrix<E> removed({Set<int> x = const <int>{}, Set<int> y = const <int>{}}) => //
      Matrix<E>(<List<E>>[
        for (int yi = 0; yi < verticalLength; yi++)
          if (!y.contains(yi))
            <E>[
              for (int xi = 0; xi < horizontalLength; xi++)
                if (!x.contains(xi)) data[yi][xi],
            ],
      ]);

  Matrix<E> transpose() => Matrix<E>(<List<E>>[
        for (int x = 0; x < horizontalLength; x++) //
          <E>[for (int y = 0; y < verticalLength; y++) data[y][x]],
      ]);

  Matrix<E> expandColumn(
    int at,
    List<E> Function(E element) handler, {
    E? filler,
    HorizontalDirection direction = HorizontalDirection.right,
  }) {
    _List2d<E> expanded = <List<E>>[for (int y = 0; y < data.length; y++) handler(data[y][at])];
    Set<int> resultLengths = expanded.map((List<E> list) => list.length).toSet();
    if (filler == null && resultLengths.length > 1) {
      throw StateError("The resulting matrix shape is uneven and there was no filler provided.");
    }

    int max = resultLengths.max();
    _List2d<E> filled = <List<E>>[
      for (List<E> row in expanded)
        <E>[
          if (filler != null && direction == HorizontalDirection.left)
            for (int x = row.length; x < max; x++) filler,
          ...row,
          if (filler != null && direction == HorizontalDirection.right)
            for (int x = row.length; x < max; x++) filler,
        ],
    ];
    _List2d<E> matrix = <List<E>>[
      for (int y = 0; y < data.length; y++)
        <E>[
          for (int x = 0; x < data[y].length; x++)
            if (x == at) ...filled[y] else data[y][x],
        ],
    ];

    return Matrix<E>(matrix);
  }

  Matrix<E> expandRow(
    int at,
    List<E> Function(E element) handler, {
    E? filler,
    VerticalDirection direction = VerticalDirection.down,
  }) {
    /// Build the matrix.
    /// if y == index, expand bottom.
    ///
    _List2d<E> expanded = <List<E>>[for (int x = 0; x < horizontalLength; ++x) handler(data[at][x])];
    Set<int> resultLengths = expanded.map((List<E> list) => list.length).toSet();
    if (filler == null && resultLengths.length > 1) {
      throw StateError("The resulting matrix shape is uneven and there was no filler provided.");
    }

    /// Normalize the matrix.
    ///   If the shape is consistent, let it be.
    ///   Else, we pad it with the filler.
    int max = resultLengths.max();
    _List2d<E> normalized = <List<E>>[
      for (List<E> partialColumn in expanded)
        if (partialColumn.length == max)
          partialColumn
        else
          <E>[
            /// Dichotomy states that it can only be UP or DOWN.
            ///   For the extra null check, idk.
            if (filler != null && direction == VerticalDirection.up)
              for (int i = partialColumn.length; i < max; ++i) filler,
            ...partialColumn,
            if (filler != null && direction == VerticalDirection.down)
              for (int i = partialColumn.length; i < max; ++i) filler,
          ],
    ];

    /// Build the matrix.
    ///   If y is [at],
    ///     we put the transpose of the normalized.
    ///   else, we just use the row of data.
    _List2d<E> built = <List<E>>[
      for (int y = 0; y < verticalLength; ++y)
        if (y == at) //
          ...<List<E>>[
          for (int y = 0; y < max; ++y) <E>[for (int x = 0; x < horizontalLength; ++x) normalized[x][y]],
        ] else
          data[y],
    ];

    return Matrix<E>(built);
  }

  Matrix<E> mapColumn(int index, E Function(E element) handler) => Matrix<E>(<List<E>>[
        for (List<E> row in data)
          <E>[
            for (int i = 0; i < row.length; i++)
              if (i == index) handler(row[i]) else row[i],
          ],
      ]);

  Matrix<E> mapRow<R extends E>(int index, E Function(E element) handler) => Matrix<E>(<List<E>>[
        for (int i = 0; i < data.length; i++)
          <E>[
            for (E item in data[i])
              if (i == index) handler(item) else item,
          ],
      ]);

  Matrix<R> matrixMap<R>(R Function(E element) handler) => Matrix<R>(<List<R>>[
        for (List<E> row in data) <R>[for (E item in row) handler(item)],
      ]);

  bool matrixAny(bool Function(E element) handler) => data.any((List<E> row) => row.any(handler));
  bool matrixEvery(bool Function(E element) handler) => data.every((List<E> row) => row.every(handler));

  Matrix<E> copy() => Matrix<E>(<List<E>>[
        for (List<E> row in data) <E>[for (E item in row) item],
      ]);

  int get verticalLength => data.length;
  int get horizontalLength => _safeLength;

  int get _safeLength => data.map((List<E> row) => row.length).min();

  String _buildString(Matrix<String> stringified) {
    List<int> profile = stringified
        .transpose() //
        .data
        .map((List<String> row) => row.map((String v) => v.length + 3).max())
        .toList();

    StringBuffer buffer = StringBuffer();
    for (List<String> row in stringified.data) {
      for (int i = 0; i < row.length; i++) {
        buffer.write("${" " * (profile[i] - row[i].length)}${row[i]} ");
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  @override
  String toString() {
    Matrix<String> stringified = matrixMap((E element) => element.toString());

    return _buildString(stringified);
  }

  String toRationalizedString() {
    if (matrixAny((E v) => v is! NumberLike)) {
      throw TypeError();
    }

    Matrix<String> stringified = matrixMap((E v) => (v as NumberLike<void>).strRat);

    return _buildString(stringified);
  }

  String toNumericalString() {
    if (matrixAny((E v) => v is! NumberLike)) {
      throw TypeError();
    }

    Matrix<String> stringified = matrixMap((E v) => (v as NumberLike<void>).strRat);

    return _buildString(stringified);
  }

  static String _renderMatrixString(String input) {
    StringBuffer buffer = StringBuffer();
    List<String> lines = input.split("\n");
    int fullWidth = lines.map((String v) => v.length).max();

    buffer
      ..write("┌ ")
      ..write(" " * fullWidth)
      ..writeln(" ┐");

    for (String line in lines) {
      buffer
        ..write("│ ")
        ..write(line)
        ..writeln(" │");
    }

    buffer
      ..write("└ ")
      ..write(" " * fullWidth)
      ..writeln(" ┘");

    return buffer.toString();
  }

  static List<int> _countColumnLengths(Matrix<String> components) {
    List<int> profile = components.columnVectors //
        .map((Vector<String> v) => v.data.map((String v) => v.length).max())
        .toList();

    return profile;
  }

  String toMatrixString() {
    StringBuffer renderBuffer = StringBuffer();
    Matrix<String> components = matrixMap((E v) => "$v");
    List<int> profile = _countColumnLengths(components);

    String rowSeparator = "  ";
    _List2d<String> data = components.data;

    for (int y = 0; y < data.length; ++y) {
      List<String> row = data[y];

      for (int x = 0; x < horizontalLength; ++x) {
        String base = row[x].padLeft(profile[x]);

        renderBuffer.write(base);
        if (x < row.length - 1) {
          renderBuffer.write(rowSeparator);
        }
      }

      if (y < data.length - 1) {
        renderBuffer.writeln();
      }
    }

    String contents = renderBuffer.toString();
    String matrixString = _renderMatrixString(contents);

    return matrixString;
  }

  String toCsvString() {
    StringBuffer renderBuffer = StringBuffer();
    Matrix<String> components = matrixMap((E v) => "$v");
    List<int> profile = _countColumnLengths(components);

    String rowSeparator = ",";
    _List2d<String> data = components.data;

    for (int y = 0; y < data.length; ++y) {
      List<String> row = data[y];

      for (int x = 0; x < horizontalLength; ++x) {
        String base = row[x].padRight(profile[x]);

        renderBuffer.write(base);
        if (x < row.length - 1) {
          renderBuffer.write(rowSeparator);
        }
      }
      if (y < data.length - 1) {
        renderBuffer.writeln();
      }
    }

    return renderBuffer.toString();
  }

  List<Vector<E>> get rowVectors => _ListVectorProxy<E>(this, <List<(int, int)>>[
        for (int y = 0; y < verticalLength; ++y) //
          <(int, int)>[for (int x = 0; x < horizontalLength; ++x) (y, x)],
      ]);
  List<Vector<E>> get columnVectors => _ListVectorProxy<E>(this, <List<(int, int)>>[
        for (int x = 0; x < horizontalLength; ++x) //
          <(int, int)>[for (int y = 0; y < verticalLength; ++y) (y, x)],
      ]);
  List<Vector<E>> get rightDiagonalVectors => _ListVectorProxy<E>(this, <List<(int, int)>>[
        for (int x = 0; x < horizontalLength; ++x) //
          <(int, int)>[for (int y = 0; y < verticalLength; ++y) (y, (y + x) % horizontalLength)],
      ]);
  List<Vector<E>> get leftDiagonalVectors => _ListVectorProxy<E>(this, <List<(int, int)>>[
        for (int x = 0; x < horizontalLength; ++x) //
          <(int, int)>[for (int y = 0; y < verticalLength; ++y) (y, (horizontalLength + y - x) % horizontalLength)],
      ]);
  Vector<E> operator [](int index) => Vector<E>(data[index]);
  void operator []=(int index, Vector<E> val) => data[index] = val.data;

  @override
  Iterator<E> get iterator => _iterable.iterator;
}
