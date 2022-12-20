import "dart:async";
import "dart:isolate";

typedef FalseRest<R, V> = R Function([V, V, V, V, V, V, V, V, V, V, V, V, V, V, V, V, V, V, V, V]);

class IsolateHelper {
  static Symbol key = #ISOLATE_HELPER_KEY;

  static void helper<T>(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    late List<Object?> arguments;
    receivePort.listen((dynamic message) async {
      if (message is Function) {
        dynamic result = (() {
          try {
            Function.apply(message, arguments);
            sendPort.send(key);
            receivePort.close();
            // ignore: avoid_catching_errors
          } on NoSuchMethodError {
            sendPort.send(key);
            receivePort.close();
            throw Exception(
              "With argument count ${arguments.length}, function type ${message.runtimeType} is unsupported.",
            );
          }
        })();

        if (result is! T) {
          throw TypeError();
        }

        sendPort.send(result);
        receivePort.close();
      } else if (message is List<Object?>) {
        arguments = message;
      }
    });
  }

  static FalseRest<R, V> generateFalseRest<R, V>(R Function(List<V>) callback) {
    const Symbol blank = #no;

    return ([
      Object? v1 = blank,
      Object? v2 = blank,
      Object? v3 = blank,
      Object? v4 = blank,
      Object? v5 = blank,
      Object? v6 = blank,
      Object? v7 = blank,
      Object? v8 = blank,
      Object? v9 = blank,
      Object? v10 = blank,
      Object? v11 = blank,
      Object? v12 = blank,
      Object? v13 = blank,
      Object? v14 = blank,
      Object? v15 = blank,
      Object? v16 = blank,
      Object? v17 = blank,
      Object? v18 = blank,
      Object? v19 = blank,
      Object? v20 = blank,
    ]) {
      List<Object?> args = <Object?>[
        if (v1 != blank) v1,
        if (v2 != blank) v2,
        if (v3 != blank) v3,
        if (v4 != blank) v4,
        if (v5 != blank) v5,
        if (v6 != blank) v6,
        if (v7 != blank) v7,
        if (v8 != blank) v8,
        if (v9 != blank) v9,
        if (v10 != blank) v10,
        if (v11 != blank) v11,
        if (v12 != blank) v12,
        if (v13 != blank) v13,
        if (v14 != blank) v14,
        if (v15 != blank) v15,
        if (v16 != blank) v16,
        if (v17 != blank) v17,
        if (v18 != blank) v18,
        if (v19 != blank) v19,
        if (v20 != blank) v20,
      ];

      return callback(args.cast());
    };
  }

  static FalseRest<Future<R>, Object?> parallel<R extends Object?>(Function function) {
    return generateFalseRest<Future<R>, Object?>((List<Object?> arguments) {
      Completer<R> completer = Completer<R>();
      ReceivePort receivePort = ReceivePort();

      late SendPort sendPort;
      receivePort.listen((FutureOr<dynamic> message) async {
        dynamic awaited = await message;

        if (awaited is SendPort) {
          sendPort = awaited;

          sendPort.send(arguments);
          sendPort.send(function);
          return;
        } else if (awaited.runtimeType == R || awaited is R) {
          completer.complete(awaited as R);
        }
        receivePort.close();
      });

      unawaited(Isolate.spawn(IsolateHelper.helper<R>, receivePort.sendPort));

      return completer.future;
    });
  }
}

FalseRest<Future<R>, Object?> parallel<R extends Object?>(Function function) => IsolateHelper.parallel(function);
