import "dart:collection";
import "dart:math";

class RangeSet with SetMixin<num> implements Set<num> {
  Range inner;

  RangeSet(this.inner);
  RangeSet.empty() : inner = Range.empty();

  @override
  bool add(num value) {
    if (inner.contains(value)) {
      return false;
    }
    int floored = value.floor();
    inner |= Range.unit(floored, floored + 1);

    return true;
  }

  @override
  bool contains(Object? element) {
    return inner.contains(element);
  }

  @override
  Iterator<int> get iterator => inner.iterator;

  @override
  int get length => inner.length;

  @override
  num? lookup(Object? element) {
    return element is num && inner.contains(element) ? element : null;
  }

  @override
  bool remove(Object? value) {
    if (value is! num || !inner.contains(value)) {
      return false;
    }

    int floored = value.floor();
    inner -= Range.unit(floored, floored + 1);

    return true;
  }

  @override
  Set<num> toSet() {
    return RangeSet(inner);
  }

  @override
  String toString() => inner.toString();
}

sealed class Range extends Iterable<int> {
  const Range();

  /// Returns an empty [Range]. The equivalent set of values this iterable has is the empty set.
  const factory Range.empty() = RangeEmpty;

  /// Returns a [RangeUnit]. It represents a continuous set of integers from [start] to [end],
  ///   with an inclusive [start] but an exclusive [end]. This is the smallest unit that a
  ///   [Range] of numbers can be represented with.
  factory Range.unit(int start, int end) {
    if (end <= start) {
      return Range.empty();
    }
    return RangeUnit(start, end);
  }

  /// Returns a [RangeUnion]. This represents a collection of [RangeUnit] that aren't continuous,
  ///   but nevertheless is from the same [Range].
  factory Range.union(Set<RangeUnit> units) {
    units = <RangeUnit>{
      for (RangeUnit unit in units)
        if (unit.isNotEmpty) unit
    };
    if (units.isEmpty) {
      return Range.empty();
    }
    return RangeUnion(units);
  }
  factory Range.fromSet(Set<int> numbers) {
    List<int> sorted = numbers.toList()..sort();
    Set<RangeUnit> runs = <RangeUnit>{};

    int? start;
    for (int i = 0; i < sorted.length; ++i) {
      start = sorted[i];

      while (i + 1 < sorted.length && sorted[i + 1] - sorted[i] == 1) {
        i++;
      }

      runs.add(RangeUnit(start, sorted[i] + 1));
    }

    if (runs case Range(length: 1)) {
      return runs.single;
    }

    return RangeUnion(runs);
  }

  /// Returns the intersection (common element) of a range.
  Range intersection(Range other);

  /// Returns the union of a range.
  Range union(Range other);

  /// Returns the difference of two ranges. If the rhs (right hand side) does not
  ///   intersect with the lhs (left hand side), then the lhs is returned unmodified.
  Range difference(Range other);

  /// Returns `true` if the [Range] intersects with another [Range].
  bool intersects(Range other);

  /// Returns `true` if the [Range] `this` covers or is a superset of another [Range]
  bool covers(Range other);

  @override
  bool contains(Object? value);

  Range operator |(Range other) => union(other);
  Range operator &(Range other) => intersection(other);
  Range operator -(Range other) => difference(other);

  Range operator ^(Range other) => (this | other) - (this & other);

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) => other is Range && this.covers(other) && other.covers(this);

  @override
  String toString() => "∅";
}

class RangeUnit extends Range {
  final int start;
  final int end;

  const RangeUnit(this.start, this.end);

  /// Returns the contingent combination of two [RangeUnit]s,
  ///   returning an equivalent [RangeUnit]
  Range combination(RangeUnit other) {
    int start = min(this.start, other.start);
    int end = max(this.end, other.end);
    if (start >= end) {
      return Range.empty();
    }

    return Range.unit(start, end);
  }

  @override
  bool covers(Range other) {
    return switch (other) {
      RangeUnit other => this.start <= other.start && this.end >= other.end,
      RangeUnion other => other.units.every(this.covers),
      RangeEmpty() => true,
    };
  }

  @override
  Range difference(Range other) => switch (other) {
        void _ when !this.intersects(other) || other.isEmpty => this,
        RangeUnit other => () {
            Range left = Range.unit(min(start, other.start), other.start);
            Range right = Range.unit(other.end, max(other.end, end));

            Set<RangeUnit> units = <RangeUnit>{
              if (left case RangeUnit _) left,
              if (right case RangeUnit _) right,
            };

            if (units.isEmpty) {
              return Range.empty();
            } else if (units.length == 1) {
              return units.single;
            } else {
              return Range.union(units);
            }
          }(),
        RangeUnion other => other.units.fold(this, (Range v, RangeUnit unit) => v.difference(unit)),
        RangeEmpty() => this,
      };

  @override
  bool intersects(Range other) => switch (other) {
        RangeUnit other => !(this.start > other.end || this.end <= other.start),
        RangeUnion other => other.units.any(this.intersects),
        RangeEmpty() => true,
      };

