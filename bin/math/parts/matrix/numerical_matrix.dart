part of "../../matrix.dart";

/// BEWARE:
///   Not everything works here.

extension NumericalMatrixMethods on NumericalMatrix {
  static NumericalMatrix eye(int dimensions) => NumericalMatrix(<List<Scalar>>[
        for (int y = 0; y < dimensions; ++y)
          <Scalar>[
            for (int x = 0; x < dimensions; ++x)
              if (y == x) 1.c else 0.c,
          ],
      ]);

  static NumericalMatrix ones(int height, [int? width]) => NumericalMatrix(<List<Scalar>>[
        for (int y = 0; y < height; ++y) //
          <Scalar>[for (int x = 0; x < (width ?? height); ++x) 1.c],
      ]);

  static NumericalMatrix zeros(int height, [int? width]) => NumericalMatrix(<List<Scalar>>[
        for (int y = 0; y < height; ++y) //
          <Scalar>[for (int x = 0; x < (width ?? height); ++x) 0.c],
      ]);

  static NumericalMatrix companion(List<Scalar> scalars) => zeros(1, scalars.length - 2) //
      .verticalConcatenate(down: eye(scalars.length - 2))
      .horizontalConcatenate(
        right: NumericalMatrix.fromVectors(<NumericalVector>[
          NumericalVector(<Scalar>[for (int i = 0; i < scalars.length - 1; ++i) -scalars[i]]),
        ]),
      );

  List<int> get dimensions => <int>[verticalLength, horizontalLength];

  void swapRows(int rowA, int rowB) {
    List<Scalar> temp = List<Scalar>.from(data[rowA]);
    data[rowA] = List<Scalar>.from(data[rowB]);
    data[rowB] = temp;
  }

  NumericalMatrix scale(Scalar scalar) => NumericalMatrix(<List<Scalar>>[
        for (int y = 0; y < verticalLength; ++y) //
          <Scalar>[for (int x = 0; x < horizontalLength; ++x) scalar * data[y][x]],
      ]);

  NumericalMatrix get collapsed => matrixMap((Scalar v) => v.collapsed);

  Scalar minorCofactorExpansion(int y, int x) {
    NumericalMatrix minorMatrix = removed(y: <int>{y}, x: <int>{x});
    Scalar determinant = minorMatrix.determinantCofactorExpansion();

    return determinant;
  }

  Scalar determinantCofactorExpansion() {
    if (verticalLength != horizontalLength) {
      throw ArgumentError("A non-square matrix does not have a determinant!");
    }

    if (verticalLength == 1) {
      return data[0][0];
    }

    List<Scalar> cofactors = <Scalar>[
      for (int x = 0; x < horizontalLength; ++x) //
        r_math.pow(-1, x).c * data[0][x] * minorCofactorExpansion(0, x),
    ];
    Scalar sum = cofactors.sum();

    return sum;
  }

  NumericalMatrix inverseCofactorExpansion() {
    int vertical = verticalLength;
    int horizontal = horizontalLength;

    if (vertical != horizontal) {
      throw ArgumentError("A non-square matrix does not have a determinant!");
    }

    Scalar determinant = determinantCofactorExpansion();
    if (determinant == 0.c) {
      throw StateError("A singular matrix does not have a determinant!");
    }

    NumericalMatrix cofactorMatrix = NumericalMatrix(<List<Scalar>>[
      for (int y = 0; y < vertical; ++y)
        <Scalar>[
          for (int x = 0; x < horizontal; ++x) //
            r_math.pow(-1, y + x).c * minorCofactorExpansion(y, x),
        ],
    ]);
    NumericalMatrix adjugateMatrix = cofactorMatrix.transpose();

    return adjugateMatrix.scale(1.c / determinant);
  }

