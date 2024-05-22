// ignore_for_file: deprecated_member_use

import "dart:async";

import "package:macros/macros.dart";

macro class WrappingClass implements FunctionDeclarationsMacro {
  const WrappingClass();

  @override
  FutureOr<void> buildDeclarationsForFunction(FunctionDeclaration function, DeclarationBuilder builder) {
    builder.declareInLibrary(DeclarationCode.fromParts(<Object>[
          "class ",
          function.identifier.name,
          "  {\n",
          "  }\n",
          "}\n",
        ],
      ),
    );
  }
}
