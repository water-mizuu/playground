sealed class Box<E> {
  E get item;
  const Box();
}

class FilledBox<E> extends Box<E> {
  @override
  final E item;

  const FilledBox(this.item);
}

class NeverBox extends Box<Never> {
  @override
  Never get item => throw Error();

  const NeverBox();
}

/// This does not.
Box<O> switchFunction<O>(O? object) => //
    /// A value of type 'Object' can't be returned from the function
    ///   'switchFunction' because it has a return type of 'Box<int>'
    switch (object) {
      O object => FilledBox<O>(object),
      _ => NeverBox() as Box<O>,
    };
