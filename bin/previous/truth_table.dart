// ignore_for_file: unreachable_from_main

import "dart:math";

typedef ParseResult = (Node?, String?, String);
typedef Environment = Map<Node, bool>;

class Tokenizer {
  static final RegExp identifier = RegExp(r"^\s*(?!not|and|xor|or|implies)([A-Za-z_$][0-9A-Za-z_$]*)(.*)$");
  static final RegExp leftParenthesis = RegExp(r"^\s*(\()(.*)$");
  static final RegExp rightParenthesis = RegExp(r"^\s*(\))(.*)$");
  static final RegExp not = RegExp(r"^\s*(!|not)(.*)$");
  static final RegExp and = RegExp(r"^\s*(&|and)(.*)$");
  static final RegExp xor = RegExp(r"^\s*(\^|xor)(.*)$");
  static final RegExp or = RegExp(r"^\s*(\||or)(.*)$");
  static final RegExp implies = RegExp(r"^\s*(=>|->|implies)(.*)$");
}

sealed class Node {
  const Node();

  Node parenthesize() => switch (this) {
        Parenthesis() || Atomic() => this,
        Node() => Parenthesis("(", this, ")"),
      };

  Node unwrap() => switch (this) {
        Parenthesis(:Node mid) => mid.unwrap(),
        Node() => this,
      };
}

enum BinaryOp {
  and("&"),
  xor("^"),
  or("|"),
  implies("=>");

  const BinaryOp(this.label);

  final String label;

  @override
  String toString() => label;
}

enum UnaryOp {
  not("~"),
  ;

  const UnaryOp(this.label);

  final String label;

  @override
  String toString() => label;
}

enum Associativity {
  left,
  right,
}

final class Parenthesis extends Node with StringEquality {
  const Parenthesis(this.left, this.mid, this.right);
  final String left;
  final Node mid;
  final String right;

  @override
  String toString() => "($mid)";
}

final class Binary extends Node with StringEquality {
  const Binary(this.left, this.mid, this.right);
  final Node left;
  final BinaryOp mid;
  final Node right;

  @override
  String toString() => "$left $mid $right";
}

final class Unary extends Node with StringEquality {
  const Unary(this.op, this.value);
  final UnaryOp op;
  final Node value;

  @override
  String toString() => "$op $value";
}

final class Atomic extends Node with StringEquality {
  const Atomic(this.value);
  final String value;

  @override
  String toString() => value;
}

mixin StringEquality {
  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) => this.toString() == other.toString();
}

Node parse(String input) {
  ParseResult Function(String) binary(
    (Node?, String?, String) Function(String) previous,
    RegExp regex,
    BinaryOp operator,
    Associativity associativity,
  ) {
    return (String input) {
      var (Node? left, String? err0, String rest0) = previous(input);
      if (left == null || err0 != null) {
        return (null, err0, rest0);
      }

      List<(BinaryOp, Node)> sequences = <(BinaryOp, Node)>[];
      while (true) {
        if (regex.exec(rest0) case [_, _, String rest1]) {
          var (Node? right, String? err2, String rest2) = previous(rest1);
          if (right == null || err2 != null) {
            return (null, err2, rest1);
          }

          sequences.add((operator, right.parenthesize()));
          rest0 = rest2;
        } else {
          break;
        }
      }

      /// Apply folding.

      if (sequences.isEmpty) {
        return (left, null, rest0);
      }

      if (associativity case Associativity.left) {
        Node node = left;
        for (var (BinaryOp op, Node right) in sequences) {
          node = Binary(node.parenthesize(), op, right);
        }

        return (node, null, rest0);
      } else {
        var (_, Node node) = sequences.last;
        for (int i = sequences.length - 1; i >= 1; --i) {
          var [(_, Node left), (BinaryOp op, _)] = sequences.sublist(i - 1, i + 1);
          node = Binary(left, op, node.parenthesize());
        }
        node = Binary(left, sequences.first.$1, node.parenthesize());

        return (node, null, rest0);
      }
    };
  }

  ParseResult Function(String) parseAtomic;
  ParseResult Function(String) parseUnary;
  ParseResult Function(String) parseAnd;
  ParseResult Function(String) parseXor;
  ParseResult Function(String) parseOr;
  ParseResult Function(String) parseImplies;
  late ParseResult Function(String) recurse;

  parseAtomic = (String input) {
    if (Tokenizer.identifier.exec(input) case [_, String value, String rest]) {
      return (Atomic(value), null, rest);
    } else if (Tokenizer.leftParenthesis.exec(input) case [_, "(", String rest1]) {
      var (Node? inner, String? err, String rest2) = recurse(rest1);
      if (err != null) {
        return (null, err, rest1);
      }

      if (Tokenizer.rightParenthesis.exec(rest2) case [_, ")", String rest3] when inner != null) {
        return (Parenthesis("(", inner, ")"), null, rest3);
      } else {
        return (null, "Unterminated ')' at \"$rest1\" from \"$input\"", rest1);
      }
    }

    return (null, 'Cannot parse atomic at input: "$input"', input);
  };

  parseUnary = (String input) {
    if (Tokenizer.not.exec(input) case [_, String _, String rest1]) {
      var (Node? inner, String? err, String rest2) = parseAtomic(rest1);
      if (inner != null && err == null) {
        return (Unary(UnaryOp.not, inner), null, rest2);
      }
    }
    return parseAtomic(input);
  };

  parseAnd = binary(parseUnary, Tokenizer.and, BinaryOp.and, Associativity.left);
  parseXor = binary(parseAnd, Tokenizer.xor, BinaryOp.xor, Associativity.left);
  parseOr = binary(parseXor, Tokenizer.or, BinaryOp.or, Associativity.left);
  parseImplies = binary(parseOr, Tokenizer.implies, BinaryOp.implies, Associativity.right);

  recurse = parseImplies;

  var (Node? result, String? error, _) = recurse(input);

  if (result == null || error != null) {
    throw Exception(error);
  }
  return result;
}

