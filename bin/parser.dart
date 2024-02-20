typedef Success<R> = (R value, String input);
typedef Parser<R> = Success<R>? Function(Success<void>);

Success<int>? parseNumber(Success<void> context) {
  var (_, String input) = context;

  return switch (RegExp(r"\d+").matchAsPrefix(input)) {
    Match(:int end) => (int.parse(input.substring(0, end)), input.substring(end)),
    null => null,
  };
}

Parser<String> parseString(String pattern) {
  return (Success<void> context) {
    var (_, String input) = context;

    return switch (pattern.matchAsPrefix(input)) {
      Match(:int end) => (input.substring(0, end), input.substring(end)),
      null => null,
    };
  };
}

void main() {
  Success<void> context = (null, "1234 5678");
  var (int v1, String inp1) = parseNumber(context)!;
  var (_, String inp2) = parseString(" ")((null, inp1))!;
  var (int v2, String _) = parseNumber((null, inp2))!;

  print((v1, v2));
}
