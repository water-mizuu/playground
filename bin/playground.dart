

import "package:json/json.dart";

@JsonCodable()
class Person {
  Person(this.name, this.age);
  String name;
  int age;
}

void main() {
  print(Person("Michael", 22).toJson());
}
