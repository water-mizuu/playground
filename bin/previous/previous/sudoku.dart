// ignore_for_file: unreachable_from_main

import "matrix.dart";
import "time.dart";

typedef Matrix<T> = List<List<T>>;

bool isValidMove(int value, int y, int x, Matrix<int> grid, int sectorSize) {
  if (grid[y][x] != 0) {
    return false;
  }

  for (int y_ = 0; y_ < grid.length; y_++) {
    if (y != y_ && grid[y_][x] == value) {
      return false;
    }
  }

  for (int x_ = 0; x_ < grid.length; x_++) {
    if (x != x_ && grid[y][x_] == value) {
      return false;
    }
  }

  // This might be odd, but focus on the FLOOR division.
  int sectorY = (y ~/ sectorSize) * sectorSize;
  int sectorX = (x ~/ sectorSize) * sectorSize;
  for (int y_ = sectorY; y_ < sectorY + sectorSize; y_++) {
    for (int x_ = sectorX; x_ < sectorX + sectorSize; x_++) {
      if (grid[y_][x_] == value) {
        return false;
      }
    }
  }

  return true;
}

bool sudokuSolverForce(Matrix<int> grid) {
  for (int y = 0; y < grid.verticalLength; y++) {
    for (int x = 0; x < grid.horizontalLength; x++) {
      if (grid[y][x] != 0) {
        continue;
      }

      for (int move = 1; move <= 9; move++) {
        if (!isValidMove(move, y, x, grid, 3)) {
          continue;
        }

        grid[y][x] = move;
        if (sudokuSolverForce(grid)) {
          return true;
        } else {
          grid[y][x] = 0;
        }
      }

      return false;
    }
  }

  return true;
}

bool _sudokuSolverOptimized(
  Matrix<int> grid,
  int i,
  List<(int, int)> indices,
  Map<(int, int), Set<int>> searchSpace,
) {
  if (i >= indices.length) {
    return true;
  }

  Set<int> moves = searchSpace[indices[i]]!;
  int y = indices[i].$1;
  int x = indices[i].$2;
  if (moves.isEmpty || grid[y][x] != 0) {
    return _sudokuSolverOptimized(grid, i + 1, indices, searchSpace);
  }

  for (int move in moves) {
    if (!isValidMove(move, y, x, grid, 3)) {
      continue;
    }

    grid[y][x] = move;
    if (_sudokuSolverOptimized(grid, i + 1, indices, searchSpace)) {
      return true;
    } else {
      grid[y][x] = 0;
    }
  }

  return false;
}

///
/// Optimizes solving a sudoku by basically
///   pruning the search to only those that are guaranteed
///   to be possible.
///
bool sudokuSolverOptimized(Matrix<int> grid) {
  Map<(int, int), Set<int>> searchSpace = <(int, int), Set<int>>{
    for (int y = 0; y < grid.verticalLength; y++)
      for (int x = 0; x < grid.horizontalLength; x++)
        (y, x): <int>{
          if (grid[y][x] == 0)
            for (int i = 1; i <= 9; i++)
              if (isValidMove(i, y, x, grid, 3)) i,
        },
  };
  List<(int, int)> indices = searchSpace.keys.where(((int, int) v) => searchSpace[v]!.isNotEmpty).toList()
    ..sort(((int, int) l, (int, int) r) => searchSpace[l]!.length.compareTo(searchSpace[r]!.length));

  return _sudokuSolverOptimized(grid, 0, indices, searchSpace);
}

void main() {
  late Matrix<int> matrix;
  // matrix = [
  //   [0, 0, 3, 0, 0, 0, 0, 0, 9],
  //   [0, 8, 0, 2, 0, 0, 6, 3, 0],
  //   [0, 0, 0, 0, 0, 6, 0, 0, 4],
  //   [0, 4, 0, 0, 5, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 9, 0],
  //   [0, 0, 5, 0, 0, 7, 3, 2, 0],
  //   [1, 0, 0, 8, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 6],
  //   [0, 0, 4, 0, 0, 2, 7, 5, 0]
  // ];
  // time(() {
  //   sudokuSolverForce(matrix);
  // });
  // print(matrix.str);

  matrix = <List<int>>[
    <int>[0, 0, 3, 0, 0, 0, 0, 0, 9],
    <int>[0, 8, 0, 2, 0, 0, 6, 3, 0],
    <int>[0, 0, 0, 0, 0, 6, 0, 0, 4],
    <int>[0, 4, 0, 0, 5, 0, 0, 0, 0],
    <int>[0, 0, 0, 0, 0, 0, 0, 9, 0],
    <int>[0, 0, 5, 0, 0, 7, 3, 2, 0],
    <int>[1, 0, 0, 8, 0, 0, 0, 0, 0],
    <int>[0, 0, 0, 0, 0, 0, 0, 0, 6],
    <int>[0, 0, 4, 0, 0, 2, 7, 5, 0],
  ];
  // matrix = [
  //   [0, 0, 0, 7, 0, 0, 0, 0, 0],
  //   [1, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 4, 3, 0, 2, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 6],
  //   [0, 0, 0, 5, 0, 9, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 4, 1, 8],
  //   [0, 0, 0, 0, 8, 1, 0, 0, 0],
  //   [0, 0, 2, 0, 0, 0, 0, 5, 0],
  //   [0, 4, 0, 0, 0, 0, 3, 0, 0]
  // ];
  // matrix = [
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //   [0, 0, 0, 0, 0, 0, 0, 0, 0]
  // ];
  time(() {
    print(matrix.str);
    sudokuSolverOptimized(matrix);
  });
  print(matrix.str);
}
