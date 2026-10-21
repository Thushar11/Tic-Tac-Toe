import 'dart:math';

enum Player { x, o }

extension PlayerX on Player {
  Player get opponent => this == Player.x ? Player.o : Player.x;
  String get symbol => this == Player.x ? 'X' : 'O';
}

enum Difficulty { easy, medium, hard }

class GameResult {
  final Player? winner;
  final List<int> winningLine;

  const GameResult.win(this.winner, this.winningLine);
  const GameResult.draw()
      : winner = null,
        winningLine = const [];

  bool get isDraw => winner == null;
}

class GameLogic {
  static const List<List<int>> lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  /// Returns the result if the game is over, otherwise null.
  static GameResult? evaluate(List<Player?> board) {
    for (final line in lines) {
      final a = board[line[0]];
      if (a != null && a == board[line[1]] && a == board[line[2]]) {
        return GameResult.win(a, line);
      }
    }
    if (board.every((cell) => cell != null)) return const GameResult.draw();
    return null;
  }

  static List<int> emptyCells(List<Player?> board) => [
        for (var i = 0; i < board.length; i++)
          if (board[i] == null) i,
      ];
}

class TicTacToeAI {
  final Random _random;

  TicTacToeAI({Random? random}) : _random = random ?? Random();

  /// Picks a move for [me]. Easy is random, medium mixes random and
  /// optimal play, hard is perfect play via minimax.
  int bestMove(List<Player?> board, Player me, Difficulty difficulty) {
    final empty = GameLogic.emptyCells(board);
    assert(empty.isNotEmpty, 'No moves available');

    switch (difficulty) {
      case Difficulty.easy:
        return empty[_random.nextInt(empty.length)];
      case Difficulty.medium:
        if (_random.nextDouble() < 0.5) {
          return empty[_random.nextInt(empty.length)];
        }
        return _minimaxMove(board, me);
      case Difficulty.hard:
        return _minimaxMove(board, me);
    }
  }

  int _minimaxMove(List<Player?> board, Player me) {
    final scratch = List<Player?>.from(board);
    var bestScore = -1000;
    final bestMoves = <int>[];

    for (final move in GameLogic.emptyCells(scratch)) {
      scratch[move] = me;
      final score = _minimax(scratch, me, me.opponent, 0);
      scratch[move] = null;
      if (score > bestScore) {
        bestScore = score;
        bestMoves
          ..clear()
          ..add(move);
      } else if (score == bestScore) {
        bestMoves.add(move);
      }
    }
    // Randomise among equally good moves so games feel less repetitive.
    return bestMoves[_random.nextInt(bestMoves.length)];
  }

  int _minimax(List<Player?> board, Player me, Player turn, int depth) {
    final result = GameLogic.evaluate(board);
    if (result != null) {
      if (result.isDraw) return 0;
      // Prefer faster wins and slower losses.
      return result.winner == me ? 10 - depth : depth - 10;
    }

    final maximizing = turn == me;
    var best = maximizing ? -1000 : 1000;
    for (final move in GameLogic.emptyCells(board)) {
      board[move] = turn;
      final score = _minimax(board, me, turn.opponent, depth + 1);
      board[move] = null;
      best = maximizing ? max(best, score) : min(best, score);
    }
    return best;
  }
}
