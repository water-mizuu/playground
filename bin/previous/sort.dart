extension _ListSwapExtension<E> on List<E> {
  void swap(int i, int j) {
    E temp = this[i];
    this[i] = this[j];
    this[j] = temp;
  }
}

extension ListIncomparableExtension<E> on List<E> {
  List<E> sorted(int Function(E, E) compareFunction) {
    if (isEmpty) {
      return [];
    }

    List<E> items = [...this];
    quickSort(items, compareFunction);

    return items;
  }
}

extension ListComparableExtension<E extends Comparable<dynamic>> on List<E> {
  List<E> sorted([int Function(E, E) compareFunction = Comparable.compare]) {
    if (isEmpty) {
      return [];
    }

    List<E> items = [...this];
    quickSort(items, compareFunction);

    return items;
  }
}

void quickSort<T>(List<T> list, int Function(T, T) comparison, [int? low, int? high]) {
  low ??= 0;
  high ??= list.length - 1;

  if (low < 0 || high < 0 || low >= high) {
    return;
  }

  // Set the pivot to be the middle element.
  T pivot = list[(low + high) >>> 1];
  int i = low - 1;
  int j = high + 1;

  int solvedPivot;
  for (;;) {
    while (comparison(list[++i], pivot) < 0) {}
    while (comparison(list[--j], pivot) > 0) {}

    if (i >= j) {
      solvedPivot = j;
      break;
    }

    list.swap(i, j);
  }

  quickSort(list, comparison, low, solvedPivot);
  quickSort(list, comparison, solvedPivot + 1, high);
}

bool isSorted(List<int> list) {
  for (int i = 0; i < list.length - 1; i++) {
    if (list[i] > list[i + 1]) {
      return false;
    }
  }
  return true;
}
