// Function to generate a list of random integers
import "dart:math";

List<int> generateRandomList(int length) {
  // Create a new list with the specified length
  // and initialize it with a function that generates
  // random integers for each element in the list
  List<int> list = List<int>.generate(length, (int i) {
    Random random = Random();

    return random.nextInt(100);
  });

  // Return the final list of random integers
  return list;
}