  @override
  Range intersection(Range other) {
    if (this.isEmpty || other.isEmpty) {
      return Range.empty();
    }

    if (!this.intersects(other)) {
      return Range.empty();
    }

    switch (other) {
      case RangeUnit _:
        return Range.unit(max(this.start, other.start), min(this.end, other.end));
      case RangeUnion _:
        return other.units.fold(this, (Range range, RangeUnit unit) => range.intersection(unit));
      case RangeEmpty _:
        return other;
    }
  }

  @override
  Range union(Range other) {
    if (this.isEmpty) {
      return other;
    }
    if (other.isEmpty) {
      return this;
    }

    /// At this point, neither of them should be empty.
    if (other is RangeUnit && other.start - this.end == 0) {
      /// This is a special case for when [a, b) | [b, c)
      ///   can be simplified to [a, c).
      return this.combination(other);
    }

    if (!this.intersects(other)) {
      /// Since this doesn't intersect, then

      return switch (other) {
        RangeUnit other => <RangeUnit>{this, other}.toRangeUnion(),
        RangeUnion other => <RangeUnit>{this, ...other.units}.toRangeUnion(),
        RangeEmpty() => this,
      };
    }

    /// At this point, it's guaranteed to intersect somewhere.
    return switch (other) {
      RangeUnit other => this.combination(other),
      RangeUnion other => other.units.fold(this, (Range l, RangeUnit r) => l.union(r)),
      RangeEmpty() => this,
    };
  }

  @override
  bool contains(Object? value) {
    return value is num && start <= value && value < end;
  }

  @override
  int get length => (end - start).clamp(0, double.maxFinite.toInt());

  @override
  Iterator<int> get iterator => () sync* {
        for (int i = start; i < end; ++i) {
          yield i;
        }
      }()
          .iterator;

  @override
  String toString() => this.isEmpty ? "∅" : "[$start, $end)";

  @override
  bool operator ==(Object other) => other is RangeUnit && start == other.start && end == other.end;

  @override
  int get hashCode => (start, end).hashCode;
}

class RangeUnion extends Range {
  final Set<RangeUnit> units;

  const RangeUnion(this.units);

  /// Returns an "equivalent" [RangeUnit] that contains the same [RangeUnit.start]
  ///   and [RangeUnit.end] as the units leftmost and rightmost unit values.
  RangeUnit contingent() {
    int? start;
    int? end;
    for (RangeUnit unit in units) {
      start ??= unit.start;
      end ??= unit.end;

      start = min(start, unit.start);
      end = max(end, unit.end);
    }

    if (start == null || end == null) {
      throw StateError("Empty union!");
    }

    return RangeUnit(start, end);
  }

  @override
  bool covers(Range other) {
    return units.any((RangeUnit r) => r.covers(other));
  }

  @override
  Range difference(Range other) {
    if (!this.intersects(other)) {
      return this;
    }

    Set<RangeUnit> units = <RangeUnit>{};
    for (RangeUnit unit in this.units) {
      switch (unit.difference(other)) {
        case RangeUnit difference when difference != Range.empty():
          units.add(difference);
          break;
        case RangeUnion difference:
          units.addAll(difference.units);
          break;
        case RangeEmpty _:
        default:
          break;
      }
    }

    return RangeUnion(units);
  }

  @override
  Range intersection(Range other) {
    return units.fold(other, (Range r, RangeUnit unit) => unit.intersection(r));
  }

  @override
  bool intersects(Range other) {
    return units.any((RangeUnit r) => r.intersects(other));
  }

  @override
  Range union(Range other) {
    return units.fold(other, (Range r, RangeUnit unit) => unit.union(r));
  }

  @override
  bool contains(Object? value) {
    return value is num && units.isNotEmpty && units.any((RangeUnit u) => u.contains(value));
  }

  @override
  int get length => units.map((RangeUnit u) => u.length).fold(0, (int a, int b) => a + b);

  @override
  Iterator<int> get iterator => () sync* {
        for (RangeUnit unit in units) {
          for (int v in unit) {
            yield v;
          }
        }
      }()
          .iterator;

  @override
  String toString() => isEmpty ? "∅" : units.join(" | ");
}

class RangeEmpty extends Range {
  const RangeEmpty();

  @override
  bool covers(Range other) {
    return other is RangeEmpty;
  }

  @override
  Range difference(Range other) {
    return this;
  }

  @override
  Range intersection(Range other) {
    return this;
  }

  @override
  bool intersects(Range other) {
    return false;
  }

  @override
  Iterator<int> get iterator => () sync* {}().cast<int>().iterator;

  @override
  Range union(Range other) {
    return other;
  }

  @override
  int get length => 0;

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  bool operator ==(Object other) => other is RangeEmpty;

  @override
  int get hashCode => const <int>{}.hashCode;

  @override
  String toString() => "∅";
}

extension on Set<RangeUnit> {
  RangeUnion toRangeUnion() => RangeUnion(this);
}
