abstract class NumberLike<Self extends NumberLike<Self>> implements Comparable<Self> {
  const NumberLike();

  @override
  int compareTo(Self other);

  Self add(Self other);
  Self subtract(Self other);
  Self multiply(Self other);
  Self divide(Self other);
  Self floorDivide(Self other);
  Self modulo(Self other);
  Self pow(Self other);
  bool isEqualTo(Self other);

  Self abs();
  Self floor();
  Self round();
  Self ceil();
  Self collapse();
  Self normalize();

  Self get additiveInverse;
  Self get multiplicativeInverse;
  Self get sign;
  Self get collapsed;
  Self get normalized;

  Self operator +(Self other) => other.isNaN ? other : add(other);
  Self operator -(Self other) => other.isNaN ? other : subtract(other);
  Self operator -() => additiveInverse;

  Self operator *(Self other) => other.isNaN ? other : multiply(other);
  Self operator /(Self other) => other.isNaN ? other : divide(other);
  Self operator ~/(Self other) => other.isNaN ? other : floorDivide(other);
  Self operator %(Self other) => other.isNaN ? other : modulo(other);

  bool operator >(Self other) => !other.isNaN && compareTo(other) > 0;
  bool operator >=(Self other) => !other.isNaN && compareTo(other) >= 0;
  bool operator <(Self other) => !other.isNaN && compareTo(other) < 0;
  bool operator <=(Self other) => !other.isNaN && compareTo(other) <= 0;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Self && isEqualTo(other);

  @override
  int get hashCode => super.hashCode;

  String get str;
  String get strRat;
  String get strShort;
  String get strLong;
  bool get isNaN;

  @override
  String toString() => str;
}
