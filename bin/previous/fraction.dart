
typedef Fraction = (int, int);

extension IntFractionExtension on int {
  Fraction get f => (this, 1);
}
extension NumFractionExtension on num {
  Fraction get f {
    const double error = 0.00001;

      int n = floor();
      num x = this - n;

    if (x < error) {
      return (n, 1);
    } else if (1 - x < error) {
      return (n + 1, 1);
    }

    int lowerN = 0;
    int lowerD = 1;
    int upperN = 1;
    int upperD = 1;
    for (;;) {
        int middleN = lowerN + upperN;
        int middleD = lowerD + upperD;

      if (middleD * (x + error) < middleN) {
        upperN = middleN;
        upperD = middleD;
      } else if (middleN < (x - error) * middleD) {
        lowerN = middleN;
        lowerD = middleD;
      } else {
        return (n * middleD + middleN, middleD);
      }
    }
  }
}

extension FractionMethods on Fraction {
  static Map<T, int> count<T>(  Iterable<T> values) {
      Map<T, int> count = { for (T c in values) c: 0 };
    for (  T c in values) {
      count[c] = count[c]! + 1;
    }

    return count;
  }

  static int _euclidGcf(  int big,   int small) {
    int b = big;
    int s = small;

    while (s != 0) {
        int temp = s;
      s = b % s;
      b = temp;
    }
    return b;
  }

  static int _computeGcf(  int left,   int right) {
      int big = left > right ? left : right;
      int small = left > right ? right : left;

    return _euclidGcf(big, small);
  }

  Fraction floor() {
      int numerator = (this.numerator / this.denominator).floor();
      int denominator = 1;

    return (numerator, denominator);
  }

  int get numerator => $0;
  int get denominator => $1;

  Fraction get reduced {
      int gcf = _computeGcf(numerator.abs(), denominator.abs());
      int sign = denominator < 0 ? -1 : 1;

    return (sign * numerator ~/ gcf, sign * denominator ~/ gcf);
  }

  Fraction operator +(  Fraction other) {
      int numerator = this.numerator * other.denominator + other.numerator * this.denominator;
      int denominator = this.denominator * other.denominator;

    return (numerator, denominator).reduced;
  }

  Fraction operator *(  Fraction other) {
      int numerator = this.numerator * other.numerator;
      int denominator = this.denominator * other.denominator;

    return (numerator, denominator).reduced;
  }

  Fraction operator -(  Fraction other) => this + other.additiveInverse;
  Fraction operator /(  Fraction other) => this * other.multiplicativeInverse;
  Fraction operator ~/(  Fraction other) => (this / other).floor();

  Fraction get additiveInverse => (-numerator, denominator);
  Fraction get multiplicativeInverse => (denominator, numerator);

  num get value => numerator / denominator;
  String get repr => denominator == 1 ? "$numerator" : "$numerator/$denominator";

  int toInt() => numerator ~/ denominator;
}
