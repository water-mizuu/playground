import "dart:math" as math;

sealed class Range {
  const factory Range.single(num value) = RangeSingle;
  factory Range.unit(num start, num end, {bool isStartInclusive = false, bool isEndInclusive = false}) {
    if (end == start) {
      if (isStartInclusive && isEndInclusive) {
        return Range.single(start);
      } else {
        return const Range.empty();
      }
    }
    if (end < start) {
      return const Range.empty();
    }
    return RangeUnit(start, end, isStartInclusive: isStartInclusive, isEndInclusive: isEndInclusive);
  }

  factory Range.union(Set<RangeUnit> units) {
    units = <RangeUnit>{
      for (RangeUnit unit in units)
        if (unit.isNotEmpty) unit,
    };
    if (units.isEmpty) {
      return const Range.empty();
    }
    return RangeUnion(units);
  }

  const factory Range.empty() = RangeEmpty;

  bool contains(num value);

  /// Returns `true` if the [Range] `this` covers or is a superset of another [Range]
  bool covers(Range other);

  /// Returns `true` if the [Range] intersects with another [Range].
  bool intersects(Range other);

  /// Returns the difference of two ranges. If the rhs (right hand side) does not
  ///   intersect with the lhs (left hand side), then the lhs is returned unmodified.
  Range difference(Range other);

  /// Returns the intersection (common element) of a range.
  Range intersection(Range other);

  /// Returns the union of a range. It is not guaranteed to return a [RangeUnion].
  Range union(Range other);

  /// Returns the length of the range.
  num get length;
}

/// A union of range units or range singles.
final class RangeUnion implements Range {
  const RangeUnion(this.ranges);

  final Set<RangeBase> ranges;

  @override
  bool covers(Range other) => ranges.any((RangeBase r) => r.covers(other));

  @override
  Range difference(Range other) {
    if (!this.intersects(other)) {
      return this;
    }

    Set<RangeBase> units = <RangeBase>{};
    for (RangeBase unit in this.ranges) {
      switch (unit.difference(other)) {
        case RangeUnit difference when difference != const Range.empty():
          units.add(difference);
        case RangeUnion difference:
          units.addAll(difference.ranges);
        case RangeEmpty _:
        default:
          break;
      }
    }

    return RangeUnion(units);
  }

  @override
  Range intersection(Range other) => ranges.fold(other, (Range r, RangeBase unit) => unit.intersection(r));

  @override
  bool intersects(Range other) => ranges.any((RangeBase r) => r.intersects(other));

  @override
  Range union(Range other) => ranges.fold(other, (Range r, RangeBase unit) => unit.union(r));

  @override
  bool contains(Object? value) => value is num && ranges.isNotEmpty && ranges.any((RangeBase u) => u.contains(value));

  @override
  num get length => ranges.map((RangeBase u) => u.length).fold(0, (num a, num b) => a + b);

  @override
  String toString() => isEmpty ? "∅" : ranges.join(" | ");
}

class RangeEmpty implements Range {
  const RangeEmpty();

  @override
  bool contains(num value) => false;

  @override
  bool covers(Range other) => other is RangeEmpty;

  @override
  Range difference(Range other) => this;

  @override
  Range intersection(Range other) => this;

  @override
  bool intersects(Range other) => false;

  @override
  Range union(Range other) => other;

  @override
  int get length => 0;

  @override
  String toString() => "∅";
}

sealed class RangeBase implements Range {}

final class RangeSingle implements RangeBase {
  const RangeSingle(this.value);

  final num value;

  @override
  bool contains(num value) => this.value == value;

  @override
  bool covers(Range other) => other is RangeSingle && other.value == value;

  @override
  Range difference(Range other) => switch (this.intersects(other)) {
        true => const Range.empty(),
        false => this,
      };

  @override
  bool intersects(Range other) => switch (other) {
        RangeUnion(:Set<RangeBase> ranges) => ranges.any(this.intersects),
        RangeEmpty() => false,
        RangeSingle(:num value) => this.value == value,

        /// A range unit is a open interval between two, (min, max). Both are exclusive.
        RangeUnit(:num start, :num end) => start < value && value < end,
      };

  @override
  Range intersection(Range other) => switch (this.intersects(other)) {
        true => this,
        false => const Range.empty(),
      };

