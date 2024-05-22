
// ignore_for_file: always_specify_types, deprecated_member_use

import "dart:async";

import "package:macros/macros.dart";


final _dartCore = Uri.parse("dart:core");

macro class Memoized implements FunctionDeclarationsMacro, FunctionTypesMacro {
  const Memoized();

  static (bool isVoid, Code returnType) returnTypeInformation(FunctionDeclaration function) {
    var returnType = function.returnType.code.parts.whereType<Identifier>().firstOrNull?.name;
    if (returnType == null) {
      throw Exception("Type-safe memoized functions must have a return type!");
    }

    var isVoid = returnType == "void";
    return (isVoid, function.returnType.code);
  }

  static (
    List<FormalParameterDeclaration> positionals,
    List<FormalParameterDeclaration> optionals,
    List<FormalParameterDeclaration> named,
  ) parameterInformation(FunctionDeclaration function) {
    var positionals = function.positionalParameters.where((p) => p.isRequired).toList();
    var optionals = function.positionalParameters.where((p) => !p.isRequired).toList();
    var named = function.namedParameters.toList();
    return (positionals, optionals, named);
  }

  @override
  Future<void> buildTypesForFunction(FunctionDeclaration function, TypeBuilder builder) async {
    // var (positionals, optionals, named) = parameterInformation(function);
    // var parameterType = [
    //   "(",
    //   for (var param in positionals) param.type.code,
    //   if (optionals.isNotEmpty) ...[
    //     if (positionals.isNotEmpty) ", ",
    //     for (var (i, param) in optionals.indexed) ...[param.type.code, if (i < named.length - 1) ", "],
    //   ] else if (named.isNotEmpty) ...[
    //     if (positionals.isNotEmpty || optionals.isNotEmpty) ", ",
    //     "{",
    //     for (var (i, param) in named.indexed) ...[param.type.code, " ", param.name, if (i < named.length - 1) ", "],
    //     "}",
    //   ],
    //   ")",
    // ];
    // var id = function.identifier.name.hashCode;
    // var keyTypeName = "Key_${function.identifier.name}\$$id";

    // builder.declareType(keyTypeName, DeclarationCode.fromParts(parameterType));
  }

  @override
  Future<void> buildDeclarationsForFunction(FunctionDeclaration function, DeclarationBuilder builder) async {
    var nullType = await builder.resolveIdentifier(_dartCore, "Null");

    var (positionals, optionals, named) = parameterInformation(function);
    var (isVoid, returnType) = returnTypeInformation(function);
    var parameters = [
        "(",
        for (var param in positionals) param.code,
        if (optionals.isNotEmpty) ...[
          if (positionals.isNotEmpty) ", ",
          "[",
            for (var (i, param) in optionals.indexed) ...[param.code, if (i < named.length - 1) ", "],
          "]",
        ] else if (named.isNotEmpty) ...[
          if (positionals.isNotEmpty || optionals.isNotEmpty) ", ",
          "{",
            for (var (i, param) in named.indexed) ...[param.code, if (i < named.length - 1) ", "],
          "}",
        ],
        ")",
      ];
    var parameterRecord = [
      "(",
      for (var param in positionals) param.name,
      if (optionals.isNotEmpty) ...[
        if (positionals.isNotEmpty) ", ",
        for (var (i, param) in optionals.indexed) ...[param.name, if (i < named.length - 1) ", "],
      ] else if (named.isNotEmpty) ...[
        if (positionals.isNotEmpty || optionals.isNotEmpty) ", ",
        for (var (i, param) in named.indexed) ...[param.name, ": ", param.name, if (i < named.length - 1) ", "],
      ],
      ")",
    ];
    var parameterType = [
      "(",
      for (var param in positionals) param.type.code,
      if (optionals.isNotEmpty) ...[
        if (positionals.isNotEmpty) ", ",
        for (var (i, param) in optionals.indexed) ...[param.type.code, if (i < named.length - 1) ", "],
      ] else if (named.isNotEmpty) ...[
        if (positionals.isNotEmpty || optionals.isNotEmpty) ", ",
        "{",
        for (var (i, param) in named.indexed) ...[param.type.code, " ", param.name, if (i < named.length - 1) ", "],
        "}",
      ],
      ")",
    ];

    var id = function.identifier.name.hashCode;
    var cacheName = "_${function.identifier.name}\$cache$id";


    var cacheCode = DeclarationCode.fromParts([
      "final $cacheName = <", ...parameterType, ", ", if (isVoid) nullType else returnType, ">{};\n",
    ]);

    var functionCode = DeclarationCode.fromParts([
      "augment ",
      returnType,
      " ",
      function.identifier.name,
      ...parameters,
      " ",
      "=> \n",
      "    ", cacheName, ".putIfAbsent(\n",
      "      ", ...parameterRecord, ",\n",
      "      ", "() => augmented",
      ...parameterRecord,
      if(isVoid) ...[" as ", nullType],
      ",\n",
      "    );\n",
      ],
    );

    builder
      ..declareInLibrary(cacheCode)
      ..declareInLibrary(functionCode);
  }
}
