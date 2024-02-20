/// Using function write a program that can find the maximum number of 3 parameters.
/// Explain.
///
/// Zuñiga, John Michael T.
/// CS 200-CS21S1 - Principles of Programming Languages
library;

import "dart:io";

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

int max3(int a, int b, int c) {
  /// We assume that the maximum is the first variable, [a].
  int max = a;

  /// If [b] is greater than [max], then [b] is the new maximum.
  if (b > max) {
    max = b;
  }

  /// If [c] is greater than [max], then [c] is the new maximum.
  if (c > max) {
    max = c;
  }

  return max;
}

void main() {
  // Non-null assertion because we want to error when stdin returns null (there is no stdin stream).
  int a = readInt()!;
  int b = readInt()!;
  int c = readInt()!;
  int max = max3(a, b, c);

  print("The maximum is $max");
}

/// Short Explanation:
///
/// As shown in the implementation of [max3], we allocate a [max] variable, and
/// assume that the maximum is the first variable, [a]. Then, comparing the value
/// of [max] with [b] and [c], we can determine if [b] or [c] is greater than the
/// other values.
///