  @override
  Range union(Range other) {
    if (other.isEmpty) {
      return this;
    }

    if (!this.intersects(other)) {
      /// Since this doesn't intersect, then

      return switch (other) {
        RangeUnion() => RangeUnion(<RangeBase>{this, ...other.ranges}),
        RangeBase() => RangeUnion(<RangeBase>{this, other}),
        RangeEmpty() => this,
      };
    } else {
      /// At this point, it's guaranteed to intersect somewhere.
      return switch (other) {
        RangeUnion() => other.ranges.fold(this, (Range l, RangeBase r) => l.union(r)),
        RangeUnit() => other,
        RangeSingle() || RangeEmpty() => this,
      };
    }
  }

  @override
  num get length => 1;

  @override
  String toString() => "{$value}";
}

/// A closed interval between two, (min, max). Both are exclusive.
final class RangeUnit implements RangeBase {
  const RangeUnit(this.start, this.end, {this.isStartInclusive = false, this.isEndInclusive = false});

  final bool isStartInclusive;
  final bool isEndInclusive;

  final num start;
  final num end;

  /// Returns the contingent combination of two [RangeUnit]s,
  ///   returning an equivalent [RangeUnit]
  Range combination(RangeUnit other) {
    num start = math.min(this.start, other.start);
    num end = math.max(this.end, other.end);
    if (start >= end) {
      return const Range.empty();
    }

    return Range.unit(start, end);
  }

  @override
  bool contains(num value) =>
      (start < value && value < end) || //
      (isStartInclusive && value == start) ||
      (isEndInclusive && value == end);

  @override
  bool covers(Range other) => other is RangeSingle && contains(other.value);

  @override
  bool intersects(Range other) => switch (other) {
        RangeUnion(:Set<RangeBase> ranges) => ranges.any(intersects),
        RangeSingle(:num value) => contains(value),
        RangeUnit() => !(this.start > other.end || this.end <= other.start),
        RangeEmpty() => false,
      };

  @override
  Range difference(Range other) => !this.intersects(other)
      ? this
      : switch (other) {
          RangeUnion(:Set<RangeBase> ranges) =>
            ranges.fold(this, (Range self, RangeBase base) => self.difference(base)),
          RangeSingle(:num value) => RangeUnion(<RangeBase>{
              if (Range.unit(start, value) case RangeBase base) base,
              if (Range.unit(value, end) case RangeBase base) base,
            }),
          RangeUnit(:num start, :num end) => RangeUnion(<RangeBase>{
              if (Range.unit(math.min(this.start, start), start) case RangeBase base) base,
              if (Range.unit(end, math.max(this.end, end)) case RangeBase base) base,
              Range.single(start) as RangeBase,
              Range.single(end) as RangeBase,
            }),
          RangeEmpty() => this,
        };

  @override
  Range intersection(Range other) => switch (this.isEmpty || other.isEmpty || !this.intersects(other)) {
        true => const Range.empty(),
        false => switch (other) {
            RangeUnit(:num start, :num end) => Range.unit(math.max(this.start, start), math.min(this.end, end)),
            RangeUnion(:Set<RangeBase> ranges) => ranges.fold(this, (Range l, RangeBase r) => l.intersection(r)),
            RangeSingle() => this,
            RangeEmpty() => other,
          },
      };

  @override
  Range union(Range other) {
    if (this.isEmpty) {
      return other;
    }
    if (other.isEmpty) {
      return this;
    }

    if (!this.intersects(other)) {
      /// Since this doesn't intersect, then

      return switch (other) {
        RangeUnion() => RangeUnion(<RangeBase>{this, ...other.ranges}),
        RangeBase() => RangeUnion(<RangeBase>{this, other}),
        RangeEmpty() => this,
      };
    } else {
      /// At this point, it's guaranteed to intersect somewhere.
      return switch (other) {
        RangeUnion() => other.ranges.fold(this, (Range l, RangeBase r) => l.union(r)),
        RangeUnit() => this.combination(other),
        RangeSingle() || RangeEmpty() => this,
      };
    }
  }

  @override
  num get length => end - start;

  @override
  String toString() => "${isStartInclusive ? "[" : "("}$start, $end${isStartInclusive ? "]" : ")"}";
}

extension GlobalRangeExtension on Range {
  Range operator -(Range other) => this.difference(other);
  Range operator &(Range other) => this.intersection(other);
  Range operator |(Range other) => this.union(other);

  bool get isEmpty => length == 0;
  bool get isNotEmpty => length != 0;
}
