abstract class Option<E extends Object?> {
  const Option();
  const factory Option.some(E element) = _Some<E>;
  const factory Option.none() = _None;

  R match<R>({
    required R Function(E value) some,
    required R Function() none,
  });

  bool get isSome;
  bool get isNone;

  Option<R> map<R extends Object?>(R Function(E value) some);
  Option<R> flatMap<R extends Object?>(Option<R> Function(E value) some);
  E? unwrap();
}

class _Some<E extends Object?> implements Option<E> {
  final E value;
  const _Some(this.value);

  @override
  R match<R>({
    required R Function(E value) some,
    required Object none,
  }) =>
      some(value);

  @override
  bool get isSome => true;

  @override
  bool get isNone => false;

  @override
  Option<R> flatMap<R extends Object?>(Option<R> Function(E value) some) => some(value);

  @override
  Option<R> map<R extends Object?>(R Function(E value) some) => Option<R>.some(some(value));

  @override
  E? unwrap() => value;

  @override
  String toString() => "Some($value)";
}

class _None implements Option<Never> {
  const _None();

  @override
  R match<R>({
    required Function some,
    required R Function() none,
  }) =>
      none();

  @override
  bool get isSome => false;

  @override
  bool get isNone => true;

  @override
  Option<R> flatMap<R extends Object?>(Object some) => this;

  @override
  Option<R> map<R extends Object?>(Object some) => this;

  @override
  Null unwrap() => null;

  @override
  String toString() => "None()";
}
