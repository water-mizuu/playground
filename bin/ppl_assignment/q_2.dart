/// Using function write a program that takes parameter input from the user and search if it is existing on an Array of numbers.
/// Explain.
///
/// Zuñiga, John Michael T.
/// CS 200-CS21S1 - Principles of Programming Languages

library;

import "dart:io";
import "dart:math";

int? readInt() {
  while (true) {
    String? line = stdin.readLineSync();
    if (line == null) {
      return null;
    }

    if (int.tryParse(line) case int value) {
      return value;
    }
  }
}

bool hasNumber(List<int> integers, int number) {
  for (int i = 0; i < integers.length; ++i) {
    if (integers[i] == number) {
      return true;
    }
  }

  return false;
}

void main() {
  Random random = Random();
  List<int> integers = <int>[for (int i = 0; i < 10; ++i) random.nextInt(100)]..sort();

  stdout.write("Enter a number within 0-99: ");

  // Non-null assertion because we want to error when stdin returns null (there is no stdin stream).
  int integer = readInt()!;

  print("The numbers are: $integers");
  if (hasNumber(integers, integer)) {
    print("The number $integer is in the list");
  } else {
    print("The number $integer is not in the list");
  }
}

/// Short Explanation:
///
/// As shown in the implementation of [hasNumber], we iterate through the list of integers
/// and check if the current integer is equal to the number we are searching for. If it is,
/// then we return true. Otherwise, we return false.
///
/// We then use the result of [hasNumber] in determining the kind of message we will print.
