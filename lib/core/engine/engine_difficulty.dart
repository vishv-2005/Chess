class EngineDifficulty {
  final String id;
  final String name;
  final int elo;
  final int skillLevel; // 0-20 for Stockfish skill level
  final int moveTimeMs;
  final int? depth;

  const EngineDifficulty({
    required this.id,
    required this.name,
    required this.elo,
    required this.skillLevel,
    required this.moveTimeMs,
    this.depth,
  });

  static const List<EngineDifficulty> presets = [
    EngineDifficulty(
      id: 'martin',
      name: 'Martin (400)',
      elo: 400,
      skillLevel: 1,
      moveTimeMs: 400,
    ),
    EngineDifficulty(
      id: 'sophia',
      name: 'Sophia (800)',
      elo: 800,
      skillLevel: 5,
      moveTimeMs: 800,
    ),
    EngineDifficulty(
      id: 'beth',
      name: 'Meet (1400)',
      elo: 1400,
      skillLevel: 10,
      moveTimeMs: 1500,
    ),
    EngineDifficulty(
      id: 'hikaru',
      name: 'Vishv (2000)',
      elo: 2000,
      skillLevel: 15,
      moveTimeMs: 2500,
    ),
    EngineDifficulty(
      id: 'magnus',
      name: 'Rudra (2800)',
      elo: 2800,
      skillLevel: 20,
      moveTimeMs: 3500,
      depth: 22,
    ),
  ];

  static EngineDifficulty get defaultDifficulty => presets[2];

  static EngineDifficulty byId(String? id) {
    if (id == null) return defaultDifficulty;
    return presets.firstWhere(
      (d) => d.id == id,
      orElse: () => defaultDifficulty,
    );
  }
}


