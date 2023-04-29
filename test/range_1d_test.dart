import "package:test/test.dart";

import "../bin/data_structeur/range_1d.dart";
import "shared.dart";

void main() {
  group("range unit", () {
    test("is continuous", () {
      Range range = Range.unit(3, 10);
      int? previous;
      for (int value in range) {
        if (previous != null) {
          expect(value - previous, equals(1));
        }
        previous = value;
      }
    });

    test("is empty when invalid", () {
      Range range = Range.unit(25, 5);
      expect(range, equals(Range.empty()));
    });

    test("is equal to sets", () {
      Range range = Range.unit(0, 5);
      expect(range.toSet(), unorderedEquals(<int>{0, 1, 2, 3, 4}));
    });

    test("does not include the last element", () {
      Range range = Range.unit(3, 8);
      expect(range.contains(8), equals(false));
    });

    test("has proper length", () {
      Range range = Range.unit(2, 6);
      expect(range.length, equals(4));
    });

    test("combines properly", () {
      RangeUnit left = RangeUnit(2, 12);
      RangeUnit right = RangeUnit(4, 20);
      Range combination = left.combination(right);

      expect(
          combination,
          isA<RangeUnit>()
              .having((RangeUnit unit) => unit.start, "start", equals(2))
              .having((RangeUnit unit) => unit.end, "end", equals(20))
              .having((RangeUnit unit) => unit.length, "length", equals(18)));
    });

    group("computes", () {
      /// [a, b] - [c, d]

      /// ---a---b----
      /// -c---d------
      test("left superior difference", () {
        Range left = Range.unit(2, 5);
        Range right = Range.unit(1, 3);

        expect(left - right, equals(Range.unit(3, 5)));
      });

      /// -a-------b---
      /// ---c--d------
      test("inferior difference", () {
        Range left = Range.unit(1, 10);
        Range right = Range.unit(4, 8);

        expect(left - right, equals(Range.unit(1, 4) | Range.unit(8, 10)));
      });

      /// -a----b----
      /// ---c----d--
      test("right-superior difference", () {
        Range left = Range.unit(2, 5);
        Range right = Range.unit(4, 7);

        expect(left - right, equals(Range.unit(2, 4)));
      });

      /// -a--b-----
      /// ------c--d
      test("right non-intersection difference", () {
        Range left = Range.unit(2, 5);
        Range right = Range.unit(8, 10);

        expect(left - right, equals(left));
      });

      /// ------a--b
      /// -c--d-----
      test("left non-intersection difference", () {
        Range left = Range.unit(8, 10);
        Range right = Range.unit(2, 5);

        expect(left - right, equals(left));
      });

      /// ---a--b---
      /// --c-----d-
      test("superior difference", () {
        Range left = Range.unit(5, 10);
        Range right = Range.unit(2, 12);

        expect(left - right, equals(Range.empty()));
      });
    });

    group("predicates", () {
      test("covers", () {
        Range superior = Range.unit(3, 20);
        Range inferior = Range.unit(4, 8);

        expect(superior.covers(inferior), equals(true));
        expect(inferior.covers(superior), equals(false));
      });

      test("intersects", () {
        Range left = Range.unit(2, 8);
        Range right = Range.unit(6, 12);

        expect(left.intersects(right), equals(right.intersects(left)) & equals(true));
      });

      test("contains", () {
        Range range = Range.unit(0, 100);

        expect(range.contains(0), equals(true)); // Inclusive start
        expect(range.contains(50), equals(true));
        expect(range.contains(100), equals(false)); // Exclusive end
      });
    });
  });

  group("general range", () {
    test("unions are not covered unless full", () {
      Range lhs = Range.unit(2, 8) | Range.unit(9, 20);
      Range rhs = Range.unit(3, 18);
      Range lhsConnected = lhs | Range.unit(6, 10);

      expect(lhs.covers(rhs), equals(false));
      expect(lhsConnected.covers(rhs), equals(true));
    });
  });

  group("right hand null", () {
    Range rhs = Range.empty();

    test("unions are unchanged", () {
      Range lhs = Range.unit(4, 20);

      expect(lhs | rhs, equals(lhs));
      expect(rhs | lhs, equals(lhs));
    });

    test("intersections are null", () {
      Range lhs = Range.unit(2, 5);

      expect(lhs & rhs, equals(rhs));
      expect(rhs & lhs, equals(rhs));
    });

    test("differences are unchanged", () {
      Range lhs = Range.unit(0, 10);

      expect(lhs - rhs, equals(lhs));
    });
  });
}
