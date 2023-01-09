// ignore_for_file: prefer_constructors_over_static_methods

import "dart:math";

sealed class Range extends Iterable<int> {
  const Range();

  factory Range.unit(int start, int end) = RangeUnit;
  factory Range.union(Set<RangeUnit> units) = RangeUnion;
  factory Range.fromSet(Set<int> numbers) {
    List<int> sorted = numbers.toList()..sort();
    Set<RangeUnit> runs = {};

    int? start;
    for (int i = 0; i < sorted.length; ++i) {
      start = sorted[i];

      while (i + 1 < sorted.length && sorted[i + 1] - sorted[i] == 1) {
        i++;
      }

      runs.add(RangeUnit(start, sorted[i] + 1));
    }


    return RangeUnion(runs);
  }

  Range intersection(Range other);
  Range union(Range other);
  Range difference(Range other);

  bool intersects(Range other);
  bool covers(Range other);

  bool includes(int value);

  Range operator |(Range other) => union(other);
  Range operator &(Range other) => intersection(other);
}


class RangeUnit extends Range {
  static const RangeUnit _nil = RangeUnit.nil();

  final int start;
  final int end;

  factory RangeUnit(int start, int end) {
    if (end < start) {
      return _nil;
    } else {
      return RangeUnit._(start, end);
    }
  }
  const RangeUnit._(this.start, this.end);
  const RangeUnit.nil(): start = 0, end = -1;

  RangeUnit combination(RangeUnit other) {
    int start = min(this.start, other.start);
    int end = max(this.end, other.end);
    if (start > end) return _nil;

    return RangeUnit(start, end);
  }

  @override
  bool covers(Range other) {
    if (other case RangeUnit unit) {
      return this.start <= other.start && this.end >= other.end;
    } else if (other case RangeUnion union) {
      return this.covers(union.contingent());
    }
    return false;
  }
  
  @override
  Range difference(Range other) {
    if (!this.intersects(other)) return this;

    if (other case RangeUnit unit) {
      RangeUnit left = RangeUnit(min(start, other.start), other.start);
      RangeUnit right = RangeUnit(other.end, max(other.end - 1, end - 1));

      return RangeUnion({
        if (left.isNotEmpty) left,
        if (right.isNotEmpty) right,
      });
    } else if (other case RangeUnion union) {
      return union.units.fold(this, (value, unit) => value.difference(unit));
    }

    throw Error();
  }

  @override
  bool intersects(Range other) {
    if (other case RangeUnit unit) {
      return !(this.start > other.end || this.end <= other.start);
    } else if (other case RangeUnion union) {
      return union.units.any(this.intersects);
    }
    return false;
  }
  
  @override
  Range intersection(Range other) {
    if (this == _nil || other == _nil || !this.intersects(other)) return _nil;

    if (other case RangeUnit unit) {
      int start = max(this.start, unit.start);
      int end = min(this.end, unit.end);
      if (end < start) return _nil;

      return RangeUnit(start, end);
    } else if (other case RangeUnion union) {
      return union.units.fold(this, (l, r) => r.intersection(l));
    }

    throw Error();
  }
  
  @override
  Range union(Range other) {
    if (this == _nil) return other;
    if (other == _nil) return this;

    /// At this point, neither of them should be empty.

    if (!this.intersects(other)) {
      /// Since this doesn't intersect, then

      if (other case RangeUnit unit) {
        /// If the rhs is a unit, then we just add it to a union.
        
        return RangeUnion({this, other});
      } else if (other case RangeUnion union) {
        /// If the rhs is a union, then we include the units of the union.

        return RangeUnion({this, ...union.units});
      }

      /// Since [RangeUnit] and [RangeUnion] are exhaustive, this is dead code.
      throw Error();
    }

    /// At this point, it's guaranteed to intersect somewhere.
    if (other case RangeUnit unit) {
      return this.combination(other);
    } else if (other case RangeUnion union) {
      return union.units.fold(this, (l, r) => l.union(r));
    }

    /// Since [RangeUnit] and [RangeUnion] are exhaustive, this is dead code.
    throw Error();
  }

  @override
  bool includes(int value) {
    return start <= value && value < end;
  }

  @override
  int get length => end - start;

  @override
  Iterator<int> get iterator => () sync* {
    for (int i = start; i < end; ++i) {
      yield i;
    }
  }().iterator;

  @override
  String toString() => this == _nil ? "∅" : "[$start, $end)";

  @override
  bool operator ==(Object? other) =>
    other is RangeUnit && start == other.start && end == other.end;

  @override
  int get hashCode => (start, end).hashCode;
}

class RangeUnion extends Range {
  final Set<RangeUnit> units;

  const RangeUnion(this.units);

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
    return units.any((r) => r.covers(other));
  }
  
  @override
  Range difference(Range other) {
    Set<RangeUnit> units = {};
    for (RangeUnit unit in this.units) {
      Range difference = unit.difference(other);
      if (difference case RangeUnit unit && != RangeUnit._nil) {
        units.add(unit);
      } else if (difference case RangeUnion union) {
        units.addAll(union.units);
      }
    }

    return RangeUnion(units);
  }

  @override
  Range intersection(Range other) {
    return units.fold(other, (r, unit) => unit.intersection(r));
  }
  
  @override
  bool intersects(Range other) {
    return units.any((r) => r.intersects(other));
  }
  
  @override
  Range union(Range other) {
    return units.fold(other, (r, unit) => unit.union(r));
  }

  @override
  bool includes(int value) {
    return units.isNotEmpty && units.any((u) => u.contains(value));
  }

  @override
  int get length => units.map((u) => u.length).reduce((a, b) => a + b);

  @override
  Iterator<int> get iterator => () sync* {
    for (RangeUnit unit in units) {
      for (int v in unit) {
        yield v;
      }
    }
  }().iterator;

  @override
  String toString() => units.join(" | ");
}
