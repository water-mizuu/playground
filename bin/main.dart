import "dart:math";

final Random random = Random();
bool? twoState() => switch (random.nextDouble()) {
      < 0.5 => false,
      >= 0.5 => true,
      _ => throw Error(),
    };

void main() {
  print(switch (twoState()) {
    void _ when !(true != false) => "hi", // Expected to find '=>'
    // /ool _ when !twoState() => "hi", // Works.
    true => 1,
    false => 0,
    null => "hi",
  });
}
