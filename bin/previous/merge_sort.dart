// ignore_for_file: always_specify_types, always_put_control_body_on_new_line

(List<int> left, List<int> right) split(List<int> list) {
  /// Get the "middle" index of the list.
  var middle = (list.length / 2).floor();

  /// Add from [0, middle) to `left`.
  var left = <int>[];
  for (var i = 0; i < middle; ++i) {
    left.add(list[i]);
  }

  /// Add from [middle, list.length) to `right`.
  var right = <int>[];
  for (var i = middle; i < list.length; ++i) {
    right.add(list[i]);
  }

  /// Return the two halves.
  return (left, right);
}

List<int> merge(List<int> left, List<int> right) {
  /// This will be the merged list of `left` and `right`.
  var resultant = <int>[];

  /// This indicates which item we are comparing in `left` and `right`.
  var leftP = 0;
  var rightP = 0;

  /// While we haven't reached the end of either list,
  while (leftP < left.length && rightP < right.length) {
    /// If the current item in `left` is less than the current item in `right`,
    ///   add the current item in `left` to `resultant`.
    if (left[leftP] < right[rightP]) {
      resultant.add(left[leftP]);
      leftP += 1;
    }

    /// Otherwise, add the current item in `right` to `resultant`.
    else {
      resultant.add(right[rightP]);
      rightP += 1;
    }
  }

  /// If there are any remaining items in `left` or `right`, add them to `resultant`.
  ///  (Only one of the two loops will run.)
  while (leftP < left.length) {
    resultant.add(left[leftP]);
    leftP += 1;
  }
  while (rightP < right.length) {
    resultant.add(right[rightP]);
    rightP += 1;
  }

  return resultant;
}

List<int> mergeSort(List<int> list) {
  /// Do nothing if the list is empty or has only one element
  if (list.length == 1 || list.isEmpty) return list;

  /// 1. Split the list into two halves.
  var (left, right) = split(list);

  /// 2. Recursively sort each half using the same function.
  var sortedLeft = mergeSort(left);
  var sortedRight = mergeSort(right);

  /// 3. Merge the sorted halves.
  var merged = merge(sortedLeft, sortedRight);

  return merged;
}

void main() {
  List<int> integers = <int>[5, 1, 0, 41, 4, 8, 10, 21];

  print(integers);
  List<int> sorted = mergeSort(integers);
  print(sorted);
}
