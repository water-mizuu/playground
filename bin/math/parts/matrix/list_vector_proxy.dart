part of "../../matrix.dart";

class _ListVectorProxy<E> implements List<Vector<E>> {
  static Never _unsupported(String message) =>
      throw UnsupportedError("$message is not supported for a vector list view.");

  final Matrix<E> parent;
  final List<List<(int, int)>> indices;

  _ListVectorProxy(this.parent, this.indices);

  List<Vector<E>> get mirror => [
        for (List<(int, int)> list in indices) //
          Vector([for ((int, int) pair in list) parent[pair.$0][pair.$1]])
      ];

  @override
  Vector<E> get first => mirror.first;

  @override
  set first(Vector<E> value) {
    for (int i = 0; i < indices.length; ++i) {
      (int, int) index = indices.first[i];

      parent[index.$0][index.$1] = value[i];
    }
  }

  @override
  Vector<E> get last => mirror.last;

  @override
  set last(Vector<E> value) {
    for (int i = 0; i < indices.length; ++i) {
      (int, int) index = indices.last[i];

      parent[index.$0][index.$1] = value[i];
    }
  }

  @override
  int get length => indices.length;

  @override
  set length(int newLength) {
    indices.length = newLength;
  }

  @override
  List<Vector<E>> operator +(List<Vector<E>> other) => _unsupported("operator +");

  @override
  Vector<E> operator [](int index) => mirror[index];

  @override
  void operator []=(int index, Vector<E> value) {
    if (value.data.length < indices.length) {
      throw ArgumentError.value(value, "value", "Replacement vector must match the original vector length!");
    }

    for (int i = 0; i < indices.length; ++i) {
      (int, int) pair = indices[index][i];

      parent[pair.$0][pair.$1] = value[i];
    }
  }

  @override
  void add(Vector<E> value) => _unsupported("add");

  @override
  void addAll(Iterable<Vector<E>> iterable) => _unsupported("addAll");

  @override
  bool any(bool Function(Vector<E> element) test) => mirror.any(test);

  @override
  Map<int, Vector<E>> asMap() => mirror.asMap();

  @override
  List<R> cast<R>() => mirror.cast<R>();

  @override
  void clear() => _unsupported("clear");

  @override
  bool contains(Object? element) => mirror.contains(element);

  @override
  Vector<E> elementAt(int index) => mirror.elementAt(index);

