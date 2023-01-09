typedef Success<R> = (R value, String input);
typedef Parser<R> = Success<R>? Function(Success<void>);

Success<int>? parseNumber(Success<void> context) {
  var (_, String input) = context;

  if (RegExp(r"\d+").matchAsPrefix(input) case Match(end: int end)) {
    return (int.parse(input.substring(0, end)), input.substring(end));
  }
}

Parser<String> parseString(String pattern) {
  return (Success<void> context) {
    var (_, String input) = context;

    if (pattern.matchAsPrefix(input) case Match(:int end)) {
      return (input.substring(0, end), input.substring(end));
    }
  };
}

void main() {
  Success<void> context = (null, "1234 5678");
  var (int v1, String inp1) = parseNumber(context)!;
  var (_, String inp2) = parseString(" ")((null, inp1))!;
  var (int v2, String inp3) = parseNumber((null, inp2))!;

  print((v1, v2));
}
