void time(void Function() callback, [String? name]) {
  Stopwatch watch = Stopwatch()..start();
  callback();
  watch.stop();

  print("Time: ${formatMicroseconds(watch.elapsedMicroseconds)}");
}

String formatMicroseconds(int value) {
  const Map<int, String> table = <int, String>{
    1 * 1000 * 1000 * 60 * 60 * 24 * 30 * 12: "years",
    1 * 1000 * 1000 * 60 * 60 * 24 * 30: "months",
    1 * 1000 * 1000 * 60 * 60 * 24: "days",
    1 * 1000 * 1000 * 60 * 60: "hr",
    1 * 1000 * 1000 * 60: "m",
    1 * 1000 * 1000: "s",
    1 * 1000: "ms",
    1: "μs",
  };

  StringBuffer buffer = StringBuffer();
  int currentDenomination = value;

  for (MapEntry<int, String> entry in table.entries) {
    int current = 0;
    while (entry.key <= currentDenomination) {
      currentDenomination -= entry.key;
      current++;
    }

    if (current == 0) {
      continue;
    }

    buffer.write("$current ${entry.value} ");
  }

  return buffer.toString().trimRight();
}