  @override
  bool every(bool Function(Vector<E> element) test) => mirror.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(Vector<E> element) toElements) => _unsupported("expand");

  @override
  void fillRange(int start, int end, [Vector<E>? fillValue]) => _unsupported("fillRange");

  @override
  Vector<E> firstWhere(bool Function(Vector<E> element) test, {Vector<E> Function()? orElse}) =>
      mirror.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, Vector<E> element) combine) =>
      mirror.fold(initialValue, combine);

  @override
  Iterable<Vector<E>> followedBy(Iterable<Vector<E>> other) => _unsupported("followedBy");

  @override
  void forEach(void Function(Vector<E> element) action) {}

  @override
  Iterable<Vector<E>> getRange(int start, int end) => mirror.getRange(start, end);

  @override
  int indexOf(Vector<E> element, [int start = 0]) => mirror.indexOf(element, start);

  @override
  int indexWhere(bool Function(Vector<E> element) test, [int start = 0]) => mirror.indexWhere(test, start);

  @override
  void insert(int index, Vector<E> element) => _unsupported("insert");

  @override
  void insertAll(int index, Iterable<Vector<E>> iterable) => _unsupported("insertAll");

  @override
  bool get isEmpty => mirror.isEmpty;

  @override
  bool get isNotEmpty => mirror.isNotEmpty;

  @override
  Iterator<Vector<E>> get iterator => mirror.iterator;

  @override
  String join([String separator = ""]) => mirror.join(separator);

  @override
  int lastIndexOf(Vector<E> element, [int? start]) => mirror.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(Vector<E> element) test, [int? start]) => mirror.lastIndexWhere(test, start);

  @override
  Vector<E> lastWhere(bool Function(Vector<E> element) test, {Vector<E> Function()? orElse}) =>
      mirror.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(Vector<E> e) toElement) => mirror.map(toElement);

  @override
  Vector<E> reduce(Vector<E> Function(Vector<E> value, Vector<E> element) combine) => mirror.reduce(combine);

  @override
  bool remove(Object? value) => _unsupported("remove");

  @override
  Vector<E> removeAt(int index) => _unsupported("removeAt");

  @override
  Vector<E> removeLast() => _unsupported("removeLast");

  @override
  void removeRange(int start, int end) => _unsupported("removeRange");

  @override
  void removeWhere(bool Function(Vector<E> element) test) => _unsupported("removeWhere");

  @override
  void replaceRange(int start, int end, Iterable<Vector<E>> replacements) {
    List<Vector<E>> taken = replacements.toList();

    for (int i = start; i < end; ++i) {
      List<(int, int)> indices = this.indices[i];
      Vector<E> replacement = taken[i - start];

      for (int j = 0; j < indices.length; ++j) {
        (int, int) pair = indices[j];

        parent[pair.$0][pair.$1] = replacement[j];
      }
    }
  }

  @override
  void retainWhere(bool Function(Vector<E> element) test) =>
      indices.retainWhere((values) => test(Vector([for ((int, int) pair in values) parent[pair.$0][pair.$1]])));

  @override
  Iterable<Vector<E>> get reversed => _ListVectorProxy(parent, indices.reversed.toList());

  @override
  void setAll(int index, Iterable<Vector<E>> iterable) => setRange(index, iterable.length, iterable);

  @override
  void setRange(int start, int end, Iterable<Vector<E>> iterable, [int skipCount = 0]) {
    List<Vector<E>> taken = iterable.skip(skipCount).toList();

    for (int i = start; i < end; ++i) {
      List<(int, int)> indices = this.indices[i];
      Vector<E> replacement = taken[i - start];

      for (int j = 0; j < indices.length; ++j) {
        (int, int) pair = indices[j];

        parent[pair.$0][pair.$1] = replacement[j];
      }
    }
  }

  @override
  void shuffle([r_math.Random? random]) => _unsupported("shuffle");

  @override
  Vector<E> get single => mirror.single;

  @override
  Vector<E> singleWhere(bool Function(Vector<E> element) test, {Vector<E> Function()? orElse}) =>
      mirror.singleWhere(test, orElse: orElse);

  @override
  Iterable<Vector<E>> skip(int count) => mirror.skip(count);

  @override
  Iterable<Vector<E>> skipWhile(bool Function(Vector<E> value) test) => mirror.skipWhile(test);

  @override
  void sort([int Function(Vector<E> a, Vector<E> b)? compare]) {
    indices.sort(compare == null
        ? null
        : (a, b) => compare.call(
              Vector([for ((int, int) pair in a) parent[pair.$0][pair.$1]]),
              Vector([for ((int, int) pair in b) parent[pair.$0][pair.$1]]),
            ));
  }

  @override
  List<Vector<E>> sublist(int start, [int? end]) => mirror.sublist(start, end);

  @override
  Iterable<Vector<E>> take(int count) => mirror.take(count);

  @override
  Iterable<Vector<E>> takeWhile(bool Function(Vector<E> value) test) => mirror.takeWhile(test);

  @override
  List<Vector<E>> toList({bool growable = true}) => mirror;

  @override
  Set<Vector<E>> toSet() => mirror.toSet();

  @override
  String toString() => mirror.toString();

  @override
  Iterable<Vector<E>> where(bool Function(Vector<E> element) test) => mirror.where(test);

  @override
  Iterable<T> whereType<T>() => mirror.whereType();
}
