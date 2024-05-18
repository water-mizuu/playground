// ignore_for_file: unreachable_from_main

import "dart:io";

extension type Stack<T>(List<T> _) {
  static Stack<T> create<T>() => Stack<T>(<T>[]);

  void push(T value) => _.add(value);
  T pop() => _.removeLast();
  T peek() => _.last;
  bool get isEmpty => _.isEmpty;
  bool get isNotEmpty => _.isNotEmpty;
}

enum Association { left, right }

const Map<String, (int, Association)> operatorTable = <String, (int, Association)>{
  "+": (1, Association.left),
  "-": (1, Association.left),
  "*": (2, Association.left),
  "/": (2, Association.left),
  "%": (2, Association.left),
  "^": (3, Association.right),
};
bool isOperator(String token) => operatorTable.containsKey(token);
int precedenceOf(String token) => operatorTable[token.trim()]?.$1 ?? -1;
Association associationOf(String token) => operatorTable[token.trim()]?.$2 ?? Association.left;

String reversePolishNotation(String input) {
  List<String> output = <String>[];
  Stack<String> stack = Stack.create();
  List<String> tokens = input //
      .replaceAll("(", " ( ")
      .replaceAll(")", " ) ")
      .split(" ")
      .map((String v) => v.trim())
      .where((String v) => v.isNotEmpty)
      .toList();

  for (String token in tokens) {
    if (isOperator(token)) {
      while (stack.isNotEmpty &&
          isOperator(stack.peek()) && //
          precedenceOf(token) <= precedenceOf(stack.peek()) &&
          associationOf(stack.peek()) == Association.left) {
        output.add(stack.pop());
      }
      stack.push(token);
    } else if (token == "(") {
      stack.push(token);
    } else if (token == ")") {
      while (stack.isNotEmpty && stack.peek() != "(") {
        output.add(stack.pop());
      }
      stack.pop();
    } else {
      output.add(token);
    }
  }

  while (stack.isNotEmpty) {
    output.add(stack.pop());
  }

  return output.join(" ");
}

String polishNotation(String input) {
  List<String> output = <String>[];
  Stack<String> stack = Stack.create();
  List<String> tokens = input //
      .replaceAll("(", " ( ")
      .replaceAll(")", " ) ")
      .split(" ")
      .map((String v) => v.trim())
      .where((String v) => v.isNotEmpty)
      .toList();

  for (int i = tokens.length - 1; i >= 0; --i) {
    String token = tokens[i].trim();

    if (isOperator(token)) {
      while (stack.isNotEmpty &&
          isOperator(stack.peek()) &&
          (precedenceOf(token) < precedenceOf(stack.peek()) ||
              (Association.right == associationOf(stack.peek()) &&
                  precedenceOf(token) == precedenceOf(stack.peek())))) {
        output.insert(0, stack.pop());
      }
      stack.push(token);
    } else if (token == ")") {
      stack.push(token);
    } else if (token == "(") {
      while (stack.isNotEmpty && stack.peek() != ")") {
        output.insert(0, stack.pop());
      }
      assert(stack.peek() == ")");
      stack.pop();
    } else {
      output.insert(0, token);
    }
  }

  while (stack.isNotEmpty) {
    output.insert(0, stack.pop());
  }

  return output.join(" ");
}

Object groupPolishNotation(String input) {
  (Object, int) process(List<String> tokens, int i) {
    if (isOperator(tokens[i])) {
      var (Object left, int j) = process(tokens, i + 1);
      var (Object right, int k) = process(tokens, j);

      return ((left, tokens[i], right), k);
    } else {
      return (tokens[i], i + 1);
    }
  }

  return process(input.split(" "), 0).$1;
}

Object groupReversedPolishNotation(String input) {
  Stack<Object> stack = Stack.create();
  List<String> tokens = input.split(" ");
  for (String token in tokens) {
    if (isOperator(token)) {
      Object right = stack.pop();
      Object left = stack.pop();
      stack.push((left, token, right));
    } else {
      stack.push(token);
    }
  }

  return stack.pop();
}

void main() {
  String input = "0 + 1 + a * (b ^ c) ^ d";
  String polish = polishNotation(input);
  String reversedPolish = reversePolishNotation(input);

  stdout.writeln(polish);
  stdout.writeln(reversedPolish);
  stdout.writeln(groupPolishNotation(polish));
  stdout.writeln(groupReversedPolishNotation(reversedPolish));
  // stdout.writeln(polishNotation("1 % 2 / 3"));
}
