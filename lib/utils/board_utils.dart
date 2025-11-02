// Utility functions for board-related operations

/// Determines if a square should be white/light colored based on its index
bool isWhite(int index) {
  int x = index ~/ 8; // this gives us the integer division ie, row
  int y = index % 8; // this gives us the remainder ie, column

  // alternate colors for each square
  bool isWhite = (x + y) % 2 == 0;

  return isWhite;
}

/// Checks if the given row and column are within board boundaries (0-7)
bool isInBoard(int row, int col) {
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}

