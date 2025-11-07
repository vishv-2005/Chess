import 'dart:io';
import 'dart:math';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/engine/uci_engine.dart';
import 'package:chess/core/fen/fen.dart';
import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/moves/move_validator.dart';

class StockfishService {
  // Attempt to find a bundled engine inside the project (lib directory)
  static String _resolveDefaultPath() {
    final bool isWindows = Platform.isWindows;

    String? _firstExisting(List<String> paths) {
      for (final p in paths) {
        final file = File(p);
        if (file.existsSync()) return file.path;
      }
      return null;
    }

    String? _scanDirForEngine(String dirPath) {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) return null;
      try {
        final entries = dir.listSync(recursive: false, followLinks: false);
        for (final entity in entries) {
          if (entity is File) {
            final name = entity.path.split(Platform.pathSeparator).last.toLowerCase();
            if (isWindows && name.endsWith('.exe') && name.contains('stockfish')) {
              return entity.path;
            }
            if (!isWindows && name == 'stockfish') {
              return entity.path;
            }
          }
        }
      } catch (_) {}
      return null;
    }

    // Direct candidates (common names)
    final directCandidate = _firstExisting([
      isWindows ? 'lib/stockfish/stockfish.exe' : 'lib/stockfish/stockfish',
      isWindows ? 'lib/StockFish/stockfish.exe' : 'lib/StockFish/stockfish',
      isWindows ? 'lib/stockfish.exe' : 'lib/stockfish',
      isWindows ? 'assets/stockfish/stockfish.exe' : 'assets/stockfish/stockfish',
    ]);
    if (directCandidate != null) return directCandidate;

    // Scan directories for a Stockfish executable
    final scanCandidate = _scanDirForEngine('lib/stockfish') ??
        _scanDirForEngine('lib/StockFish') ??
        _scanDirForEngine('assets/stockfish');
    if (scanCandidate != null) return scanCandidate;

    // Fallback to Windows installation
    if (isWindows) {
      final fallback = File(r"C:\\StockFish\\stockfish.exe");
      if (fallback.existsSync()) return fallback.path;
    }

    // Nothing found; return first direct path so callers see a useful path in errors
    return isWindows ? 'lib/stockfish/stockfish.exe' : 'lib/stockfish/stockfish';
  }

  UciEngine? _engine;
  bool _useFallback = false;

  Future<void> ensureStarted({String? enginePath}) async {
    final path = enginePath ?? _resolveDefaultPath();
    try {
      if (!File(path).existsSync()) {
        // No engine at path; fall back
        _useFallback = true;
        return;
      }
      // On Unix-like systems, ensure executable bit
      if (!Platform.isWindows) {
        try {
          await Process.run('chmod', ['+x', path]);
        } catch (_) {}
      }
      _engine ??= UciEngine(path);
      await _engine!.start();
      _useFallback = false;
    } catch (_) {
      // Engine failed to start (likely on Android). Use fallback.
      _useFallback = true;
    }
  }

  /// Returns best move in UCI format like 'e2e4' or null on failure.
  Future<String?> getBestMove(BoardState state, {int movetimeMs = 1500}) async {
    await ensureStarted();
    if (_useFallback) {
      return _computeFallbackBestMove(state);
    }
    final fen = Fen.encode(state);
    await _engine!.setPositionFen(fen);
    return await _engine!.go(movetimeMs: movetimeMs);
  }

  static List<int> uciSquareToRowCol(String sq) {
    // e2 => row 6, col 4
    final file = sq.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(sq[1]);
    final row = 8 - rank;
    final col = file;
    return [row, col];
  }

  static String _rowColToUci(int row, int col) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = (8 - row).toString();
    return file + rank;
  }

  /// Very simple fallback: choose a random legal move for the side to move.
  String? _computeFallbackBestMove(BoardState state) {
    final rng = Random();
    final isWhite = state.isWhiteTurn;
    final List<_Candidate> candidates = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = state.board[r][c];
        if (piece == null || piece.isWhite != isWhite) continue;
        final moves = MoveValidator.calculateRealValidMoves(
          r,
          c,
          piece,
          false,
          state,
        );
        for (final mv in moves) {
          candidates.add(_Candidate(r, c, mv[0], mv[1]));
        }
      }
    }
    if (candidates.isEmpty) return null;
    final pick = candidates[rng.nextInt(candidates.length)];
    return _rowColToUci(pick.sr, pick.sc) + _rowColToUci(pick.er, pick.ec);
  }
}

class _Candidate {
  final int sr;
  final int sc;
  final int er;
  final int ec;
  _Candidate(this.sr, this.sc, this.er, this.ec);
}


