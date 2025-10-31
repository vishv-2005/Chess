import 'package:flutter/material.dart';
import 'package:passant/components/dead_piece.dart';
import 'package:passant/components/piece.dart';
import 'package:passant/components/square.dart';
import 'package:passant/helper/help_method.dart';
import 'package:passant/values/colors.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;

  // currently selected piece on the chess board
  // if no piece is selected, this is null
  ChessPiece? selectedPiece;

  // The row and col index of the selected piece
  // default value -1 indicates no piece is currently selected
  int selectedRow = -1;
  int selectedCol = -1;

  // A list of valid moves for the currently selected piece
  // each move is represented with rows and cols
  List<List<int>> validMoves = [];

  // A list of white pieces that have been taken by the black plyaer
  List<ChessPiece> whitePiecesTaken = [];

  // A list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken = [];

  // A boolean to indicate whos turn it is
  bool isWhiteTurn = true;

  // inital position of kings (keep track of this to make it easier later to see if king is in check)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  // //castling conditions
  bool whiteKingMoved = false;
  bool blackKingMoved = false;
  bool whiteLeftRookMoved = false;
  bool whiteRightRookMoved = false;
  bool blackLeftRookMoved = false;
  bool blackRightRookMoved = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    //initalize the board with nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard = List.generate(
      8,
      (index) => List.generate(8, (index) => null),
    );

    // place random piece to test
    // newBoard[2][3] = ChessPiece(
    //   type: ChessPieceType.bishop,
    //   isWhite: true,
    //   imagePath: 'lib/assets/wB.svg',
    // );

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'lib/assets/bP.svg',
      );

      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'lib/assets/wP.svg',
      );
    }
    // Place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/assets/bR.svg',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/assets/bR.svg',
    );

    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/assets/wR.svg',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/assets/wR.svg',
    );

    // Place knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/assets/bN.svg',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/assets/bN.svg',
    );

    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/assets/wN.svg',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/assets/wN.svg',
    );

    // Place bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/assets/bB.svg',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/assets/bB.svg',
    );

    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/assets/wB.svg',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/assets/wB.svg',
    );

    // Place queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/assets/bQ.svg',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/assets/wQ.svg',
    );

    // Place kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/assets/bK.svg',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/assets/wK.svg',
    );

    board = newBoard;
  }

  // USER SELECTED PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // No piece has been selected yet, this is the first selection
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      // There is a piece already selected, but user can select another one of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      //if there is a piece that is selected and user taps on a square that is a valid move, move there
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // if a piece is selected, calculate it's valid moves
      validMoves = calculateRealValidMoves(
        selectedRow,
        selectedCol,
        selectedPiece,
        true,
      );
    });
  }

  // CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }
    // different directiosn based on their color
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // pawns can move 2 square if they are at their initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // pawns can capture a piece diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        // horizonal and vertical direction
        var directions = [
          [-1, 0], //up
          [1, 0], // down
          [0, -1], // left
          [0, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break;
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        //all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [1, -2], // down 1 left 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
          [-1, 2], // up 1 right 2
          [1, 2], // down 1 right 2
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); //capture
            }
            continue; // blocked
          }

          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        // diagonal directions
        var directions = [
          [1, 1], // down 1 right  1
          [1, -1], //down 1 left 1
          [-1, -1], // up 1 left 1
          [-1, 1], // up 1 right 1
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); //capture
              }
              break;
            }

            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        // all eight directions: up, down, left, right and 4 diagonals
        var directions = [
          [-1, 0], //up
          [1, 0], // down
          [0, -1], // left
          [0, 1], //right
          [1, 1], // down 1 right  1
          [1, -1], //down 1 left 1
          [-1, -1], // up 1 left 1
          [-1, 1], // up 1 right 1
        ];
        for (var direction in directions) {
          int i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        // all eight directions
        var directions = [
          [-1, 0], //up
          [1, 0], // down
          [0, -1], // left
          [0, 1], //right
          [1, 1], // down 1 right  1
          [1, -1], //down 1 left 1
          [-1, -1], // up 1 left 1
          [-1, 1], // up 1 right 1
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }

        // // castling
        if (piece.isWhite) {
          if (!whiteKingMoved && row == 7 && col == 4) {
            // king side castle
            if (!whiteRightRookMoved &&
                board[7][7] != null &&
                board[7][7]!.type == ChessPieceType.rook &&
                board[7][7]!.isWhite &&
                board[7][6] == null &&
                board[7][5] == null) {
              candidateMoves.add([7, 6]);
            }

            // queen side castle
            if (!whiteLeftRookMoved &&
                board[7][0] != null &&
                board[7][0]!.type == ChessPieceType.rook &&
                board[7][0]!.isWhite &&
                board[7][3] == null &&
                board[7][2] == null &&
                board[7][1] == null) {
              candidateMoves.add([7, 2]);
            }
          }
        } else {
          if (!blackKingMoved && row == 0 && col == 4) {
            // Kingside castling (to [0,6])
            if (!blackRightRookMoved &&
                board[0][7] != null &&
                board[0][7]!.type == ChessPieceType.rook &&
                !board[0][7]!.isWhite &&
                board[0][5] == null &&
                board[0][6] == null) {
              candidateMoves.add([0, 6]);
            }
            // Queenside castling (to [0,2])
            if (!blackLeftRookMoved &&
                board[0][0] != null &&
                board[0][0]!.type == ChessPieceType.rook &&
                !board[0][0]!.isWhite &&
                board[0][1] == null &&
                board[0][2] == null &&
                board[0][3] == null) {
              candidateMoves.add([0, 2]);
            }
          }
        }
        break;
      // default:
    }

    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    ChessPiece? piece,
    bool checkSimulation,
  ) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // after generatig all candidate moves, filter out any that would result in a check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // this will simulate the future move to see if it's safe
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          // check if the move is castling
          if (piece.type == ChessPieceType.king &&
              col == 4 &&
              (endCol == 6 || endCol == 2)) {
            int direction = endCol == 6 ? 1 : -1;

            bool pathSafe = true;

            for (int i = col; i != endCol + direction; i += direction) {
              if (!simulatedMoveIsSafe(piece, row, col, endRow, i)) {
                pathSafe = false;
              }
            }

            if (pathSafe) realValidMoves.add(move);
          } else {
            realValidMoves.add(move);
          }
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  // MOVE PIECE
  void movePiece(int newRow, int newCol) {
    // if the new spot has an enemy piece
    if (board[newRow][newCol] != null) {
      // add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // check if the piece being moved in the king
    if (selectedPiece!.type == ChessPieceType.king) {
      // update the appropriate king position
      if (selectedPiece!.isWhite) {
        whiteKingMoved = true;

        // Castling
        if (selectedRow == 7 &&
            selectedCol == 4 &&
            newRow == 7 &&
            newCol == 6) {
          // King Side Castle
          board[7][5] = board[7][7];
          board[7][7] = null;
          whiteRightRookMoved = true;
        } else if (selectedRow == 7 &&
            selectedCol == 4 &&
            newRow == 7 &&
            newCol == 2) {
          // King Side Castle
          board[7][3] = board[7][0];
          board[7][0] = null;
          whiteLeftRookMoved = true;
        }

        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingMoved = true;

        // Black kingside castle
        if (selectedRow == 0 &&
            selectedCol == 4 &&
            newRow == 0 &&
            newCol == 6) {
          board[0][5] = board[0][7];
          board[0][7] = null;
          blackRightRookMoved = true;
        }
        // Black queenside castle
        if (selectedRow == 0 &&
            selectedCol == 4 &&
            newRow == 0 &&
            newCol == 2) {
          board[0][3] = board[0][0];
          board[0][0] = null;
          blackLeftRookMoved = true;
        }

        blackKingPosition = [newRow, newCol];
      }
    }

    if (selectedPiece!.type == ChessPieceType.rook) {
      if (selectedPiece!.isWhite) {
        if (selectedRow == 7 && selectedCol == 0) whiteLeftRookMoved = true;
        if (selectedRow == 7 && selectedCol == 7) whiteRightRookMoved = true;
      } else {
        if (selectedRow == 0 && selectedCol == 0) blackLeftRookMoved = true;
        if (selectedRow == 0 && selectedCol == 7) blackRightRookMoved = true;
      }
    }

    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // see if any kings are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if it's checkmate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("CHECK MATE"),
          actions: [
            // play the game again
            TextButton(onPressed: resetGame, child: const Text("Play again")),
          ],
        ),
      );
    }

    // change turns
    isWhiteTurn = !isWhiteTurn;
  }

  // IS KING IN CHECK
  bool isKingInCheck(bool isWhiteKing) {
    // get the position of the king
    List<int> kingPosition = isWhiteKing
        ? whiteKingPosition
        : blackKingPosition;

    // check if any enemy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and pieces of the same color
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(
          i,
          j,
          board[i][j],
          false,
        );

        // check if the king's position is in this pieces's valid moves
        if (pieceValidMoves.any(
          (move) => move[0] == kingPosition[0] && move[1] == kingPosition[1],
        )) {
          return true;
        }
      }
    }

    return false;
  }

  // SIMULATE A FUTURE TO SEE IF IT'S SAFE (DOESN'T PUT YOUR OWN KING UNDER ATTACK)
  bool simulatedMoveIsSafe(
    ChessPiece piece,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    // save the current board state
    ChessPiece? originalDesitinationPiece = board[endRow][endCol];

    // if the piece is the king, save it's current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition = piece.isWhite
          ? whiteKingPosition
          : blackKingPosition;

      // update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our own king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // restre board to orignal state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDesitinationPiece;

    // if the piece was the king, restore it original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    // if king is in check = true, means it's not safe. safe move = false
    return !kingInCheck;
  }

  // IS IT CHECKMATE?
  bool isCheckMate(bool isWhiteKing) {
    // if the king is not in check, then it's not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    // if there is at least one legal move for any of the players's piece, then it's not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and pieces of the same color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateRealValidMoves(
          i,
          j,
          board[i][j],
          true,
        );

        // if this piece has any valid moves, then it's not checkmate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // if none of the above conditions are not, then there are no legal moves left to make
    // it's check mate!

    return true;
  }

  // RESET THE GAME
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chess"), centerTitle: true),
      backgroundColor: foregroundColor,
      body: Column(
        children: [
          // WHITE PIECE TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          // GAME STATUS
          Text(checkStatus ? "CHECK!" : ""),

          // CHESS BOARD
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                //get teh row and col position of this square
                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = selectedRow == row && selectedCol == col;

                //check if this square is a vaild move
                bool isValidMove = false;
                for (var position in validMoves) {
                  //compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }
                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () {
                    pieceSelected(row, col);
                  },
                );
              },
            ),
          ),

          // BLACK PIECE TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
