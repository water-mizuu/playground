import "package:test/test.dart";

extension MatcherMethods on Matcher {
  Matcher operator |(Matcher other) => anyOf(this, other);
  Matcher operator &(Matcher other) => allOf(this, other);
}
