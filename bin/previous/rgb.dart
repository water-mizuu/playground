import "dart:math";

class Rgb {
  const Rgb({required this.red, required this.green, required this.blue});
  final int red;
  final int green;
  final int blue;

  @override
  String toString() => "Rgb ($red, $green, $blue)";
}

Rgb hslToRgb(int hue, double saturation, double lightness) {
  // Magic some gods created.
  num a = saturation * min(lightness, 1 - lightness);
  num f(int n) {
    num k = (n + hue / 30) % 12;

    return lightness - a * max(<num>[k - 3, 9 - k, 1].reduce(min), -1);
  }

  return Rgb(
    red: (f(0) * 256).floor(),
    green: (f(8) * 256).floor(),
    blue: (f(4) * 256).floor(),
  );
}

Rgb hslToRgb2(int hue, double saturation, double lightness) {
  num c = (1 - (2 * lightness - 1).abs()) * saturation;
  num x = c * (1 - ((hue ~/ 60) % 2 - 1).abs());
  num m = lightness - c / 2;

  List<num> set = <List<num>>[
    <num>[c, x, 0],
    <num>[x, c, 0],
    <num>[0, c, x],
    <num>[0, x, c],
    <num>[x, 0, c],
    <num>[c, 0, x],
  ][hue ~/ 60];

  return Rgb(
    red: ((set[0] + m) * 256).floor(),
    green: ((set[1] + m) * 256).floor(),
    blue: ((set[2] + m) * 256).floor(),
  );
}
