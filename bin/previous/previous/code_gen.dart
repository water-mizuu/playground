import "dart:io";

String codeGen(int count) {
  const int restLimit = 50;
  StringBuffer buffer = StringBuffer();

  buffer
    ..write("typedef FakeRest$count")
    ..write("<")
    ..write(<String>["R", "V", for (int i = 0; i < count; i++) "A$i"].join(", "))
    ..write(">")
    ..write(" = R Function")
    ..write("(")
    ..write(<String>[for (int i = 0; i < count; i++) "A$i"].join(", "))
    ..write(", ")
    ..write("[")
    ..write(<String>[for (int i = 0; i < restLimit; i++) "V"].join(", "))
    ..write("]")
    ..write(");")
    ..writeln();

  buffer
    ..write("FakeRest$count")
    ..write("<")
    ..write(<String>["R", "V", for (int i = 0; i < count; i++) "A$i"].join(", "))
    ..write(">")
    ..write(" ")
    ..write("fakeRest$count")
    ..write("<")
    ..write(<String>["R", "V", for (int i = 0; i < count; i++) "A$i"].join(", "))
    ..write(">")
    ..write("(")
    ..write("R Function")
    ..write("(")
    ..write(<String>[for (int i = 0; i < count; i++) "A$i", "List<V>"].join(", "))
    ..write(")")
    ..write(" callback")
    ..write(")")
    ..write(" => ")
    ..write("(")
    ..write(
      <String>[
        <String>[for (int i = 0; i < count; i++) "A$i a$i"].join(", "),
        "[${<String>[for (int i = 0; i < restLimit; i++) "Object? v$i = _fakeRest"].join(", ")}]",
      ].join(", "),
    )
    ..write(")")
    ..write(" => ")
    ..write("callback")
    ..write("(")
    ..write(<String>[for (int i = 0; i < count; i++) "a$i"].join(", "))
    ..write(", ")
    ..write("<V>[")
    ..write(<String>[for (int i = 0; i < restLimit; i++) "if (v$i != _fakeRest && v$i is V) v$i"].join(","))
    ..write("]);")
    ..writeln("\n");

  buffer
    ..write("extension FakeRestExtension$count")
    ..write("<")
    ..write(<String>["R", "V", for (int i = 0; i < count; i++) "A$i"].join(", "))
    ..write(">")
    ..write(" on ")
    ..write("R Function")
    ..write("(")
    ..write(<String>[for (int i = 0; i < count; i++) "A$i", "List<V>"].join(", "))
    ..write(")")
    ..writeln(" {")
    ..write("  ")
    ..write("FakeRest$count")
    ..write("<")
    ..write(<String>["R", "V", for (int i = 0; i < count; i++) "A$i"].join(", "))
    ..write(">")
    ..writeln(" get rest => fakeRest$count(this);")
    ..write("}")
    ..writeln("\n");

  return buffer.toString();
// extension FakeRestExtension1<R, V, A1> on R Function(A1, List<V>) {
//   FakeRest1<R, V, A1> get rest => fakeRest1(this);
// }
}

void generateFakeRest(String path) {
  File file = File(path);

  StringBuffer buffer = StringBuffer("const Symbol _fakeRest = #FAKE_REST;");

  for (int i = 0; i <= 30; i++) {
    buffer.writeln(codeGen(i));
  }

  file.writeAsStringSync(buffer.toString());
}

String mapFunctionType(int count) {
  if (count <= 0) {
    throw UnsupportedError("Only supports >0");
  }

  StringBuffer buffer = StringBuffer()
    ..write("typedef MapFunction\$$count = MapFunction Function")
    ..write("<")
    ..write(<String>[for (int i = 1; i <= count; i++) "V$i"].join(", "))
    ..write(">")
    ..write("(")
    ..write("ParseResult Function")
    ..write("(")
    ..write(<String>[for (int i = 1; i <= count; i++) "V$i"].join(", "))
    ..write(")")
    ..write(")")
    ..writeln(";");

  return buffer.toString();
}
