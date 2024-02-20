import "dart:io";

bool isOperator(String token) => <String>{"+", "-", "*", "/", "%"}.contains(token);
int precedence(String token) => <String, int>{"+": 1, "-": 1, "*": 2, "/": 2, "%": 2}[token.trim()] ?? -1;

String reversePolishNotation(String input) {
  StringBuffer builder = StringBuffer();
  List<String> stack = <String>[];
  List<String> tokens = input.split(" ");
  for (String token in tokens) {
    if (isOperator(token)) {
      while (stack.isNotEmpty && isOperator(stack.last) && precedence(token) <= precedence(stack.last)) {
        builder
          ..write(stack.removeLast())
          ..write(" ");
      }
      stack.add(token);
    } else if (token == "(") {
      stack.add(token);
    } else if (token == ")") {
      while (stack.isNotEmpty && stack.last != "(") {
        builder
          ..write(stack.removeLast())
          ..write(" ");
      }
      stack.removeLast();
    } else {
      builder
        ..write(token)
        ..write(" ");
    }
  }

  while (stack.isNotEmpty) {
    builder
      ..write(stack.removeLast())
      ..write(" ");
  }

  return builder.toString();
}

String polishNotation(String input) {
  List<String> output = <String>[];
  List<String> stack = <String>[];
  List<String> tokens = input.replaceAll("(", " ( ").replaceAll(")", " ) ").split(" ");

  for (int i = tokens.length - 1; i >= 0; --i) {
    String token = tokens[i].trim();

    if (isOperator(token)) {
      while (stack.isNotEmpty && isOperator(stack.last) && precedence(token) < precedence(stack.last)) {
        output.insert(0, stack.removeLast());
      }
      stack.add(token);
    } else if (token == ")") {
      stack.add(token);
    } else if (token == "(") {
      while (stack.isNotEmpty && stack.last != ")") {
        output.insert(0, stack.removeLast());
      }
      assert(stack.last == ")");
      stack.removeLast();
    } else {
      output.insert(0, token);
    }
  }

  while (stack.isNotEmpty) {
    output.insert(0, stack.removeLast());
  }

  return output.join(" ");
}

void main() {
  stdout.writeln(reversePolishNotation("a % b / c"));
  stdout.writeln(polishNotation("a % b / c"));
}
