import 'package:flutter/material.dart';
import 'package:chess/ui/screens/game_board.dart';
import 'package:chess/ui/themes/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:chess/core/engine/engine_difficulty.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  EngineDifficulty _selectedDifficulty = EngineDifficulty.defaultDifficulty;
  bool _computerIsWhite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Chess Icon/Title
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_esports,
                      size: 80,
                      color: AppTheme.textColorLight,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  const Text(
                    'CHESS',
                    style: AppTheme.titleStyle,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Master the Game',
                    style: AppTheme.subtitleStyle,
                  ),
                  const SizedBox(height: 64),
                  
                  // Play Against Computer Button
                  _buildMenuButton(
                    context,
                    icon: Icons.computer,
                    label: 'Play Against Computer',
                    onPressed: () async {
                      await _openComputerOptions(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Over the Board Button
                  _buildMenuButton(
                    context,
                    icon: Icons.people,
                    label: 'Over the Board',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameBoard(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Exit Button
                  TextButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: const Text(
                      'Exit',
                      style: TextStyle(
                        color: AppTheme.textColorLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openComputerOptions(BuildContext context) async {
    EngineDifficulty tempDifficulty = _selectedDifficulty;
    bool tempComputerIsWhite = _computerIsWhite;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        const Text(
                          'Choose Opponent',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColorLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...EngineDifficulty.presets.map((difficulty) {
                          final selected = difficulty.id == tempDifficulty.id;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.accentColor.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? AppTheme.accentColor
                                    : Colors.white70,
                              ),
                              title: Text(
                                difficulty.name,
                                style: const TextStyle(
                                  color: AppTheme.textColorLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                difficulty.depth != null
                                    ? 'Skill ${difficulty.skillLevel}, depth ${difficulty.depth}'
                                    : 'Skill ${difficulty.skillLevel}, think ${difficulty.moveTimeMs ~/ 1000}s',
                                style: const TextStyle(color: AppTheme.textColorLight),
                              ),
                              onTap: () {
                                setModalState(() {
                                  tempDifficulty = difficulty;
                                });
                              },
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          value: tempComputerIsWhite,
                          onChanged: (value) {
                            setModalState(() {
                              tempComputerIsWhite = value;
                            });
                          },
                          title: const Text(
                            'Computer Plays White',
                            style: TextStyle(
                              color: AppTheme.textColorLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          activeColor: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text(
                              'Start Game',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.pop(context, {
                                'difficulty': tempDifficulty,
                                'computerWhite': tempComputerIsWhite,
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (result != null) {
      final difficulty = result['difficulty'] as EngineDifficulty;
      final computerWhite = result['computerWhite'] as bool;
      setState(() {
        _selectedDifficulty = difficulty;
        _computerIsWhite = computerWhite;
      });

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameBoard(
            playVsComputer: true,
            computerIsWhite: computerWhite,
            difficultyId: difficulty.id,
          ),
        ),
      );
    }
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: AppTheme.buttonTextStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

