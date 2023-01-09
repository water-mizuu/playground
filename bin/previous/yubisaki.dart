import "dart:io";
import "dart:math";

import "package:image/image.dart";
import "package:path/path.dart" as path;

class Rgba {
  final int red;
  final int green;
  final int blue;
  final int alpha;

  const Rgba(this.red, this.green, this.blue, this.alpha);
  const Rgba.fromUint32(int value)
      : red = value >>> (8 * 0) & 0xff,
        green = value >>> (8 * 1) & 0xff,
        blue = value >>> (8 * 2) & 0xff,
        alpha = value >>> (8 * 3) & 0xff;

  @override
  String toString() => "rgba($red, $green, $blue, $alpha)";
}

Iterable<List<T>> partitioned<T>(Iterable<T> data, int partitionSize) sync* {
  List<T> values = [];
  for (T value in data) {
    values.add(value);

    if (values.length == partitionSize) {
      yield values;
      values = [];
    }
  }
}

bool closeEnough(int left, int right) {
  Rgba leftRgba = Rgba.fromUint32(left);
  Rgba rightRgba = Rgba.fromUint32(right);

  int r = leftRgba.red - rightRgba.red;
  int g = leftRgba.green - rightRgba.green;
  int b = leftRgba.blue - rightRgba.blue;

  return r * r + g * g + b * b <= 8 * 8;
}

void main() {
  Directory directory = Directory("assets");

  print("Reading files.");
  List<File> children = [
    for (File dir in directory.listSync().whereType<File>()) dir
  ];
  List<Image> images = [
    for (File c in children) decodeJpg(c.readAsBytesSync())!
  ];
  List<bool> isSinglePage = [for (int i = 0; i < children.length; i++) i == 0];
  print("Finished reading files.");

  int singleOffset = 2 << 32 - 1;
  int doubleOffset = 2 << 32 - 1;
  for (int i = 0; i < children.length; i++) {
    isSinglePage[i] = i == 0;

    Image image = images[i];

    int width = image.width;
    int height = image.height;

    ImageData imageData = image.data!;
    List<int> data = imageData.getBytes();
    Iterable<List<int>> partitionedData =
        partitioned(data, width).take(5 * height ~/ 7);

    // Assume that the first pixel (top left) is always a padding/sentinel pixel.
    int sentinel = partitionedData.first[0];

    int leftOffset = width;
    int rightOffset = width;
    for (List<int> row in partitionedData) {
      int leftCount = row.takeWhile((c) => closeEnough(c, sentinel)).length;
      int rightCount =
          row.reversed.takeWhile((c) => closeEnough(c, sentinel)).length;

      leftOffset = min(leftOffset, leftCount);
      rightOffset = min(rightOffset, rightCount);
    }

    if (leftOffset != rightOffset) {
      continue;
    }

    if (isSinglePage[i]) {
      singleOffset = leftOffset;
    } else {
      doubleOffset = leftOffset;
    }
  }

  for (int i = 0; i < children.length; i++) {
    File file = children[i];
    Image image = images[i];

    int width = image.width;
    int height = image.height;

    String baseName = path.basenameWithoutExtension(file.path);
    String directoryName = path.join(path.dirname(file.path), "out");

    // The image is a two-paged image.
    if (!isSinglePage[i]) {
      // The middle of the original page.
      int middle = width ~/ 2;

      // RIGHT SIDE: ( PAGE 1 )
      {
        String name = "${baseName}_1";
        String fullPath = path.join(directoryName, "$name.jpg");
        Image croppedImage =
            copyCrop(image, x: middle, y: 0, width: middle - doubleOffset, height: height,);

        File(fullPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(encodeJpg(croppedImage));
      }

      // LEFT SIDE: ( PAGE 2 )
      {
        String name = "${baseName}_2";
        String fullPath = path.join(directoryName, "$name.jpg");
        Image croppedImage =
            copyCrop(image, x: doubleOffset, y: 0, width: middle - doubleOffset, height: height);

        File(fullPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(encodeJpg(croppedImage));
      }
    } else {
      String name = "${baseName}_1";
      String fullPath = path.join(directoryName, "$name.jpg");
      int pageWidth = width - 2 * singleOffset;
      Image croppedImage = copyCrop(image, x: singleOffset, y: 0, width: pageWidth, height: height);

      File(fullPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(encodeJpg(croppedImage));
    }
  }
}
