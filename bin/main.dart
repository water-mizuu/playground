import "dart:developer";
import "dart:io";

import "package:time/time.dart";

import "stdio.dart";

void main(List<String> args) async {
  int start = Timeline.now ~/ 1e6;

  for (;;) {
    stdout.clearScreen();

    stdout.write("Hello! This application has been open for: ");
    stdout.foregroundColor = (255, 0, 255);
    stdout.resetForegroundColor();

    await sleep(800.milliseconds);
  }
}