bool evaluate(Node node, Environment environment) {
  if (environment[node] case bool value) {
    return value;
  }

  switch (node) {
    case Parenthesis(:Node mid):
      return environment[node] = evaluate(mid, environment);
    case Binary(:Node left, :BinaryOp mid, :Node right):
      switch (mid) {
        case BinaryOp.and:
          return environment[node] = evaluate(left, environment) & evaluate(right, environment);
        case BinaryOp.or:
          return environment[node] = evaluate(left, environment) | evaluate(right, environment);
        case BinaryOp.xor:
          return environment[node] = evaluate(left, environment) ^ evaluate(right, environment);
        case BinaryOp.implies:
          return environment[node] = !evaluate(left, environment) | evaluate(right, environment);
      }
    case Unary(:UnaryOp op, :Node value):
      switch (op) {
        case UnaryOp.not:
          return environment[node] = true ^ evaluate(value, environment);
      }
    case Atomic(:String value):
      if (environment[node] case bool b) {
        return b;
      }
      throw Exception("Atomic node '$value' is not defined!");
  }
}

Set<Atomic> variables(Node node) {
  return switch (node) {
    Parenthesis(:Node mid) => variables(mid),
    Binary(:Node left, :Node right) => <Atomic>{...variables(left), ...variables(right)},
    Unary(:Node value) => <Atomic>{...variables(value)},
    Atomic() => <Atomic>{node},
  };
}

List<Environment> truthValues(Node node) {
  List<Atomic> vars = variables(node).toList().reversed.toList();
  List<Environment> result = <Environment>[];

  Iterable<List<bool>> permute(int n) sync* {
    if (n <= 0) {
      yield <bool>[];
      return;
    }

    for (List<bool> permutations in permute(n - 1)) {
      yield <bool>[false, ...permutations];
      yield <bool>[true, ...permutations];
    }
  }

  for (List<bool> startingValues in permute(vars.length)) {
    Environment environment = Environment();
    for (int i = vars.length - 1; i >= 0; --i) {
      environment[vars[i]] = startingValues[i];
    }

    result.add(environment);
  }

  return result;
}

void truthTable(Node node) {
  List<List<int>> results = <List<int>>[];

  List<String>? labels;
  for (Environment env in truthValues(node)) {
    evaluate(node, env);

    List<(Node, int)> values = <(Node, int)>[];
    for (var (Node key, bool value) in env.pairs) {
      if (key is Parenthesis) {
        continue;
      }

      values.add((key, value ? 1 : 0));
    }

    labels ??= values.map(((Node, int) node) => " ${node.$1} ").toList();
    results.add(values.map(((Node, int) pair) => pair.$2).toList());
  }

  List<List<String>> matrix = <List<String>>[
    labels!,
    List<String>.filled(results[0].length, "--"),
    ...<List<String>>[
      for (List<int> values in results) //
        <String>[for (int value in values) value.toString()],
    ],
  ];
  List<int> profiles = List<int>.generate(
    matrix[0].length,
    (int x) => matrix.map((List<String> row) => row[x].length).fold(0, max),
  );

  List<List<String>> padded = <List<String>>[
    for (List<String> row in matrix)
      <String>[
        for (int x = 0; x < row.length; ++x) //
          if ((row[x], profiles[x]) case (String v, int width))
            if (v.startsWith("-") && v.endsWith("-"))
              v.padLeft((width / 2).ceil(), "-").padRight(width, "-")
            else
              v.padLeft((width / 2).ceil()).padRight(width),
      ],
  ];

  String joined = padded
      .map(
        (List<String> row) => row.every((String v) => v.startsWith("-") && v.endsWith("-")) //
            ? row.join("+")
            : row.join("|"),
      )
      .join("\n");

  print(joined);
}

void main() {
  truthTable(parse("a implies b implies c -> d"));
}

extension on RegExp {
  List<String?>? exec(String input, [int index = 0]) {
    if (this.matchAsPrefix(input, index) case RegExpMatch match) {
      if (match.groups(<int>[for (int i = 0; i < match.groupCount + 1; ++i) i]) case List<String?> matches) {
        return matches;
      }
    }
    return null;
  }
}

extension<K, V> on Map<K, V> {
  Iterable<(K, V)> get pairs sync* {
    for (var MapEntry<K, V>(:K key, :V value) in entries) {
      yield (key, value);
    }
  }
}
