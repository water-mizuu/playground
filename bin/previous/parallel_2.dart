import "dart:async";
import "dart:isolate";

class Test<T> {
  void entryPoint(SendPort sendPort) async {
    ReceivePort isolateReceivePort = ReceivePort();
    sendPort.send(isolateReceivePort.sendPort);

    Completer<FutureOr<T> Function()> callbackCompleter = Completer<FutureOr<T> Function()>();

    isolateReceivePort.listen((dynamic message) {
      if (message is FutureOr<T> Function()) {
        callbackCompleter.complete(message);
      }
    });

    FutureOr<T> Function() callback = await callbackCompleter.future;
    FutureOr<T> result = callback();

    sendPort.send(result);
  }

  Future<T> thing(FutureOr<T> Function() function) async {
    ReceivePort receivePort = ReceivePort();

    Completer<SendPort> sendPortCompleter = Completer<SendPort>();
    Completer<T> resultCompleter = Completer<T>();

    receivePort.listen((dynamic message) {
      if (!sendPortCompleter.isCompleted && message is SendPort) {
        sendPortCompleter.complete(message);
      }
      if (message is FutureOr<T>) {
        resultCompleter.complete(message);
      }
    });
    Isolate isolate = await Isolate.spawn(entryPoint, receivePort.sendPort);

    SendPort isolateSendPort = await sendPortCompleter.future;
    isolateSendPort.send(function);

    FutureOr<T> result = await resultCompleter.future;

    receivePort.close();
    isolate.kill();

    return result;
  }
}
