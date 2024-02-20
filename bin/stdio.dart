import "dart:io";

typedef Rgb = ({int r, int g, int b});

extension RgbMethods on Rgb {
  String get ansi => "$r;$g;$b";
}

extension StdoutExt on Stdout {
  static String _clearCode = String.fromCharCodes(<int>[27, 99, 27, 91, 51, 74]);
  static String _bellCode = String.fromCharCode(0x07);
  static String _escapeCode = "\x1B[";
  static String _hideCursorCode = "?25l";
  static String _showCursorCode = "?25h";
  static String _clearLineCode = "2K";
  static String _moveUpCode = "A";
  static String _moveDownCode = "B";
  static String _moveRightCode = "C";
  static String _moveLeftCode = "D";
  static String _moveToColumnCode = "G";
  static String _resetForegroundCode = "39m";
  static String _resetBackgroundCode = "49m";
  static bool _cursorHidden = false;

  void print([Object object = ""]) => write(object);
  void println([Object object = ""]) => writeln(object);
  void printAll(List<Object> objects, {String separator = ""}) => <List<void>>[
        for (Object obj in objects) <void>[print(obj), if (obj != objects.last) print(separator)],
      ];

  void newln([int n = 1]) => print("\n" * n);

  void esc(String s) => write("$_escapeCode$s");
  void bell() => write(_bellCode);

  void resetForegroundColor() => esc(_resetForegroundCode);
  void resetBackgroundColor() => esc(_resetBackgroundCode);
  void setForegroundColor(Rgb color) => esc("38;2;${color.ansi}m");
  void setBackgroundColor(Rgb color) => esc("48;2;${color.ansi}m");
  void resetColor() => <void>[resetBackgroundColor(), resetForegroundColor()];

  void clearScreen() => write(_clearCode);
  void clearln() => <void>[esc(_clearLineCode), movelnStart()];
  void clearlnsUp([int n = 1]) => <void>[
        clearln(),
        for (int i = 1; i < n; i++) <void>[moveUp(), clearln()],
      ];
  void clearlnsDown([int n = 1]) => <void>[
        clearln(),
        for (int i = 1; i < n; i++) <void>[moveUp(), clearln()],
      ];

  void moveUp([int n = 1]) => esc("$n$_moveUpCode");
  void moveDown([int n = 1]) => esc("$n$_moveDownCode");
  void moveRight([int n = 1]) => esc("$n$_moveRightCode");
  void moveLeft([int n = 1]) => esc("$n$_moveLeftCode");
  void movelnStart() => esc("1$_moveToColumnCode");
  void movelnEnd() => esc("1000000000$_moveToColumnCode");

  void hideCursor() => esc(_hideCursorCode);
  void showCursor() => esc(_showCursorCode);
  void sessionHideCursor() => hideCursor();
  void toggleCursor() => !(_cursorHidden = !_cursorHidden) ? showCursor() : hideCursor();

  // Overloads
  set foregroundColor(Rgb color) => setForegroundColor(color);
  set backgroundColor(Rgb color) => setBackgroundColor(color);
}

Future<void> sleep(Duration duration) => Future<void>.delayed(duration);
