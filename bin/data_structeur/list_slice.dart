import "dart:math";

extension ListSliceExtension<E> on List<E> {
  ListSlice<E> slice(int start, [int end = 0]) => ListSlice(this, start, end == 0 ? length : end);
}

class ListSlice<E> implements List<E> {
  final List<E> list;
  final int start;
  final int end;

  const ListSlice(this.list, int start, int end)
      : assert(list.length > 0, "A list must have at least one element to have a slice."),
        start = start > 0 ? start : start % list.length,
        end = end > 0 ? end : end % list.length;

  @override
  E get first => list[start];

  @override
  void set first(E _) => throw UnsupportedError("Cannot set item to slice!");

  @override
  E get last => list[end - 1];

  @override
  void set last(E _) => throw UnsupportedError("Cannot set item to slice!");

  @override
  int get length => end - start;

  @override
  void set length(int _) => throw UnsupportedError("Cannot change slice size!");

  @override
  Never operator +(List<E> other) {
    throw UnimplementedError();
  }

  @override
  E operator [](int index) {
    return list[start + index];
  }

  @override
  void operator []=(int index, E value) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never add(E value) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never addAll(Iterable<E> iterable) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  bool any(bool Function(E element) test) {
    bool found = false;
    for (int i = start; i < end; ++i) {
      if (found = test(list[i])) {
        break;
      }
    }

    return found;
  }

  @override
  Map<int, E> asMap() => {for (int i = start; i < end; ++i) i: list[i]};

  @override
  List<R> cast<R>() => list.sublist(start, end).cast<R>();

  @override
  Never clear() => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  bool contains(Object? element) {
    for (int i = start; i < end; ++i) {
      if (list[i] == element) {
        return true;
      }
    }

    return false;
  }

  @override
  E elementAt(int index) {
    return list[start + index];
  }

  @override
  bool every(bool Function(E element) test) {
    bool found = true;
    for (int i = start; i < end; ++i) {
      if (!(found = test(list[i]))) {
        break;
      }
    }

    return found;
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) sync* {
    for (int i = start; i < end; ++i) {
      yield* toElements(list[i]);
    }
  }

  @override
  Never fillRange(int start, int end, [E? fillValue]) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    for (int i = start; i < end; ++i) {
      if (test(list[i])) {
        return list[i];
      }
    }

    return orElse?.call() ?? (throw StateError("No element"));
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    T value = initialValue;
    for (int i = start; i < end; ++i) {
      value = combine(value, list[i]);
    }
    return value;
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) sync* {
    for (int i = start; i < end; ++i) {
      yield list[i];
    }
    yield* other;
  }

  @override
  void forEach(void Function(E element) action) {
    for (int i = start; i < end; ++i) {
      action(list[i]);
    }
  }

  @override
  Iterable<E> getRange(int start, int end) {
    assert(end + this.start <= this.end, "Range must not exceed slice bounds!");

    return list.getRange(start + this.start, end + this.start);
  }

  @override
  int indexOf(E element, [int start = 0]) {
    for (int i = this.start + start; i < end; ++i) {
      if (list[i] == element) {
        return i;
      }
    }

    return -1;
  }

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) {
    for (int i = this.start + start; i < end; ++i) {
      if (test(list[i])) {
        return i;
      }
    }
    return -1;
  }

  @override
  Never insert(int index, E element) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never insertAll(int index, Iterable<E> iterable) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  bool get isEmpty => end - start + 1 == 0;

  @override
  bool get isNotEmpty => end - start + 1 > 0;

  @override
  Iterator<E> get iterator {
    return () sync* {
      for (int i = start; i < end; ++i) {
        yield list[i];
      }
    }()
        .iterator;
  }

  @override
  String join([String separator = ""]) {
    StringBuffer buffer = StringBuffer();
    for (int i = start; i < end; ++i) {
      if (i > start) {
        buffer.write(separator);
      }
      buffer.write(list[i]);
    }

    return buffer.toString();
  }

  @override
  int lastIndexOf(E element, [int? start]) {
    for (int i = end - 1; i >= this.start + (start ?? 0); --i) {
      if (list[i] == element) {
        return i;
      }
    }

    return -1;
  }

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) {
    for (int i = end - 1; i >= this.start + (start ?? 0); --i) {
      if (test(list[i])) {
        return i;
      }
    }

    return -1;
  }

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    for (int i = end - 1; i >= start; --i) {
      if (test(list[i])) {
        return list[i];
      }
    }

    throw StateError("No match");
  }

  @override
  Iterable<T> map<T>(T Function(E e) toElement) sync* {
    for (int i = start; i < end; ++i) {
      yield toElement(list[i]);
    }
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    E value = list[start];
    for (int i = start + 1; i < end; ++i) {
      value = combine(value, list[i]);
    }
    return value;
  }

  @override
  bool remove(Object? value) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  E removeAt(int index) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  E removeLast() => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never removeRange(int start, int end) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never removeWhere(bool Function(E element) test) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never replaceRange(int start, int end, Iterable<E> replacements) =>
      throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never retainWhere(bool Function(E element) test) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Iterable<E> get reversed sync* {
    for (int i = end - 1; i >= start; --i) {
      yield list[i];
    }
  }

  @override
  Never setAll(int index, Iterable<E> iterable) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) =>
      throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never shuffle([Random? random]) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  E get single {
    if (length == 0) {
      throw StateError("Slice is empty!");
    }
    if (length != 1) {
      throw StateError("Too many elements");
    }

    return list[start];
  }

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    E? found;
    for (int i = start; i < end; ++i) {
      if (test(list[i])) {
        if (found == null) {
          found = list[i];
        } else {
          throw StateError("Too many elements");
        }
      }
    }

    return found ?? orElse?.call() ?? (throw StateError("No elements"));
  }

  @override
  Iterable<E> skip(int count) sync* {
    for (int i = start + count; i < end; ++i) {
      yield list[i];
    }
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) sync* {
    bool skipping = true;
    for (int i = start; i < end; ++i) {
      if (skipping) {
        skipping = test(list[i]);
      } else {
        yield list[i];
      }
    }
  }

  @override
  Never sort([int Function(E a, E b)? compare]) => throw UnsupportedError("Cannot mutate list from slice!");

  @override
  Never sublist(int start, [int? end]) => throw UnsupportedError("Cannot take sublist from slice!");

  @override
  Iterable<E> take(int count) sync* {
    for (int i = start; i < start + count; ++i) {
      yield list[i];
    }
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) sync* {
    for (int i = start; i < end; ++i) {
      if (test(list[i])) {
        yield list[i];
      } else {
        break;
      }
    }
  }

  @override
  List<E> toList({bool growable = true}) => list.sublist(start, end);

  @override
  Set<E> toSet() => {for (int i = start; i < end; ++i) list[i]};

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write("&[");
    for (int i = start; i < end; ++i) {
      if (i > start) {
        buffer.write(", ");
      }
      buffer.write(list[i]);
    }
    buffer.write("]");
    return buffer.toString();
  }

  @override
  Iterable<E> where(bool Function(E element) test) sync* {
    for (int i = start; i < end; ++i) {
      if (test(list[i])) {
        yield list[i];
      }
    }
  }

  @override
  Iterable<T> whereType<T>() sync* {
    for (int i = start; i < end; ++i) {
      E value = list[i];

      if (value is T) {
        yield value;
      }
    }
  }
}
