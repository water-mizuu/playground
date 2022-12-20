void bruteForce() {
  /// Select 5 unique cards WHERE
  ///   the first three are completely random face cards
  ///   the fourth card is a king
  ///   the fifth card is any spade card.

  List<String> faceCards = <String>[
    for (String s in ["H", "D", "C", "S"])
      for (String f in ["K", "Q", "J"]) "$s$f",
  ];
  List<String> kings = ["HK", "DK", "CK", "SK"];
  List<String> spades = [for (int i = 1; i <= 10; i++) "S$i", "SJ", "SQ", "SK"];
  List<Set<String>> cards = [];
  int finalCount = 0;

  for (String c1 in faceCards) {
    for (String c2 in faceCards.where((c) => !{c1}.contains(c))) {
      for (String c3 in faceCards.where((c) => !{c1, c2}.contains(c))) {
        Set<String> accumulated = {c1, c2, c3};
        if (cards.any((c) => accumulated.every(c.contains))) {
          continue;
        }
        cards.add(accumulated);

        for (String k in kings.where((c) => !{c1, c2, c3}.contains(c))) {
          finalCount += spades.where((c) => !{c1, c2, c3, k}.contains(c)).length;
        }
      }
    }
  }

  print("  Count: $finalCount");
}
