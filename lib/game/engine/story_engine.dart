import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/story.dart';

class StoryOutcome {
  final GameState state;
  final StoryChapter chapter;
  final StoryChoice choice;

  const StoryOutcome({
    required this.state,
    required this.chapter,
    required this.choice,
  });
}

class StoryEngine {
  static const List<int> realmGates = [0, 1, 3, 5, 7];

  static List<StoryChapter> arcOf(GameState state) =>
      state.raceId == null ? const [] : StoryCatalog.arcFor(state.raceId!);

  static StoryChapter? currentChapter(GameState state) {
    if (state.ascended || state.raceId == null) return null;
    if (state.storyChapter >= realmGates.length) return null;
    final arc = arcOf(state);
    if (state.storyChapter >= arc.length) return null;
    final chapter = arc[state.storyChapter];
    if (state.realmIndex < chapter.requiredRealm) return null;
    return chapter;
  }

  static StoryOutcome? advance(GameState state, int choiceIndex) {
    final chapter = currentChapter(state);
    if (chapter == null) return null;
    if (choiceIndex < 0 || choiceIndex >= chapter.choices.length) return null;
    final choice = chapter.choices[choiceIndex];
    final points = {...state.pathPoints};
    points[choice.pathId] = (points[choice.pathId] ?? 0) + choice.pathWeight;
    final updated = state.copyWith(
      pathPoints: points,
      storyChapter: state.storyChapter + 1,
      storyFlags: choice.flag == null || state.storyFlags.contains(choice.flag)
          ? state.storyFlags
          : [...state.storyFlags, choice.flag!],
    );
    return StoryOutcome(
      state: updated,
      chapter: chapter,
      choice: choice,
    );
  }

  static String dominantPath(GameState state) {
    String? best;
    var bestValue = 0;
    for (final entry in state.pathPoints.entries) {
      if (entry.value > bestValue) {
        bestValue = entry.value;
        best = entry.key;
      }
    }
    return best ?? 'heaven';
  }

  static double breakthroughBonus(GameState state) =>
      dominantPath(state) == 'heaven' &&
              state.pathPoints['heaven'] != null &&
              state.pathPoints['heaven']! > 0
          ? 0.03
          : 0.0;

  static double attackBonus(GameState state) =>
      dominantPath(state) == 'sovereignty' &&
              (state.pathPoints['sovereignty'] ?? 0) > 0
          ? 0.05
          : 0.0;

  static double stoneBonus(GameState state) =>
      dominantPath(state) == 'wild' && (state.pathPoints['wild'] ?? 0) > 0
          ? 0.05
          : 0.0;
}
