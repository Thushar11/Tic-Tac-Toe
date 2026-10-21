import 'package:flutter/material.dart';

import '../game/game_logic.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Difficulty _difficulty = Difficulty.hard;

  void _start({required bool vsComputer}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          vsComputer: vsComputer,
          difficulty: _difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('X',
                      style: theme.textTheme.displayLarge?.copyWith(
                          color: colors.primary, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 12),
                  Text('O',
                      style: theme.textTheme.displayLarge?.copyWith(
                          color: colors.tertiary, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tic Tac Toe',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => _start(vsComputer: true),
                icon: const Icon(Icons.smart_toy_outlined),
                label: const Text('Play vs Computer'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 16),
              Text('Difficulty',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<Difficulty>(
                segments: const [
                  ButtonSegment(value: Difficulty.easy, label: Text('Easy')),
                  ButtonSegment(
                      value: Difficulty.medium, label: Text('Medium')),
                  ButtonSegment(value: Difficulty.hard, label: Text('Hard')),
                ],
                selected: {_difficulty},
                onSelectionChanged: (s) =>
                    setState(() => _difficulty = s.first),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => _start(vsComputer: false),
                icon: const Icon(Icons.people_outline),
                label: const Text('Two Players'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
