import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/game_logic.dart';

class GameScreen extends StatefulWidget {
  final bool vsComputer;
  final Difficulty difficulty;

  const GameScreen({
    super.key,
    required this.vsComputer,
    this.difficulty = Difficulty.hard,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const Player _human = Player.x;

  final TicTacToeAI _ai = TicTacToeAI();
  List<Player?> _board = List.filled(9, null);
  Player _current = Player.x;
  Player _startingPlayer = Player.x;
  GameResult? _result;
  bool _aiThinking = false;
  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;

  bool get _isAiTurn => widget.vsComputer && _current != _human;

  void _tap(int index) {
    if (_board[index] != null || _result != null || _aiThinking || _isAiTurn) {
      return;
    }
    HapticFeedback.selectionClick();
    _play(index);
  }

  void _play(int index) {
    setState(() {
      _board[index] = _current;
      _result = GameLogic.evaluate(_board);
      if (_result == null) {
        _current = _current.opponent;
      } else {
        _recordResult(_result!);
      }
    });
    if (_result == null && _isAiTurn) _aiMove();
  }

  Future<void> _aiMove() async {
    setState(() => _aiThinking = true);
    // Small delay so the computer's move feels natural.
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final move = _ai.bestMove(_board, _current, widget.difficulty);
    setState(() => _aiThinking = false);
    _play(move);
  }

  void _recordResult(GameResult result) {
    if (result.isDraw) {
      _draws++;
    } else if (result.winner == Player.x) {
      _xWins++;
    } else {
      _oWins++;
    }
    HapticFeedback.mediumImpact();
  }

  void _newRound() {
    setState(() {
      _board = List.filled(9, null);
      _result = null;
      // Alternate who starts each round.
      _startingPlayer = _startingPlayer.opponent;
      _current = _startingPlayer;
    });
    if (_isAiTurn) _aiMove();
  }

  void _resetScores() {
    setState(() {
      _xWins = _oWins = _draws = 0;
      _startingPlayer = Player.o; // _newRound flips this back to X.
    });
    _newRound();
  }

  String get _xName => widget.vsComputer ? 'You' : 'Player X';
  String get _oName => widget.vsComputer ? 'Computer' : 'Player O';
  String _nameOf(Player p) => p == Player.x ? _xName : _oName;

  String get _status {
    final result = _result;
    if (result != null) {
      if (result.isDraw) return "It's a draw!";
      if (widget.vsComputer) {
        return result.winner == _human ? 'You win! 🎉' : 'Computer wins!';
      }
      return '${_nameOf(result.winner!)} wins! 🎉';
    }
    if (_aiThinking) return 'Computer is thinking…';
    if (widget.vsComputer) return 'Your turn';
    return "${_nameOf(_current)}'s turn";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vsComputer
            ? 'vs Computer (${widget.difficulty.name})'
            : 'Two Players'),
        actions: [
          IconButton(
            tooltip: 'Reset scores',
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetScores,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  _ScoreCard(
                    label: _xName,
                    symbol: 'X',
                    score: _xWins,
                    color: colors.primary,
                    active: _result == null && _current == Player.x,
                  ),
                  const SizedBox(width: 12),
                  _ScoreCard(
                    label: 'Draws',
                    symbol: '–',
                    score: _draws,
                    color: colors.outline,
                    active: false,
                  ),
                  const SizedBox(width: 12),
                  _ScoreCard(
                    label: _oName,
                    symbol: 'O',
                    score: _oWins,
                    color: colors.tertiary,
                    active: _result == null && _current == Player.o,
                  ),
                ],
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _status,
                  key: ValueKey(_status),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
              AspectRatio(aspectRatio: 1, child: _buildBoard(colors)),
              const Spacer(),
              AnimatedOpacity(
                opacity: _result != null ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: FilledButton.icon(
                  onPressed: _result != null ? _newRound : null,
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(ColorScheme colors) {
    final winningLine = _result?.winningLine ?? const <int>[];
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, i) {
        final cell = _board[i];
        final isWinning = winningLine.contains(i);
        final cellColor = cell == Player.x ? colors.primary : colors.tertiary;
        return Material(
          color: isWinning
              ? cellColor.withValues(alpha: 0.2)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _tap(i),
            child: Center(
              child: AnimatedScale(
                scale: cell == null ? 0 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Text(
                  cell?.symbol ?? '',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: cellColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final String symbol;
  final int score;
  final Color color;
  final bool active;

  const _ScoreCard({
    required this.label,
    required this.symbol,
    required this.score,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceContainer,
          border: Border.all(
            color: active ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(symbol,
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: color, fontWeight: FontWeight.w900)),
            Text(label,
                style: theme.textTheme.labelMedium,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('$score',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
