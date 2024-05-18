// ignore_for_file: avoid_dynamic_calls, unreachable_from_main

import "dart:collection";

typedef Command = int? Function(Engine);

Command push(Object? value) => (Engine engine) {
      engine.push(value);

      return null;
    };
Command echo() => (Engine engine) {
      print(engine.stack.last);

      return null;
    };

Command increment() => (Engine engine) {
      int value = engine.pop<int>();
      engine.push(value + 1);

      return null;
    };
Command decrement() => (Engine engine) {
      int value = engine.pop<int>();
      engine.push(value - 1);

      return null;
    };

Command compare(bool Function(num, num) callback) => (Engine engine) {
      num right = engine.pop();
      num left = engine.pop();
      bool result = callback(left, right);
      engine.stack.addLast(result);

      return null;
    };

Command lessThan() => compare((num l, num r) => l < r);
Command greaterThan() => compare((num l, num r) => l > r);

Command conditionalJump(int index) => (Engine engine) {
      if (engine.pop()) {
        return index;
      }
      return null;
    };

class Engine {
  Engine(this.commands);
  List<Command> commands;
  Queue<dynamic> stack = Queue<dynamic>();

  int position = 0;

  R pop<R>() {
    dynamic removed = stack.removeLast();
    if (removed is! R) {
      throw StateError("Expected type $R, received ${removed.runtimeType}");
    }
    return removed;
  }

  bool get isFinished => position >= commands.length;
  bool get isNotFinished => position < commands.length;

  void step() {
    if (position >= commands.length) {
      throw StateError("It is over.");
    }
    position = commands[position](this) ?? position + 1;
  }

  void push(Object? value) => stack.addLast(value);
}

void main() {
  Engine engine = Engine(<Command>[
    push(1),
    echo(),
    push(2),
    echo(),
    greaterThan(),
    conditionalJump(0),
  ]);
  while (engine.isNotFinished) {
    engine.step();
  }
}
