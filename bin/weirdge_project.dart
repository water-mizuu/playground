import "dart:collection";
import "dart:io";

// HashSet<V> -> HashMap<V, bool>
// HashMap<int, List<int>> friendData = HashMap<int, List<int>>();
List<List<int>> friendData = List<List<int>>.empty(growable: true);

void loadData(String path) {
  File file = File(path);
  if (!file.existsSync()) {
    throw Exception("File not found!");
  }

  List<String> lines = file.readAsLinesSync();

  /// The first line contains two numbers, n and e.
  List<String> tokens = lines[0].split(" ");
  int n = int.parse(tokens[0]);
  int e = int.parse(tokens[1]);

  for (int i = 0; i < n; ++i) {
    friendData.add(<int>[]);
  }

  /// Why i = 1? We skip the first line.
  for (int i = 1; i < e + 1; ++i) {
    tokens = lines[i].split(" ");

    /// int idFirst = Integer.parseInt(tokens[0]); <- Java
    int idFirst = int.parse(tokens[0]);

    /// <- Dart
    int idSecond = int.parse(tokens[1]);

    List<int>? friends = friendData[idFirst];
    friends.add(idSecond);
  }

  assert(friendData.length == n, "There must be exactly $n people in the graph.");
}

void getFriendList() {
  stdout.write("Enter ID of person: ");
  int id = int.parse(stdin.readLineSync()!);

  List<int> friends = friendData[id];
  stdout.writeln("Person $id has ${friends.length} friends!");
  stdout.writeln("List of friends: ${friends.join(" ")}");
}

void getConnection() {
  /// Load IDs
  stdout.write("Enter ID of first person: ");
  int idFirst = int.parse(stdin.readLineSync()!);
  stdout.write("Enter ID of second person: ");
  int idSecond = int.parse(stdin.readLineSync()!);

  /// Breadth-first search
  HashMap<int, bool> visited = HashMap<int, bool>();
  Queue<List<int>> queue = Queue<List<int>>();
  // visited.add(idFirst);
  visited[idFirst] = true;
  queue.add(<int>[idFirst]);

  while (queue.isNotEmpty) {
    List<int> path = queue.removeFirst();
    if (path.last == idSecond) {
      stdout.writeln("Connection found!");
      stdout.writeln("Path: ${path.join(" -> ")}");
      stdout.writeln();

      break;
    }

    List<int>? friends = friendData[path.last];
    for (int friend in friends) {
      if (!visited.containsKey(friend)) {
        // visited.add(friend);
        visited[friend] = true;
        List<int> newPath = List<int>.from(path);
        newPath.add(friend);
        queue.add(newPath);
      }
    }
  }
}

void main() {
  stdout.write("Input file path: ");
  String filePath = stdin.readLineSync()!;
  loadData(filePath);

  bool run = true;

  while (run) {
    stdout.writeln("MAIN MENU");
    stdout.writeln("[1] Get friend list");
    stdout.writeln("[2] Get connection");
    stdout.writeln("[3] Exit");
    stdout.writeln();
    stdout.write("Enter your choice: ");

    int choice = int.parse(stdin.readLineSync()!);
    switch (choice) {
      case 1:
        getFriendList();
      case 2:
        getConnection();
      case 3:
        run = false;
    }
  }
}
