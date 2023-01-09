import "dart:math";

class Rgb {
  final int red;
  final int green;
  final int blue;

  const Rgb({required this.red, required this.green, required this.blue});

  @override
  String toString() => "Rgb ($red, $green, $blue)";
}

Rgb hslToRgb(int hue, double saturation, double lightness) {
  // Magic some gods created.
  num a = saturation * min(lightness, 1 - lightness);
  num f(int n) {
    num k = (n + hue / 30) % 12;

    return lightness - a * max([k - 3, 9 - k, 1].reduce(min), -1);
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

  List<num> set = [
    [c, x, 0],
    [x, c, 0],
    [0, c, x],
    [0, x, c],
    [x, 0, c],
    [c, 0, x],
  ][hue ~/ 60];

  return Rgb(
    red: ((set[0] + m) * 256).floor(),
    green: ((set[1] + m) * 256).floor(),
    blue: ((set[2] + m) * 256).floor(),
  );
}
