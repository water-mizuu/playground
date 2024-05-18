sealed class Option<E extends Object?> {
  const Option();
  const factory Option.some(E element) = Some<E>;
  const factory Option.none() = None;

  R match<R>({
    required R Function(E value) some,
    required R Function() none,
  });

  bool get isSome;
  bool get isNone;

  Option<R> select<R extends Object?>(R Function(E value) some);
  Option<R> expand<R extends Object?>(Option<R> Function(E value) some);
  E? unwrap();
}

class Some<E extends Object?> implements Option<E> {
  const Some(this.value);
  final E value;

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
  Option<R> expand<R extends Object?>(Option<R> Function(E value) some) => some(value);

  @override
  Option<R> select<R extends Object?>(R Function(E value) some) => Option<R>.some(some(value));

  @override
  E? unwrap() => value;

  @override
  String toString() => "Some($value)";
}

class None implements Option<Never> {
  const None();

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
  Option<R> expand<R extends Object?>(Object some) => this;

  @override
  Option<R> select<R extends Object?>(Object some) => this;

  @override
  Null unwrap() => null;

  @override
  String toString() => "None()";
}
