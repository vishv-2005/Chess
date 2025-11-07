import 'package:flutter/material.dart';
import 'package:chess/ui/components/dead_piece.dart';
import 'package:chess/ui/components/square.dart';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/board/board_initializer.dart';
import 'package:chess/core/moves/move_executor.dart';
import 'package:chess/core/game_state/game_state_manager.dart';
import 'package:chess/utils/board_utils.dart';
import 'package:chess/ui/themes/app_theme.dart';
import 'package:chess/ui/components/promotion_dialog.dart';
import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/engine/stockfish_service.dart';
import 'package:chess/core/engine/engine_difficulty.dart';

class GameBoard extends StatefulWidget {
  final bool playVsComputer;
  final bool computerIsWhite;
  final String? difficultyId;

  const GameBoard({
    super.key,
    this.playVsComputer = false,
    this.computerIsWhite = false,
    this.difficultyId,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late BoardState boardState;
  final StockfishService _engine = StockfishService();
  late EngineDifficulty _difficulty;
  bool _fallbackNotified = false;

  @override
  void initState() {
    super.initState();
    final initialBoard = BoardInitializer.initializeBoard();
    boardState = BoardState(board: initialBoard);
    boardState.playVsComputer = widget.playVsComputer;
    boardState.computerIsWhite = widget.computerIsWhite;
    boardState.engineDifficultyId = widget.difficultyId ?? boardState.engineDifficultyId;
    _difficulty = EngineDifficulty.byId(boardState.engineDifficultyId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _engine.setDifficulty(_difficulty);
      if (boardState.playVsComputer &&
          boardState.computerIsWhite == boardState.isWhiteTurn) {
        await _playEngineMove();
      }
    });
  }

  // USER SELECTED PIECE
  void pieceSelected(int row, int col) {
    // Don't allow any moves if game is over
    if (boardState.gameOver) {
      return;
    }
    
    setState(() {
      // No piece has been selected yet, this is the first selection
      if (boardState.selectedPiece == null && boardState.board[row][col] != null) {
        if (boardState.board[row][col]!.isWhite == boardState.isWhiteTurn) {
          boardState.selectedPiece = boardState.board[row][col];
          boardState.selectedRow = row;
          boardState.selectedCol = col;
        }
      }
      // There is a piece already selected, but user can select another one of their pieces
      else if (boardState.board[row][col] != null &&
          boardState.board[row][col]!.isWhite == boardState.selectedPiece?.isWhite) {
        boardState.selectedPiece = boardState.board[row][col];
        boardState.selectedRow = row;
        boardState.selectedCol = col;
      }
      // if there is a piece that is selected and user taps on a square that is a valid move, move there
      else if (boardState.selectedPiece != null &&
          boardState.validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // if a piece is selected, calculate its valid moves
      boardState.validMoves = GameStateManager.getValidMoves(
        boardState.selectedRow,
        boardState.selectedCol,
        boardState.selectedPiece,
        boardState,
      );


    });
  }

  // MOVE PIECE
  void movePiece(int newRow, int newCol) async {
    bool needsPromotion = MoveExecutor.executeMove(
      boardState.selectedRow,
      boardState.selectedCol,
      newRow,
      newCol,
      boardState,
    );

    // If pawn promotion is needed, show dialog
    if (needsPromotion) {
      setState(() {});
      
      // Show promotion dialog
      ChessPieceType? promotionType = await showDialog<ChessPieceType>(
        context: context,
        builder: (context) => PromotionDialog(
          isWhite: boardState.board[newRow][newCol]?.isWhite ?? false,
        ),
      );

      // Apply promotion (default to queen if dialog was dismissed)
      if (promotionType != null) {
        MoveExecutor.applyPromotion(newRow, newCol, promotionType, boardState);
      } else {
        // If dialog was dismissed, default to queen
        MoveExecutor.applyPromotion(newRow, newCol, ChessPieceType.queen, boardState);
      }
    }

    // see if any kings are under attack
    GameStateManager.updateCheckStatus(boardState);

    setState(() {});

    // check if it's checkmate
    if (GameStateManager.isCheckmate(boardState)) {
      // Set game over flag and determine winner
      // isCheckmate checks the player whose turn it is now (the one who just received the move)
      // If checkmate is true, that player is checkmated
      // The winner is the player who just moved (the opposite of current turn)
      boardState.gameOver = true;
      boardState.winnerIsWhite = !boardState.isWhiteTurn; // Winner is the player who just moved
      
      // Clear any selected piece
      boardState.selectedPiece = null;
      boardState.selectedRow = -1;
      boardState.selectedCol = -1;
      boardState.validMoves = [];
      
      setState(() {});
      
      // Show winner dialog
      String winnerColor = boardState.winnerIsWhite! ? "White" : "Black";
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppTheme.primaryColor,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration, color: AppTheme.accentColor, size: 32),
              SizedBox(width: 12),
              Text(
                "CHECKMATE!",
                style: TextStyle(
                  color: AppTheme.textColorLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "$winnerColor won!",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColorLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(color: AppTheme.textColorLight),
              ),
            ),
            ElevatedButton(
              onPressed: resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Play Again"),
            ),
          ],
        ),
      );
    }

    // If playing vs computer and it's now engine's turn, trigger engine move
    if (boardState.playVsComputer && !boardState.gameOver) {
      bool engineTurnIsWhite = boardState.isWhiteTurn;
      if (engineTurnIsWhite == boardState.computerIsWhite) {
        await _playEngineMove();
      }
    }
  }

  // RESET THE GAME
  void resetGame() {
    Navigator.pop(context);
    final initialBoard = BoardInitializer.initializeBoard();
    final bool wasComputer = boardState.playVsComputer;
    final bool computerWhite = boardState.computerIsWhite;
    final String difficultyId = boardState.engineDifficultyId;
    boardState = BoardState(board: initialBoard);
    boardState.gameOver = false;
    boardState.winnerIsWhite = null;
    boardState.playVsComputer = wasComputer;
    boardState.computerIsWhite = computerWhite;
    boardState.engineDifficultyId = difficultyId;
    setState(() {});
  }

  Future<void> _playEngineMove() async {
    try {
      // Ask engine for best move
      final uci = await _engine.getBestMove(boardState);
      if (_engine.isFallbackActive && !_fallbackNotified) {
        _fallbackNotified = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using fallback AI. Stockfish binary not found or failed to start.'),
            ),
          );
        }
      }
      if (uci == null || uci.length < 4) return;
      final fromSq = uci.substring(0, 2);
      final toSq = uci.substring(2, 4);
      final from = StockfishService.uciSquareToRowCol(fromSq);
      final to = StockfishService.uciSquareToRowCol(toSq);

      // Handle optional promotion character (e.g., e7e8q)
      bool needsPromotion = MoveExecutor.executeMove(
        from[0],
        from[1],
        to[0],
        to[1],
        boardState,
      );
      if (needsPromotion) {
        // Default to queen for engine promotions
        MoveExecutor.applyPromotion(to[0], to[1], ChessPieceType.queen, boardState);
      }

      GameStateManager.updateCheckStatus(boardState);
      setState(() {});
    } catch (_) {
      // ignore engine errors for now
    }
  }

  String _getCoordinateLabel(int row, int col) {
    // Show coordinates on the edges
    String label = '';
    if (row == 7) {
      // Bottom row - show file letters (a-h)
      label = String.fromCharCode(97 + col); // 'a' to 'h'
    }
    if (col == 0) {
      // Left column - show rank numbers (1-8)
      label = '${8 - row}';
    }
    return label;
  }

  bool _isKingInCheck(int row, int col) {
    if (boardState.board[row][col]?.type != ChessPieceType.king) {
      return false;
    }
    return boardState.checkStatus && 
           boardState.board[row][col]?.isWhite == boardState.isWhiteTurn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chess",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textColorLight,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(boardState.playVsComputer ? Icons.computer : Icons.computer_outlined),
            tooltip: 'Play vs Computer',
            onPressed: () async {
              setState(() {
                boardState.playVsComputer = !boardState.playVsComputer;
                // Default: computer plays Black
                boardState.computerIsWhite = false;
              });
              // If computer plays white and it's white to move, let engine move immediately
              if (boardState.playVsComputer && boardState.computerIsWhite == boardState.isWhiteTurn) {
                await _engine.setDifficulty(_difficulty);
                await _playEngineMove();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Game',
            onPressed: boardState.gameOver ? null : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Game'),
                  content: const Text('Are you sure you want to reset the game?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        resetGame();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // BLACK PIECES TAKEN (Top)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: boardState.blackPiecesTaken.isEmpty
                  ? const Center(
                      child: Text(
                        'Black Captured',
                        style: TextStyle(
                          color: AppTheme.textColorLight,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: boardState.blackPiecesTaken.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 4,
                      ),
                      itemBuilder: (context, index) => DeadPiece(
                        imagePath: boardState.blackPiecesTaken[index].imagePath,
                        isWhite: false,
                      ),
                    ),
            ),

            // GAME STATUS
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (boardState.playVsComputer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.computer, size: 16, color: AppTheme.textColorLight),
                          const SizedBox(width: 6),
                          Text(
                            _difficulty.name,
                            style: const TextStyle(
                              color: AppTheme.textColorLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (boardState.gameOver)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.checkSquare,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.celebration, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            boardState.winnerIsWhite != null
                                ? "${boardState.winnerIsWhite! ? "White" : "Black"} Wins!"
                                : "Game Over",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (boardState.checkStatus)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.checkSquare.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "CHECK!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            boardState.isWhiteTurn
                                ? Icons.circle
                                : Icons.circle_outlined,
                            color: boardState.isWhiteTurn
                                ? Colors.white
                                : Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${boardState.isWhiteTurn ? "White" : "Black"}'s Turn",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColorLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // CHESS BOARD
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.textColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  itemCount: 8 * 8,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) {
                    // get the row and col position of this square
                    int row = index ~/ 8;
                    int col = index % 8;

                    bool isSelected =
                        boardState.selectedRow == row &&
                        boardState.selectedCol == col;

                    // check if this square is a valid move
                    bool isValidMove = false;
                    for (var position in boardState.validMoves) {
                      // compare row and col
                      if (position[0] == row && position[1] == col) {
                        isValidMove = true;
                      }
                    }

                    String coordinateLabel = _getCoordinateLabel(row, col);
                    bool isInCheck = _isKingInCheck(row, col);

                    bool isLastFrom = boardState.lastMoveFrom != null &&
                        boardState.lastMoveFrom![0] == row &&
                        boardState.lastMoveFrom![1] == col;
                    bool isLastTo = boardState.lastMoveTo != null &&
                        boardState.lastMoveTo![0] == row &&
                        boardState.lastMoveTo![1] == col;

                    return Square(
                      isWhite: isWhite(index),
                      piece: boardState.board[row][col],
                      isSelected: isSelected,
                      isValidMove: isValidMove,
                      coordinateLabel: coordinateLabel.isNotEmpty
                          ? coordinateLabel
                          : null,
                      isInCheck: isInCheck,
                      isLastFrom: isLastFrom,
                      isLastTo: isLastTo,
                      onTap: () {
                        pieceSelected(row, col);
                      },
                    );
                  },
                ),
              ),
            ),

            // WHITE PIECES TAKEN (Bottom)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.3),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: boardState.whitePiecesTaken.isEmpty
                  ? const Center(
                      child: Text(
                        'White Captured',
                        style: TextStyle(
                          color: AppTheme.textColorLight,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: boardState.whitePiecesTaken.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 4,
                      ),
                      itemBuilder: (context, index) => DeadPiece(
                        imagePath: boardState.whitePiecesTaken[index].imagePath,
                        isWhite: true,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

