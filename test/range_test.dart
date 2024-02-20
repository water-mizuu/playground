import "package:test/test.dart";

import "../bin/range.dart";

void main() {
  group("range", () {
    group("single", () {
      test("instantiates properly", () {
        Range range = const Range.single(3);

        expect(range, isA<RangeSingle>().having((RangeSingle range) => range.value == 3, "Value", isTrue));
      });

      test("contains", () {
        Range range = const Range.single(3);

        expect(range.contains(3), isTrue);
        expect(range.contains(4), isFalse);
      });

      test("covers", () {
        Range range = const Range.single(3);

        expect(range.covers(const Range.single(3)), isTrue);
        expect(range.covers(const Range.single(4)), isFalse);
      });

      test("length is valid", () {
        Range range = const Range.single(3);

        expect(range.length, equals(1));
        expect(range.isEmpty, isFalse);
      });

      test("intersects", () {
        Range range = const Range.single(3);

        expect(range.intersects(const Range.single(3)), isTrue);
        expect(range.intersects(const Range.single(4)), isFalse);
      });

      test("difference", () {
        Range range = const Range.single(3);

        expect(range.difference(const Range.single(3)), isA<RangeEmpty>());
        expect(range.difference(const Range.single(4)), equals(range));
      });

      test("intersection", () {
        Range range = const Range.single(3);

        expect(range.intersection(const Range.single(3)), equals(range));
        expect(range.intersection(const Range.single(4)), isA<RangeEmpty>());
      });

      test("union", () {
        Range range = const Range.single(3);

        expect(range.union(const Range.single(3)), equals(range));
        expect(
          range.union(const Range.single(4)),
          isA<RangeUnion>()
              .having((RangeUnion union) => union.contains(3), "Contains 3", isTrue)
              .having((RangeUnion union) => union.contains(4), "Contains 4", isTrue)
              .having((RangeUnion union) => union.contains(2.5), "Not before", isFalse)
              .having((RangeUnion union) => union.contains(3.5), "Not in between", isFalse)
              .having((RangeUnion union) => union.contains(4.5), "Not after", isFalse),
        );
      });

      test("toString", () {
        Range range = const Range.single(3);

        expect(range.toString(), equals("{3}"));
      });
    });

    group("unit", () {
      test("instantiates properly", () {
        Range range = Range.unit(3, 5);

        expect(
          range,
          isA<RangeUnit>()
              .having((RangeUnit range) => range.start == 3, "Start", isTrue)
              .having((RangeUnit range) => range.end == 5, "End", isTrue),
        );
      });

      group("with equal arguments", () {
        test("instantiates into empty if both are exclusive", () {
          Range range = Range.unit(3, 3);

          expect(range, isA<RangeEmpty>());
        });

        test("instantiates into empty if only left is inclusive", () {
          Range range = Range.unit(3, 3, isStartInclusive: true);

          expect(range, isA<RangeEmpty>());
        });

        test("instantiates into empty if only right is inclusive", () {
          Range range = Range.unit(3, 3);

          expect(range, isA<RangeEmpty>());
        });

        test("instantiates into single if both are inclusive", () {
          Range range = Range.unit(3, 3, isStartInclusive: true, isEndInclusive: true);

          expect(range, isA<RangeSingle>().having((RangeSingle range) => range.value == 3, "Value", isTrue));
        });
      });
    });
  });
}
