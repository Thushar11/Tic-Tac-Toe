import 'package:flutter_test/flutter_test.dart';

import 'package:tictactoe/game/game_logic.dart';
import 'package:tictactoe/main.dart';

void main() {
  group('GameLogic.evaluate', () {
    test('detects a row win', () {
      final board = <Player?>[
        Player.x, Player.x, Player.x,
        Player.o, Player.o, null,
        null, null, null,
      ];
      final result = GameLogic.evaluate(board)!;
      expect(result.winner, Player.x);
      expect(result.winningLine, [0, 1, 2]);
    });

    test('detects a draw', () {
      final board = <Player?>[
        Player.x, Player.o, Player.x,
        Player.x, Player.o, Player.o,
        Player.o, Player.x, Player.x,
      ];
      expect(GameLogic.evaluate(board)!.isDraw, isTrue);
    });

    test('returns null for an ongoing game', () {
      expect(GameLogic.evaluate(List.filled(9, null)), isNull);
    });
  });

  group('TicTacToeAI (hard)', () {
    final ai = TicTacToeAI();

    test('takes a winning move', () {
      final board = <Player?>[
        Player.o, Player.o, null,
        Player.x, Player.x, null,
        null, null, null,
      ];
      expect(ai.bestMove(board, Player.o, Difficulty.hard), 2);
    });

    test('blocks the opponent', () {
      final board = <Player?>[
        Player.x, Player.x, null,
        null, Player.o, null,
        null, null, null,
      ];
      expect(ai.bestMove(board, Player.o, Difficulty.hard), 2);
    });

    test('never loses against a random opponent', () {
      final random = TicTacToeAI();
      for (var game = 0; game < 50; game++) {
        final board = List<Player?>.filled(9, null);
        var turn = game.isEven ? Player.x : Player.o;
        while (GameLogic.evaluate(board) == null) {
          board[turn == Player.o
              ? ai.bestMove(board, Player.o, Difficulty.hard)
              : random.bestMove(board, Player.x, Difficulty.easy)] = turn;
          turn = turn.opponent;
        }
        expect(GameLogic.evaluate(board)!.winner, isNot(Player.x));
      }
    });
  });

  testWidgets('home screen shows game modes', (tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    expect(find.text('Play vs Computer'), findsOneWidget);
    expect(find.text('Two Players'), findsOneWidget);
  });
}
