import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/story_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/story.dart';

void main() {
  group('StoryEngine', () {
    test('no race means no chapters', () {
      expect(StoryEngine.currentChapter(GameState.initial()), isNull);
      expect(StoryEngine.arcOf(GameState.initial()), isEmpty);
    });

    test('each race has five chapters with three path choices', () {
      for (final raceId in ['human', 'demon', 'demi_human']) {
        final arc = StoryCatalog.arcFor(raceId);
        expect(arc.length, 5, reason: raceId);
        for (final chapter in arc) {
          expect(chapter.choices.length, 3, reason: chapter.id);
          expect(
            chapter.choices.map((choice) => choice.pathId).toSet(),
            {'heaven', 'sovereignty', 'wild'},
            reason: chapter.id,
          );
        }
      }
    });

    test('chapters are gated by realm', () {
      final state = GameState.initial().copyWith(raceId: 'human');
      final chapter = StoryEngine.currentChapter(state)!;
      expect(chapter.id, 'human_1');
      expect(
        StoryEngine.currentChapter(state.copyWith(storyChapter: 1)),
        isNull,
      );
      expect(
        StoryEngine.currentChapter(
          state.copyWith(storyChapter: 1, realmIndex: 1),
        )!.id,
        'human_2',
      );
    });

    test('advance applies path points, flags, and chapter count', () {
      final state = GameState.initial().copyWith(raceId: 'human');
      final outcome = StoryEngine.advance(state, 1)!;
      expect(outcome.choice.pathId, 'sovereignty');
      expect(outcome.state.pathPoints['sovereignty'], 2);
      expect(outcome.state.storyChapter, 1);
      final second = StoryEngine.advance(outcome.state, 2)!;
      expect(second.state.pathPoints['wild'], 2);
      expect(second.state.storyChapter, 2);
    });

    test('chapter flags are set once', () {
      final state = GameState.initial().copyWith(raceId: 'human');
      var updated = StoryEngine.advance(state, 0)!.state;
      updated = StoryEngine.advance(updated, 0)!.state;
      final third = StoryEngine.currentChapter(
        updated.copyWith(realmIndex: 3),
      )!;
      expect(third.id, 'human_3');
      final outcome = StoryEngine.advance(
        updated.copyWith(realmIndex: 3),
        0,
      )!;
      expect(outcome.state.storyFlags, contains('served_in_war'));
    });

    test('dominant path falls back to heaven with no points', () {
      expect(StoryEngine.dominantPath(GameState.initial()), 'heaven');
      final state = GameState.initial().copyWith(
        pathPoints: const {'wild': 4, 'sovereignty': 2},
      );
      expect(StoryEngine.dominantPath(state), 'wild');
    });

    test('alignment bonuses follow the dominant path', () {
      final heaven = GameState.initial().copyWith(
        pathPoints: const {'heaven': 6, 'wild': 2},
      );
      expect(StoryEngine.breakthroughBonus(heaven), closeTo(0.03, 1e-9));
      expect(StoryEngine.attackBonus(heaven), 0.0);
      expect(StoryEngine.stoneBonus(heaven), 0.0);

      final sovereignty = GameState.initial().copyWith(
        pathPoints: const {'sovereignty': 6},
      );
      expect(StoryEngine.attackBonus(sovereignty), closeTo(0.05, 1e-9));

      final wild = GameState.initial().copyWith(
        pathPoints: const {'wild': 6},
      );
      expect(StoryEngine.stoneBonus(wild), closeTo(0.05, 1e-9));
    });

    test('story ends at ascension and after five chapters', () {
      final done = GameState.initial().copyWith(
        raceId: 'human',
        storyChapter: 5,
        realmIndex: 8,
      );
      expect(StoryEngine.currentChapter(done), isNull);
      final ascended = GameState.initial().copyWith(
        raceId: 'human',
        ascended: true,
      );
      expect(StoryEngine.currentChapter(ascended), isNull);
    });
  });
}
