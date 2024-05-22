
// ignore_for_file: always_specify_types, deprecated_member_use

import "dart:async";

import "package:macros/macros.dart";


final _dartCore = Uri.parse("dart:core");

macro class Timed implements FunctionDeclarationsMacro {
  const Timed();

  @override
  Future<void> buildDeclarationsForFunction(FunctionDeclaration function, DeclarationBuilder builder) async {
    var (stopwatch, print) = await (
      builder.resolveIdentifier(_dartCore, "Stopwatch"),
      builder.resolveIdentifier(_dartCore, "print"),
    ).wait;

    var positionals = function.positionalParameters.where((p) => p.isRequired).toList();
    var optionals = function.positionalParameters.where((p) => !p.isRequired).toList();
    var named = function.namedParameters;

    var returnType = function.returnType.code.parts.whereType<Identifier>().firstOrNull?.name;

    var code = DeclarationCode.fromParts([
      "augment ",
      if (returnType != null) function.returnType.code,
      " ",
      function.identifier.name,
      "(",
      for (var param in positionals) param.code,
      if (optionals.isNotEmpty) ...[
        if (positionals.isNotEmpty) ", ",
        "[",
          for (var (i, param) in optionals.indexed) ...[param.code, if (i < named.length - 1) ", "],
        "]",
      ] else if (named.isNotEmpty) ...[
        if (positionals.isNotEmpty) ", ",
        "{",
          for (var (i, param) in named.indexed) ...[param.code, if (i < named.length - 1) ", "],
        "}",
      ],
      ") ",
      "{\n",
      "  var stopwatch = ", stopwatch, "()..start();\n",
      "  ",
      if (returnType != "void") "var result = ", "augmented(",
      for (var param in positionals) param.name,
      if (positionals.isNotEmpty && (optionals.isNotEmpty || named.isNotEmpty)) ", ",
      if (optionals.isNotEmpty) ...[
        for (var (i, param) in optionals.indexed) ...[param.name, if (i < named.length - 1) ", "],
      ] else if (named.isNotEmpty) ...[
        for (var (i, param) in named.indexed) ...[param.name, ": ", param.name, if (i < named.length - 1) ", "],
      ],
      ");\n",
      "  " , print, "(stopwatch.elapsedMilliseconds);\n",
      if (returnType != "void")
        "  return result;\n",
      "}\n",
      "\n",
      ],
    );

    builder.declareInLibrary(code);
  }
}
