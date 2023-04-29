// ignore_for_file: avoid_returning_this

import "dart:collection";
import "dart:math" as math;

extension AvlTreeNodeNullableMethods<E> on AvlTreeNode<E>? {
  int get height {
    AvlTreeNode<E>? self = this;
    if (self == null) {
      return 0;
    }

    return 1 + math.max(self.left.height, self.right.height);
  }

  int get balanceFactor {
    AvlTreeNode<E>? self = this;
    if (self == null) {
      return 0;
    }

    int leftHeight = self.left.height;
    int rightHeight = self.right.height;

    return leftHeight - rightHeight;
  }
}

class AvlTreeNode<E> {
  static final math.Random _random = math.Random();
  final int Function(E, E) comparison;

  E value;
  AvlTreeNode<E>? left;
  AvlTreeNode<E>? right;

  AvlTreeNode({required this.value, required this.comparison, this.left, this.right});

  AvlTreeNode<E> _rotateLeft() {
    AvlTreeNode<E> rightChild = this.right!;
    AvlTreeNode<E>? temp = rightChild.left;
    rightChild.left = this;
    this.right = temp;

    return rightChild;
  }

  AvlTreeNode<E> _rotateRight() {
    AvlTreeNode<E> leftChild = this.left!;
    AvlTreeNode<E>? temp = leftChild.right;
    leftChild.right = this;
    this.left = temp;

    return leftChild;
  }

  AvlTreeNode<E> _balance() {
    int factor = balanceFactor;

    if (factor > 1) {
      if (left.balanceFactor > 0) {
        return _rotateRight();
      } else {
        left = left?._rotateLeft();
        return _rotateRight();
      }
    } else if (factor < -1) {
      if (right.balanceFactor < 0) {
        return _rotateLeft();
      } else {
        right = right?._rotateRight();
        return _rotateLeft();
      }
    }

    return this;
  }

  String asciiTree({String indent = "", bool isLast = true}) {
    StringBuffer buffer = StringBuffer();
    String marker = isLast ? "└─" : "├─";

    buffer
      ..write(indent)
      ..write(marker)
      ..write(" ");
    buffer.writeln("$value");

    String newIndent = "$indent${isLast ? "   " : "│  "}";
    AvlTreeNode<void>? last = right ?? left;
    AvlTreeNode<void>? pre = last == left ? null : left;

    buffer.write(pre?.asciiTree(indent: newIndent, isLast: false) ?? "");
    buffer.write(last?.asciiTree(indent: newIndent) ?? "");

    return buffer.toString();
  }

  (AvlTreeNode<E>, bool) add(E value) {
    bool inserted = false;
    if (comparison(value, this.value) < 0) {
      var (AvlTreeNode<E> node, bool _inserted) =
          this.left?.add(value) ?? (AvlTreeNode<E>(value: value, comparison: comparison), true);

      inserted = _inserted;
      this.left = node;
    } else if (comparison(value, this.value) > 0) {
      var (AvlTreeNode<E> node, bool _inserted) =
          this.right?.add(value) ?? (AvlTreeNode<E>(value: value, comparison: comparison), true);

      inserted = _inserted;
      this.right = node;
    }

    return (this._balance(), inserted);
  }

  (AvlTreeNode<E>?, bool) remove(E value) {
    bool removed = false;
    int compare = comparison(value, this.value);

    if (compare < 0) {
      if (this.left case AvlTreeNode<E> left) {
        var (AvlTreeNode<E>? node, bool _removed) = left.remove(value);
        this.left = node;
        removed = _removed;
      }
    } else if (compare > 0) {
      if (this.right case AvlTreeNode<E> right) {
        var (AvlTreeNode<E>? node, bool _removed) = right.remove(value);
        this.right = node;
        removed = _removed;
      }
    } else {
      if (this.left == null) {
        return (this.right, true);
      } else if (this.right == null) {
        return (this.left, true);
      } else {
        if (this.right case AvlTreeNode<E> right) {
          E value = right.minValueNode.value;
          var (AvlTreeNode<E>? node, bool _removed) = right.remove(value);
          this.value = value;
          this.right = node;
          removed = _removed;
        }
      }
    }

    return (this._balance(), removed);
  }

