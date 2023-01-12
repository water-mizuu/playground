import 'data_structeur/range_1d.dart';
import "math/shared.dart";

void main(List<String> args) async {
  Range left = Range.unit(1, 10);
  Range right = Range.unit(5, 14);

  Range operation = left ^ right;

  print("A = ${operation.toSet()}");
  print(left - right);

  print(4.re + 3.im);
}
