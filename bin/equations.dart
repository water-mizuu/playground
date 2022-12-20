import "math/shared.dart";

List<Complex> differences(List<Complex> numbers) => //
    List.generate(numbers.length - 1, (i) => numbers[i] - numbers[i + 1]);

Iterable<List<Complex>> _solveCoefficient(List<Complex> numbers) sync* {
  yield numbers;

  if (numbers.length > 1) {
    for (List<Complex> extension in _solveCoefficient(differences(numbers))) {
      yield extension;
    }
  }
}

List<Complex> generateLeadingCoefficients(Complex degree) =>
    _solveCoefficient([for (Complex i = degree + 1.re; i > 0.re; i -= 1.re) i.pow(degree).floor()]) //
        .map((e) => e.last)
        .toList();

NumericalMatrix generateSystem(int degree) {
  NumericalMatrix matrix = (List.generate(degree + 1, (i) => [i]).mt) //
      .expandColumn(0, generateLeadingCoefficients, filler: 0.re)
      .transpose()
      .rowVectors
      .map((v) => v.data.reversed.toList())
      .toList()
      .mt;

  return matrix;
}

String generateEquations(NumericalMatrix matrix) {
  StringBuffer buffer = StringBuffer();

  for (int row = 0; row < matrix.verticalLength; row++) {
    StringBuffer rowBuffer = StringBuffer();

    rowBuffer
      ..write(String.fromCharCode(65 + row))
      ..write(" = ");

    for (int i = 0; i < matrix[row].degree; i++) {
      Complex cell = matrix[row][i];
      if (cell <= 0.re) {
        continue;
      }

      rowBuffer
        // If this is not the first element, separate it by a plus sign.
        ..write(i > 0 ? " + " : "")
        // If the number is greater than 1, then write the number. (1a = a)
        ..write(cell > 1.re ? cell : "")
        // Write it as the nth lowercase alphabet.
        ..write(String.fromCharCode(97 + i));
    }

    buffer.writeln(rowBuffer.toString());
  }

  return buffer.toString();
}

String generateEquationsFromDegree(int degree) => generateEquations(generateSystem(degree));

NumericalMatrix solve(NumericalMatrix coefficientMatrix, NumericalVector constantVector) {
  NumericalMatrix augmented = coefficientMatrix.horizontalConcatenate(right: Matrix.fromVectors([constantVector]));
  RowReduction reduction = augmented.reducedRowEchelonForm(RowReduction.preserveRowOrder);
  NumericalMatrix reduced = reduction.reduced.collapsed;

  return reduced;
}
