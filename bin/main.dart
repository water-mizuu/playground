import "data_structeur/avl_tree.dart";
import "data_structeur/range_union.dart";

void main(List<String> args) async {
  var unit = Range.unit(2, 10);
  var union = Range.unit(3, 5) | Range.unit(8, 10);

  print(Range.fromSet({1, 2, 3, 5, 6, 7}));
  print(Range.fromSet({1, 8150125, 12489, 13, 14, 15, 16, 2, 3, 4, 5}).length);

  print(unit.difference(union));
  print("TARGET: [2, 3) | [5, 8)");
  print("ACTUAL: ${unit.difference(union)}");

  print(Range.unit(1, 1).length);
}