  AvlTreeNode<E>? lookup(E value) {
    int key = comparison(value, this.value);
    if (key < 0) {
      return left?.lookup(value);
    } else if (key > 0) {
      return right?.lookup(value);
    } else if (key == 0) {
      return this;
    }
    return null;
  }

  AvlTreeNode<E> random(Expando<int> expando) {
    int r = _random.nextInt(expando[this] ??= length);

    if (r == 0) {
      return this;
    } else if (left case AvlTreeNode<E> left) {
      if (1 <= r && r <= left.length) {
        return left.random(expando);
      }
    }

    return right?.random(expando) ?? this;
  }

  AvlTreeNode<E> get minValueNode {
    AvlTreeNode<E>? left = this.left;
    if (left == null) {
      return this;
    }
    return left.minValueNode;
  }

  int get length => 1 + (left?.length ?? 0) + (right?.length ?? 0);

  @override
  String toString() => "[$value, $left, $right]";
}

class AvlTree<E> extends Iterable<E> with SetMixin<E> {
  final int Function(E, E) comparison;
  AvlTreeNode<E>? head;

  AvlTree([int Function(E, E)? comparison])
      : comparison = comparison ?? ((E a, E b) => (a as Comparable<dynamic>).compareTo(b));

  factory AvlTree.from(Iterable<E> iterable, [int Function(E, E)? comparison]) {
    AvlTree<E> tree = AvlTree<E>(comparison);
    tree.addAll(iterable);

    return tree;
  }

  @override
  int get length => head?.length ?? 0;

  @override
  bool add(E value) {
    if (head case AvlTreeNode<E> head) {
      var (AvlTreeNode<E> node, bool found) = head.add(value);
      this.head = node;

      return found;
    } else {
      this.head = AvlTreeNode<E>(value: value, comparison: comparison);

      return true;
    }
  }

  @override
  bool remove(Object? value) {
    if (value is! E) {
      return false;
    }

    if (this.head case AvlTreeNode<E> head) {
      var (AvlTreeNode<E>? newHead, bool removed) = head.remove(value);
      this.head = newHead;

      return removed;
    }
    return false;
  }

  @override
  String toString() => head?.asciiTree() ?? "";

  @override
  Iterator<E> get iterator => () sync* {
        if (this.head case AvlTreeNode<E> head) {
          Queue<AvlTreeNode<E>> stack = Queue<AvlTreeNode<E>>();
          AvlTreeNode<E>? current = head;

          while (true) {
            if (current != null) {
              stack.addLast(current);
              current = current.left;
            } else if (stack.isNotEmpty) {
              current = stack.removeLast();
              yield current.value;
              current = current.right;
            } else {
              break;
            }
          }
        }
      }()
          .iterator;

  @override
  E? lookup(Object? element) {
    if (head == null || element is! E) {
      return null;
    }

    return head?.lookup(element)?.value;
  }

  @override
  AvlTree<E> toSet() {
    AvlTree<E> tree = AvlTree<E>();

    if (head case AvlTreeNode<E> head) {
      Queue<AvlTreeNode<E>> stack = Queue<AvlTreeNode<E>>()..add(head);

      while (stack.isNotEmpty) {
        var AvlTreeNode<E>(
          value: E value,
          left: AvlTreeNode<E>? left,
          right: AvlTreeNode<E>? right,
        ) = stack.removeFirst();

        tree.add(value);

        if (left case AvlTreeNode<E> node) {
          stack.addLast(node);
        }
        if (right case AvlTreeNode<E> node) {
          stack.addLast(node);
        }
      }
    }

    return tree;
  }

  E random() {
    if (head case AvlTreeNode<E> head) {
      return head.random(Expando<int>()).value;
    }
    throw StateError("no element");
  }

  @override
  E get first {
    if (head case AvlTreeNode<E> head) {
      AvlTreeNode<E> node = head;
      while (node.left != null) {
        node = node.left!;
      }

      return node.value;
    }
    throw StateError("no elements");
  }

  @override
  E get last {
    if (head case AvlTreeNode<E> head) {
      AvlTreeNode<E> node = head;
      while (node.right != null) {
        node = node.right!;
      }

      return node.value;
    }
    throw StateError("no elements");
  }
}
