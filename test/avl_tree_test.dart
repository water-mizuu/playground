import "package:test/test.dart";

import "../bin/data_structeur/avl_tree.dart";
import "shared.dart";

void main() {
  group("avl-node", () {
    AvlTree<int> tree = AvlTree<int>();

    test("adds items and remains balanced", () {
      expect(tree.add(4), equals(true));
      expect(tree.add(4), equals(false));

      expect(tree.add(5), equals(true));
      expect(tree.add(5), equals(false));

      expect(tree.add(21), equals(true));
      expect(tree.add(-3), equals(true));

      expect(tree.head.balanceFactor, equals(-1) | equals(0) | equals(1));
    });

    test("removes successfully", () {
      expect(tree.remove(43), equals(false));
      expect(tree.remove(-3), equals(true));
      expect(tree.remove(21), equals(true));

      expect(tree.head.balanceFactor, equals(-1) | equals(0) | equals(1));
    });
  });
}
