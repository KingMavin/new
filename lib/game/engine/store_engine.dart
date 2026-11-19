import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/sect_store.dart';

class StoreEngine {
  static GameState equipIfBetter(GameState state, Equipment item) {
    switch (item.slot) {
      case EquipmentSlot.weapon:
        final current = state.weapon;
        if (current != null && current.power >= item.power) return state;
        return state.copyWith(weapon: item);
      case EquipmentSlot.armor:
        final current = state.armor;
        if (current != null && current.power >= item.power) return state;
        return state.copyWith(armor: item);
      case EquipmentSlot.amulet:
        final current = state.amulet;
        if (current != null && current.power >= item.power) return state;
        return state.copyWith(amulet: item);
    }
  }
}

class SectStoreEngine {
  static String? buyBlocker(GameState state, SectStoreItem item) {
    if (state.sectId == null) return 'Leave wandering; join a sect first.';
    if (SectEngine.rankOf(state.contribution) < item.minRank) {
      return 'Your rank is too low \u2014 earn contribution.';
    }
    final cost = item.stoneCostFor(state.realmIndex);
    if (state.spiritStones < cost) {
      return 'You need ${cost - state.spiritStones} more spirit stones.';
    }
    return null;
  }

  static GameState buy(GameState state, SectStoreItem item) {
    if (buyBlocker(state, item) != null) return state;
    final equipped = StoreEngine.equipIfBetter(
      state,
      Equipment(
        name: item.name,
        slot: item.slot,
        grade: item.grade,
        power: item.powerFor(state.realmIndex),
      ),
    );
    return equipped.copyWith(
      spiritStones: equipped.spiritStones - item.stoneCostFor(state.realmIndex),
    );
  }
}