  LUFactorization luFactorization() {
    int vertical = verticalLength;

    NumericalMatrix lower = NumericalMatrixMethods.eye(vertical);
    NumericalMatrix upper = copy();

    for (int p = 0; p < vertical; ++p) {
      if (upper[p][p] == 0.c) {
        throw StateError("Unexpected zero pivot at E[$p][$p] in matrix.\nM =\n${toNumericalString()}");
      }

      for (int y = p + 1; y < vertical; ++y) {
        Scalar scalar = -upper[y][p] / upper[p][p];

        upper[y] += upper[p].scale(scalar);
        lower[y] -= lower[p].scale(scalar);
      }
    }

    return LUFactorization(lower, upper);
  }

  PLUFactorization pluFactorization([int flags = 0]) {
    bool permuteOnZeroOnly = flags & PLUFactorization.permuteOnZeroOnly != 0;

    int vertical = verticalLength;

    NumericalMatrix permutations = NumericalMatrixMethods.eye(vertical);
    NumericalMatrix lower = NumericalMatrixMethods.eye(vertical);
    NumericalMatrix upper = copy();
    int permutationCount = 0;

    for (int p = 0; p < vertical; ++p) {
      /// Pivot Resolution
      /// If the pivot is zero, force permutation regardless of flag.
      ///   Else, permute if the flag is false.
      if (upper[p][p] == 0.c || !permuteOnZeroOnly) {
        int swap = p;
        for (int y = p; y < vertical; ++y) {
          if (upper[y][p].abs() < upper[swap][p].abs()) {
            {
              continue;
            }
          }

          swap = y;
        }
        if (swap != p) {
          upper.swapRows(swap, p);
          permutations.swapRows(swap, p);

          for (int x = 0; x < p; ++x) {
            Scalar temp = lower[swap][x];
            lower[swap][x] = lower[p][x];
            lower[p][x] = temp;
          }
          ++permutationCount;
        }
        if (upper[swap][p] == 0.c) {
          {
            continue;
          }
        }
      }

      for (int y = p + 1; y < vertical; ++y) {
        Scalar scalar = -upper[y][p] / upper[p][p];

        upper[y] += upper[p].scale(scalar);
        lower[y] -= lower[p].scale(scalar);
      }
    }

    return PLUFactorization(permutations, lower, upper, permutationCount);
  }

  Scalar determinantLuFactorization() {
    PLUFactorization factorization = pluFactorization();
    NumericalMatrix upper = factorization.upper;
    Scalar diagonal = <Scalar>[for (int y = 0; y < verticalLength; ++y) upper[y][y]].product();
    Scalar determinant = r_math.pow(-1, factorization.permutationCount).c * diagonal;

    return determinant;
  }

  QRFactorization qrFactorization() {
    NumericalMatrix makeHouseholder(NumericalVector vector) {
      Scalar scalar = vector[0] + vector.magnitude * vector[0].sign;
      NumericalVector v = vector.scale(1.c / scalar);
      v[0] = 1.c;

      Scalar beta = 2.c / v.dot(v).abs();
      NumericalMatrix matrix = NumericalMatrix.fromVectors(<NumericalVector>[v]);
      NumericalMatrix matrixT = matrix.transpose();
      NumericalMatrix hMatrix = NumericalMatrixMethods.eye(vector.degree) - (matrix * matrixT).scale(beta);

      return hMatrix;
    }

    int horizontal = horizontalLength;
    int vertical = verticalLength;

    NumericalMatrix A = copy();
    NumericalMatrix Q = eye(vertical);
    for (int i = 0; i < horizontal - (horizontal == vertical ? 1 : 0); ++i) {
      NumericalMatrix H = eye(vertical);
      NumericalMatrix submatrix = makeHouseholder(A.columnVectors[i].subvector(top: i));

      for (int y = i; y < vertical; ++y) {
        for (int x = i; x < horizontal; ++x) {
          H[y][x] = submatrix[y - i][x - i];
        }
      }

      Q = Q * H;
      A = H * A;
    }

    return QRFactorization(Q, A);
  }

