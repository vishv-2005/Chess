import 'dart:io';
import 'dart:math';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/engine/uci_engine.dart';
import 'package:chess/core/fen/fen.dart';
import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/moves/move_validator.dart';
import 'package:chess/core/engine/engine_difficulty.dart';

class StockfishService {
  // Attempt to find a bundled engine inside the project (lib directory)
  static String _resolveDefaultPath() {
    final bool isWindows = Platform.isWindows;
    final String base = Directory.current.path;

    String normalize(String relative) {
      return relative.replaceAll(RegExp(r'[\\/]'), Platform.pathSeparator);
    }

    String makeAbsolute(String candidate) {
      if (candidate.isEmpty) return base;
      final normalized = normalize(candidate);
      if (normalized.contains(':') || normalized.startsWith(Platform.pathSeparator)) {
        return normalized;
      }
      return base + Platform.pathSeparator + normalized;
    }

    String? firstExisting(List<String> candidates) {
      for (final candidate in candidates) {
        final file = File(makeAbsolute(candidate));
        if (file.existsSync()) return file.path;
      }
      return null;
    }

    String? scanDir(String dir) {
      final directory = Directory(makeAbsolute(dir));
      if (!directory.existsSync()) return null;
      try {
        for (final entity in directory.listSync(followLinks: false)) {
          if (entity is File) {
            final lower = entity.path.toLowerCase();
            if (isWindows && lower.endsWith('.exe') && lower.contains('stockfish')) {
              return entity.path;
            }
            if (!isWindows && lower.endsWith('stockfish')) {
              return entity.path;
            }
          }
        }
      } catch (_) {}
      return null;
    }

    final directMatch = firstExisting([
      isWindows ? 'lib/stockfish/stockfish.exe' : 'lib/stockfish/stockfish',
      isWindows ? 'lib/StockFish/stockfish.exe' : 'lib/StockFish/stockfish',
      isWindows ? 'lib/stockfish.exe' : 'lib/stockfish',
      isWindows ? 'lib/StockFish/stockfish-windows-x86-64-avx2.exe' : 'lib/StockFish/stockfish',
      isWindows ? 'stockfish.exe' : 'stockfish',
    ]);
    if (directMatch != null) return directMatch;

    final scanned = scanDir('lib/StockFish') ?? scanDir('lib/stockfish');
    if (scanned != null) return scanned;

    if (isWindows) {
      final fallback = File(r"C:\\StockFish\\stockfish.exe");
      if (fallback.existsSync()) return fallback.path;
    }

    return makeAbsolute(isWindows ? 'lib/stockfish/stockfish.exe' : 'lib/stockfish/stockfish');
  }

  UciEngine? _engine;
  bool _useFallback = false;
  EngineDifficulty _currentDifficulty = EngineDifficulty.defaultDifficulty;

  bool get isFallbackActive => _useFallback;

  Future<void> ensureStarted({String? enginePath}) async {
    final path = enginePath ?? _resolveDefaultPath();
    try {
      final file = File(path);
      if (!file.existsSync()) {
        _useFallback = true;
        return;
      }
      if (!Platform.isWindows) {
        try {
          await Process.run('chmod', ['+x', path]);
        } catch (_) {}
      }
      _engine ??= UciEngine(path);
      await _engine!.start();
      await _applyDifficultyOptions();
      _useFallback = false;
    } catch (_) {
      _useFallback = true;
    }
  }

  Future<void> setDifficulty(EngineDifficulty difficulty) async {
    _currentDifficulty = difficulty;
    if (_useFallback) return;
    await ensureStarted();
    if (_useFallback) return;
    await _applyDifficultyOptions();
  }

  /// Returns best move in UCI format like 'e2e4' or null on failure.
  Future<String?> getBestMove(BoardState state) async {
    await ensureStarted();
    if (_useFallback) {
      return _computeFallbackBestMove(state);
    }
    final fen = Fen.encode(state);
    await _engine!.setPositionFen(fen);
    return await _engine!.go(
      movetimeMs: _currentDifficulty.depth == null ? _currentDifficulty.moveTimeMs : null,
      depth: _currentDifficulty.depth,
    );
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
    final sampleSize = _fallbackSampleSize();
    candidates.shuffle(rng);
    final picks = candidates.take(sampleSize).toList();
    final pick = picks[rng.nextInt(picks.length)];
    return _rowColToUci(pick.sr, pick.sc) + _rowColToUci(pick.er, pick.ec);
  }

  Future<void> _applyDifficultyOptions() async {
    if (_engine == null) return;
    try {
      if (_currentDifficulty.elo >= 0 && _currentDifficulty.elo < 3000) {
        await _engine!.send('setoption name UCI_LimitStrength value true');
        await _engine!.send('setoption name UCI_Elo value ${_currentDifficulty.elo}');
      } else {
        await _engine!.send('setoption name UCI_LimitStrength value false');
      }
      await _engine!.send('setoption name Skill Level value ${_currentDifficulty.skillLevel}');
    } catch (_) {
      // ignore option errors
    }
  }

  int _fallbackSampleSize() {
    if (_currentDifficulty.skillLevel <= 2) return 1;
    if (_currentDifficulty.skillLevel <= 5) return 2;
    if (_currentDifficulty.skillLevel <= 10) return 4;
    if (_currentDifficulty.skillLevel <= 15) return 6;
    return 10;
  }
}

class _Candidate {
  final int sr;
  final int sc;
  final int er;
  final int ec;
  _Candidate(this.sr, this.sc, this.er, this.ec);
}


