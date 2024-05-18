bool circleEqualityOf(String left, String right) {
  if (left.length != right.length) {
    return false;
  }

  String moved = left;
  do {
    if (moved == right) {
      return true;
    }

    moved = moved.substring(1) + moved[0];
  } while (moved != left);

  return false;
}

Iterable<String> permutationsOf(String input, {int? withLength}) sync* {
  Iterable<String> permutationsOf(String input, int count) sync* {
    if (input.isEmpty || count <= 0) {
      yield "";
      return;
    }

    for (int i = 0; i < input.length; i++) {
      String prefix = input[i];
      String rest = input.substring(0, i) + input.substring(i + 1);
      for (String permutation in permutationsOf(rest, count - 1)) {
        yield prefix + permutation;
      }
    }
  }

  yield* permutationsOf(input, withLength ?? input.length);
}

extension<T> on Set<T> {
  Set<T> operator &(Set<T> other) => this.intersection(other);
}

extension on String {
  Set<String> get charSet => this.split("").toSet();
}

extension on int {
  int get factorial => this == 0 ? 1 : this * (this - 1).factorial;
  int c(int k) => this.factorial ~/ (k.factorial * (this - k).factorial);
}

void main() {
  Set<String> values = permutationsOf("0123456789", withLength: 7)
      .where((String v) => (("02468".charSet) & (v.charSet)).length == 5)
      .toSet();

  int length = values.length;
  print("Brute force: $length");
  print(permutationsOf("123"));
  print("Computed: ${5.c(2) * 7.factorial}");
}
