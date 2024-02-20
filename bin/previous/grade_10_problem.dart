void bruteForce() {
  /// Select 5 unique cards WHERE
  ///   the first three are completely random face cards
  ///   the fourth card is a king
  ///   the fifth card is any spade card.

  List<String> faceCards = <String>[
    for (String s in <String>["H", "D", "C", "S"])
      for (String f in <String>["K", "Q", "J"]) "$s$f",
  ];
  List<String> kings = <String>["HK", "DK", "CK", "SK"];
  List<String> spades = <String>[for (int i = 1; i <= 10; i++) "S$i", "SJ", "SQ", "SK"];
  List<Set<String>> cards = <Set<String>>[];
  int finalCount = 0;

  for (String c1 in faceCards) {
    for (String c2 in faceCards.where((String c) => !<String>{c1}.contains(c))) {
      for (String c3 in faceCards.where((String c) => !<String>{c1, c2}.contains(c))) {
        Set<String> accumulated = <String>{c1, c2, c3};
        if (cards.any((Set<String> c) => accumulated.every(c.contains))) {
          continue;
        }
        cards.add(accumulated);

        for (String k in kings.where((String c) => !<String>{c1, c2, c3}.contains(c))) {
          finalCount += spades.where((String c) => !<String>{c1, c2, c3, k}.contains(c)).length;
        }
      }
    }
  }

  print("  Count: $finalCount");
}