  EigenEstimation eigenvalueEstimation() {
    QRFactorization qr = qrFactorization();
    NumericalMatrix a = copy();
    NumericalMatrix q = qr.orthogonal;
    NumericalMatrix r = qr.upper;

    NumericalVector previous = NumericalVector(<Scalar>[for (int i = 0; i < verticalLength; ++i) 0.re]);
    NumericalMatrix accumulatedQ = q;
    for (int k = 0; k <= 100; ++k) {
      NumericalMatrix a0 = r * q;
      QRFactorization qr0 = a0.qrFactorization();
      NumericalMatrix q0 = qr0.orthogonal;
      NumericalMatrix r0 = qr0.upper;
      NumericalMatrix accumulative = accumulatedQ * q0;

      NumericalVector estimates = a0.rightDiagonalVectors.first;
      Scalar deviation = 0
          .to(estimates.degree) //
          .map((int i) => (previous[i] - estimates[i]).abs())
          .variance();

      if (0.re <= deviation && deviation <= 1e-16.re) {
        break;
      }
      a = a0;
      q = q0;
      r = r0;
      previous = estimates;
      accumulatedQ = accumulative;
    }

    NumericalMatrix vectorMatrix = accumulatedQ.collapsed;
    NumericalMatrix diagonalMatrix = a.collapsed;

    return EigenEstimation(vectorMatrix, diagonalMatrix);
  }

  EigenObjects eigenObjects() {
    if (verticalLength != horizontalLength) {
      throw UnsupportedError("[eigenObjects] is not supported for non-square matrices!");
    }

    int size = verticalLength;
    EigenEstimation estimation = eigenvalueEstimation();
    List<Scalar> values = estimation.eigenvalues.map((Scalar v) => v.collapse()).toSet().toList();
    List<NumericalVector> vectors = <NumericalVector>[
      // A - λI
      for (Matrix<Complex> eigenMatrix in values.map(NumericalMatrixMethods.eye(size).scale)) //
        ...(this - eigenMatrix).nullBasis(),
    ];

    NumericalMatrix diagonal = NumericalMatrixMethods.eye(size)..leftDiagonalVectors[0] = NumericalVector(values);
    NumericalMatrix eigenMatrix = NumericalMatrix.fromVectors(vectors);

    return EigenObjects(diagonal, eigenMatrix);
  }

  RowReduction reducedRowEchelonForm([int flags = 0]) {
    bool permuteOnZeroOnly = flags & RowReduction.permuteOnZeroOnly != 0;
    bool preserveRowOrder = flags & RowReduction.preserveRowOrder != 0;

    int vertical = verticalLength;
    int horizontal = horizontalLength;
    int diagonal = r_math.min(vertical, horizontal);

    Set<int> ignoreColumns = <int>{};
    NumericalMatrix copy = this.copy();
    NumericalMatrix permutations = NumericalMatrixMethods.eye(vertical);

    for (int p = 0; p < diagonal; ++p) {
      int swap = p;
      if (copy[p][p] == 0.c || !permuteOnZeroOnly) {
        for (int y = p + 1; y < vertical; ++y) {
          if (copy[y][p].abs() < copy[swap][p].abs()) {
            continue;
          }

          swap = y;
        }
      }

      if (swap != p) {
        copy.swapRows(swap, p);
        permutations.swapRows(swap, p);
      }
      if (copy[p][p] == 0.c) {
        continue;
      }

      Scalar divisor = copy[p][p];
      copy[p] = copy[p].scale(divisor.multiplicativeInverse);

      for (int y = p + 1; y < vertical; ++y) {
        Scalar scalar = -copy[y][p] / copy[p][p];

        copy[y] += copy[p].scale(scalar);
      }
    }

    for (int p = diagonal - 1; p >= 0; --p) {
      if (ignoreColumns.contains(p) || copy[p][p] == 0.c) {
        continue;
      }
      for (int y = p - 1; y >= 0; --y) {
        Scalar scalar = -copy[y][p] / copy[p][p];

        copy[y] += copy[p].scale(scalar);
      }
    }

    NumericalMatrix reduced = !preserveRowOrder //
        ? copy
        : permutations.transpose() * copy;

    return RowReduction(reduced);
  }

  NumericalMatrix inverseGaussianElimination() {
    NumericalMatrix identity = NumericalMatrixMethods.eye(verticalLength);
    NumericalMatrix augmented = horizontalConcatenate(right: identity);
    RowReduction reduction = augmented.reducedRowEchelonForm();
    NumericalMatrix reduced = reduction.reduced;
    NumericalMatrix inverse = reduced.submatrix(left: verticalLength);

    return inverse;
  }

