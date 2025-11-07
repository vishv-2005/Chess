import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Minimal UCI engine wrapper. Start once, send commands, read lines.
class UciEngine {
  final String enginePath;
  Process? _process;
  StreamSubscription<String>? _stdoutSub;
  final _lines = StreamController<String>.broadcast();

  UciEngine(this.enginePath);

  Future<void> start() async {
    if (_process != null) return;
    _process = await Process.start(enginePath, [], runInShell: true);
    _stdoutSub = _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_lines.add);
    // Initialize UCI
    await send('uci');
    await _waitFor('uciok', timeoutMs: 3000);
    await send('isready');
    await _waitFor('readyok', timeoutMs: 3000);
  }

  Future<void> stop() async {
    try {
      await send('quit');
      await _process?.kill();
    } catch (_) {}
    await _stdoutSub?.cancel();
    await _lines.close();
  }

  Future<void> send(String cmd) async {
    _process?.stdin.writeln(cmd);
    await _process?.stdin.flush();
  }

  Future<String?> _waitFor(String token, {int timeoutMs = 5000}) async {
    try {
      return await _lines.stream.firstWhere(
        (line) => line.contains(token),
      ).timeout(Duration(milliseconds: timeoutMs));
    } catch (_) {
      return null;
    }
  }

  /// Set position by FEN. Optionally include UCI moves list appended.
  Future<void> setPositionFen(String fen, {List<String>? moves}) async {
    final mv = (moves != null && moves.isNotEmpty) ? ' moves ${moves.join(' ')}' : '';
    await send('position fen $fen$mv');
  }

  /// Ask engine for best move. Returns bestmove token like e2e4 or null on error.
  Future<String?> go({int? movetimeMs, int? depth}) async {
    String command;
    int timeoutMs;
    if (depth != null) {
      command = 'go depth $depth';
      timeoutMs = 1000 * depth + 5000;
    } else {
      final time = movetimeMs ?? 1000;
      command = 'go movetime $time';
      timeoutMs = time + 5000;
    }
    await send(command);
    try {
      final line = await _lines.stream
          .firstWhere((l) => l.startsWith('bestmove'))
          .timeout(Duration(milliseconds: timeoutMs));
      final parts = line.split(' ');
      if (parts.length >= 2) return parts[1];
      return null;
    } catch (_) {
      return null;
    }
  }
}


