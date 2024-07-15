import 'dart:math';

class Board {
  final int row;
  final int column;
  int score;
  List<List<Tile>>? boardTiles;

  Board(this.row, this.column, this.score) {
    initBoard();
  }

  void initBoard() {
    boardTiles = List.generate(
      row,
      (r) => List.generate(
        column,
        (c) => Tile(
          row: r,
          column: c,
          value: 0,
          isNew: false,
          canMerge: false,
        ),
      ),
    );
    score = 0;
    resetCanMerge();
    randomEmptyTile();
    randomEmptyTile();
  }

  void moveLeft() {
    if (!canMoveLeft()) return;
    for (int r = 0; r < row; ++r) {
      for (int c = 1; c < column; ++c) {
        mergeLeft(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveRight() {
    if (!canMoveRight()) return;
    for (int r = 0; r < row; ++r) {
      for (int c = column - 2; c >= 0; --c) {
        mergeRight(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveUp() {
    if (!canMoveUp()) return;
    for (int r = 1; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        mergeUp(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveDown() {
    if (!canMoveDown()) return;
    for (int r = row - 2; r >= 0; --r) {
      for (int c = 0; c < column; ++c) {
        mergeDown(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  bool canMoveLeft() {
    for (int r = 0; r < row; ++r) {
      for (int c = 1; c < column; ++c) {
        if (canMerge(boardTiles![r][c], boardTiles![r][c - 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveRight() {
    for (int r = 0; r < row; ++r) {
      for (int c = column - 2; c >= 0; --c) {
        if (canMerge(boardTiles![r][c], boardTiles![r][c + 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveUp() {
    for (int r = 1; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        if (canMerge(boardTiles![r][c], boardTiles![r - 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveDown() {
    for (int r = row - 2; r >= 0; --r) {
      for (int c = 0; c < column; ++c) {
        if (canMerge(boardTiles![r][c], boardTiles![r + 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  void mergeLeft(int row, int col) {
    while (col > 0) {
      merge(boardTiles![row][col], boardTiles![row][col - 1]);
      col = col - 1;
    }
  }

  void mergeRight(int row, int col) {
    while (col < column - 1) {
      merge(boardTiles![row][col], boardTiles![row][col + 1]);
      col = col + 1;
    }
  }

  void mergeUp(int row, int col) {
    while (row > 0) {
      merge(boardTiles![row][col], boardTiles![row - 1][col]);
      row = row - 1;
    }
  }

  void mergeDown(int row, int col) {
    while (row < this.row - 1) {
      merge(boardTiles![row][col], boardTiles![row + 1][col]);
      row = row + 1;
    }
  }

  bool canMerge(Tile a, Tile b) {
    return !a.canMerge &&
        ((b.isEmpty() && !a.isEmpty()) || (a.value == b.value && !a.isEmpty()));
  }

  void randomEmptyTile() {
    List<Tile> empty = [];

    for (var rows in boardTiles!) {
      for (var tile in rows) {
        if (tile.isEmpty()) {
          empty.add(tile);
        }
      }
    }

    if (empty.isEmpty) return;

    Random rng = Random();
    int index = rng.nextInt(empty.length);
    empty[index].value = rng.nextInt(10) == 0 ? 4 : 2;
    empty[index].isNew = true;
  }

  void resetCanMerge() {
    for (var rows in boardTiles!) {
      for (var tile in rows) {
        tile.canMerge = false;
      }
    }
  }

  void merge(Tile a, Tile b) {
    if (b.isEmpty()) {
      b.value = a.value;
      a.value = 0;
    } else if (a.value == b.value) {
      b.value += a.value;
      score += b.value;
      a.value = 0;
      b.canMerge = true;
    }
  }

  Tile getTile(int row, int column) {
    return boardTiles![row][column];
  }
}

class Tile {
  final int row;
  final int column;
  int value;
  bool canMerge;
  bool isNew;

  Tile({
    required this.row,
    required this.column,
    this.value = 0,
    this.canMerge = false,
    this.isNew = false,
  });

  bool isEmpty() {
    return value == 0;
  }

  @override
  int get hashCode {
    return value.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is Tile && value == other.value;
  }
}