  List<MapEntry<int, NumericalVector>> nullVectors([RowReduction? reduction]) {
    reduction ??= reducedRowEchelonForm();

    // We need to eliminate linearly dependent rows AND columns.
    NumericalMatrix hyperReduced = reduction.reduced //
        .transpose()
        .matrixMap((Scalar v) => v.collapsed)
        .reducedRowEchelonForm()
        .reduced;

    List<NumericalVector> vectors = hyperReduced.rowVectors;
    List<MapEntry<int, NumericalVector>> nullVectors = 0
        .to(vectors.length) //
        .where((int i) {
          NumericalVector vector = vectors[i];
          for (int i = vector.degree - 1; i >= 0; --i) {
            if (vector[i] == 0.c) {
              continue;
            }
            if (vector[i] == 1.c) {
              return false;
            }
            return true;
          }
          return true;
        })
        .map((int i) => MapEntry<int, Vector<Complex>>(i, vectors[i]))
        .toList();

    return nullVectors;
  }

  Set<NumericalVector> rowBasis() {
    RowReduction reduction = reducedRowEchelonForm();
    NumericalMatrix reduced = reduction.reduced.collapsed;
    List<NumericalVector> vectors = reduced.rowVectors;
    Set<NumericalVector> basis = <NumericalVector>{
      for (int i = 0; i < verticalLength; ++i)
        if (!reduced[i].data.every((Scalar v) => v == 0.c)) vectors[i],
    };

    return basis;
  }

  Set<NumericalVector> columnBasis() {
    Set<int> nullIndices = nullVectors().map((MapEntry<int, NumericalVector> v) => v.key).toSet();
    List<NumericalVector> vectors = columnVectors;
    Set<NumericalVector> nonNullVectors = <NumericalVector>{
      for (int i = 0; i < vectors.length; ++i)
        if (!nullIndices.contains(i)) vectors[i],
    };

    return nonNullVectors;
  }

  Set<NumericalVector> nullBasis() {
    int vertical = verticalLength;
    int horizontal = horizontalLength;

    RowReduction reduction = reducedRowEchelonForm();
    NumericalMatrix reduced = reduction.reduced.collapsed;

    List<int> freeIndices = nullVectors(reduction) //
        .map((MapEntry<int, NumericalVector> entry) => entry.key)
        .toList();

    // Count the maximum free variables.
    // This is here because sometimes, there are given where:
    //    It is *not* an augmented matrix.
    // Also times that it is, so ¯\_(ツ)_/ ¯ I think it works for now.

    int max = freeIndices.map((int v) => v + 1).max();
    NumericalMatrix padded = max > vertical //
        ? reduced.verticalConcatenate(down: zeros(max - vertical, horizontal))
        : reduced;

    List<NumericalVector> columnVectors = padded.columnVectors;
    Set<NumericalVector> vectors = freeIndices.map((int i) {
      NumericalVector vector = columnVectors[i];
      NumericalVector negative = vector.scale(-1.c);
      negative[i] = 1.c;

      return negative;
    }).toSet();

    return vectors;
  }

  NumericalMatrix add(NumericalMatrix other) {
    if (horizontalLength != other.horizontalLength || verticalLength != other.verticalLength) {
      throw ArgumentError("Cannot add two incompatible matrices. L:$dimensions; R:${other.dimensions}");
    }

    return NumericalMatrix(<List<Scalar>>[
      for (int y = 0; y < verticalLength; ++y)
        <Scalar>[for (int x = 0; x < horizontalLength; ++x) data[y][x] + other.data[y][x]],
    ]);
  }

