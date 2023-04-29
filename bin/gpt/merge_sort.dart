void mergeSort(List<int> arr, [int? start, int? end]) {
  start ??= 0;
  end ??= arr.length;

  if (end <= start + 1) {
    return;
  }

  int mid = (start + end) ~/ 2;

  mergeSort(arr, start, mid);
  mergeSort(arr, mid, end);

  int i = start;
  int j = mid;
  arr.replaceRange(start, end, <int>[
    for (; i < mid && j < end;)
      if (arr[i] <= arr[j]) arr[i++] else arr[j++],
    for (; i < mid;) arr[i++],
    for (; j < end;) arr[j++],
  ]);
}
