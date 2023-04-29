import "dart:math";

final Random random = Random();

bool? threeState() => switch (random.nextDouble()) {
      < 0.33 => null,
      >= 0.33 && < 0.66 => false,
      >= 0.66 => true,
      _ => throw Error(),
    };

void doesNothing(void Function() function) {
  function();
}

void main() {
  for (int i = 0; i < 10; ++i) {
    print(threeState());
  }
  // doesNothing(() => switch (threeState()) {
  //       null => print("null"),
  //       true => print("true"),
  //       false => print("false"),
  //     });
}
