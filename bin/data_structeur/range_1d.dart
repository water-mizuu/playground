import "dart:math";

sealed class Range extends Iterable<int> {
  const Range();

  /// Returns a [RangeUnit]. It represents a continuous set of integers from [start] to [end],
  ///   with an inclusive [start] but an exclusive [end]. This is the smallest unit that a
  ///   [Range] of numbers can be represented with.
  factory Range.unit(int start, int end) {
    if (end <= start) {
      return RangeUnit._nil;
    }
    return RangeUnit(start, end);
  }
  /// Returns a [RangeUnion]. This represents a collection of [RangeUnit] that aren't continuous,
  ///   but nevertheless is from the same [Range].
  factory Range.union(Set<RangeUnit> units) {
    units = { for (RangeUnit unit in units) if (unit != RangeUnit._nil) unit };
    if (units.isEmpty) {
      return RangeUnit._nil;
    }
    return RangeUnion(units);
  }
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

  /// Returns the contingent combination of two [RangeUnit]s,
  ///   returning an equivalent [RangeUnit]
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
      RangeUnit right = RangeUnit(other.end, max(other.end, end));

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
      if (end <= start) return _nil;

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
  bool contains(Object? value) {
    return value is num && start <= value && value < end;
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
  String toString() => this.isEmpty ? "∅" : "[$start, $end)";

  @override
  bool operator ==(Object? other) =>
    other is RangeUnit && start == other.start && end == other.end;

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
    return units.any((r) => r.covers(other));
  }
  
  @override
  Range difference(Range other) {
    if (!this.intersects(other)) return this;

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
  bool contains(Object? value) {
    return value is num && units.isNotEmpty && units.any((u) => u.contains(value));
  }

  @override
  int get length => units.map((u) => u.length).fold(0, (a, b) => a + b);

  @override
  Iterator<int> get iterator => () sync* {
    for (RangeUnit unit in units) {
      for (int v in unit) {
        yield v;
      }
    }
  }().iterator;

  @override
  String toString() => isEmpty ? "∅" : units.join(" | ");
}