  NumericalMatrix dot(NumericalMatrix other) {
    if (horizontalLength != other.verticalLength) {
      throw ArgumentError("Cannot multiply two incompatible matrices. L:$dimensions; R:${other.dimensions}");
    }

    List<NumericalVector> rowVectors = this.rowVectors;
    List<NumericalVector> columnVectors = other.columnVectors;
    List<NumericalVector> vectors = <NumericalVector>[
      for (NumericalVector column in columnVectors) //
        NumericalVector(<Scalar>[for (NumericalVector row in rowVectors) row * column]),
    ];

    return NumericalMatrix.fromVectors(vectors);
  }

  NumericalMatrix operator +(NumericalMatrix other) => add(other);
  NumericalMatrix operator -(NumericalMatrix other) => add(other.additiveInverse);
  NumericalMatrix operator -() => additiveInverse;

  NumericalMatrix operator *(NumericalMatrix other) => dot(other);

  NumericalMatrix get additiveInverse => scale(-1.c);

  Scalar get determinant => determinantLuFactorization();

  ElementWiseNumericalMatrixProxy get elementWise => ElementWiseNumericalMatrixProxy(this);
}

class EigenEstimation {

  const EigenEstimation(this.eigenvectors, this.diagonal);
  final NumericalMatrix eigenvectors;
  final NumericalMatrix diagonal;

  Set<Scalar> get eigenvalues {
    NumericalMatrix matrix = diagonal.collapsed;
    Set<Scalar> eigenvalues = <Scalar>{};

    for (int p = 0; p < matrix.verticalLength; ++p) {
      // Determine if it's a 1x1 or 2x2 block.

      bool isComplex = p < matrix.verticalLength - 1 && matrix[p + 1][p].abs() > 1e-9.re;
      if (isComplex) {
        Scalar mean = 0.5.c * (matrix[p + 1][p + 1] + matrix[p][p]);
        Scalar product = matrix[p][p] * matrix[p + 1][p + 1] - matrix[p][p + 1] * matrix[p + 1][p];

        // m ± √(m² - p) *ping*
        Scalar root1 = mean + c_math.pow(mean * mean - product, 0.5.re);
        Scalar root2 = mean - c_math.pow(mean * mean - product, 0.5.re);

        eigenvalues
          ..add(root1)
          ..add(root2);

        ++p;
      } else {
        eigenvalues.add(matrix[p][p]);
      }
    }

    return eigenvalues;
  }
}

class RowReduction {

  const RowReduction(this.reduced);
  static const int permuteOnZeroOnly = 1 << 0;
  static const int preserveRowOrder = 1 << 1;

  final NumericalMatrix reduced;
}

class QRAlgorithm {

  const QRAlgorithm(this.diagonal, this.eigenvectors);
  final NumericalMatrix diagonal;
  final NumericalMatrix eigenvectors;
}

class EigenObjects {

  const EigenObjects(this.diagonal, this.eigenvectors);
  final NumericalMatrix diagonal;
  final NumericalMatrix eigenvectors;
}

class LUFactorization {

  const LUFactorization(this.lower, this.upper);
  final NumericalMatrix lower;
  final NumericalMatrix upper;
}

class PLUFactorization extends LUFactorization {

  const PLUFactorization(this.permutation, super.lower, super.upper, this.permutationCount);
  static const int permuteOnZeroOnly = 1 << 0;

  final NumericalMatrix permutation;
  final int permutationCount;
}

class QRFactorization {

  const QRFactorization(this.orthogonal, this.upper);
  final NumericalMatrix orthogonal;
  final NumericalMatrix upper;
}

extension MatrixPostfixExtension<E> on List<List<E>> {
  Matrix<E> get mt => Matrix<E>(this);
  Matrix<E> toMatrix() => Matrix<E>(this);
}

extension NumericalMatrixPostfixExtension<E extends num> on List<List<E>> {
  Matrix<Scalar> get mt => Matrix<Scalar>(map((List<E> e) => e.map(Scalar.from).toList()).toList());
  Matrix<Scalar> toMatrix() => Matrix<Scalar>(map((List<E> e) => e.map(Scalar.from).toList()).toList());
}

extension on Iterable<Complex> {
  Complex variance() {
    Complex mean = this.mean();
    Complex distances = map((Complex v) => (v - mean).abs()).sum();
    Complex variance = distances / length.c;

    return variance;
  }
}
