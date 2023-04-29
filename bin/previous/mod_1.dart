import "dart:math" as math;

import "matrix.dart";

extension on num {
  num pow(num exponent) => math.pow(this, exponent);
}

List<int> differences(List<int> numbers) => //
    List<int>.generate(numbers.length - 1, (int i) => numbers[i] - numbers[i + 1]);

Iterable<List<int>> _solveCoefficient(List<int> numbers) sync* {
  yield numbers;

  if (numbers.length > 1) {
    for (List<int> extension in _solveCoefficient(differences(numbers))) {
      yield extension;
    }
  }
}

Iterable<int> generateLeadingCoefficients(int degree) =>
    _solveCoefficient(<int>[for (int i = degree + 1; i > 0; i--) i.pow(degree).floor()]) //
        .map((List<int> e) => e.last);

Matrix<int> generateSystem(int degree) {
  Matrix<int> matrix = List<List<int>>.generate(degree + 1, (int i) => <int>[i])
      .expandColumn(0, (int i) => generateLeadingCoefficients(i).toList(), filler: 0)
      .transpose()
      .map((List<int> e) => e.reversed.toList())
      .toList();

  return matrix;
}

String generateEquations(Matrix<int> matrix) {
  StringBuffer buffer = StringBuffer();

  for (int row = 0; row < matrix.verticalLength; row++) {
    StringBuffer rowBuffer = StringBuffer();

    <void>[
      String.fromCharCode(65 + row),
      " = ",
    ].forEach(rowBuffer.write);

    for (int i = 0; i < matrix[row].length; i++) {
      int cell = matrix[row][i];
      if (cell <= 0) {
        continue;
      }

      <void>[
        // If this is not the first element, separate it by a plus sign.
        if (i > 0) " + ",
        // If the number is greater than 1, then write the number. (1a = a)
        if (cell > 1) cell,
        // Write it as the nth lowercase alphabet.
        String.fromCharCode(97 + i),
      ].forEach(rowBuffer.write);
    }

    buffer.writeln(rowBuffer.toString());
  }

  return buffer.toString();
}

String generateEquationsFromDegree(int degree) => generateEquations(generateSystem(degree));

void main(List<String> args) async {
  print(generateEquationsFromDegree(5));
}
