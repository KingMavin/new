import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/store_engine.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/monetization.dart';
import 'package:immortal_path/game/models/sect_store.dart';

GameState stateAt({
  int realmIndex = 0,
  String? sectId,
  int contribution = 0,
  double spiritStones = 0,
}) {
  return GameState.initial().copyWith(
    realmIndex: realmIndex,
    sectId: sectId,
    contribution: contribution,
    spiritStones: spiritStones,
  );
}

void main() {
  group('offline caps', () {
    test('free players cap at 8 hours', () {
      expect(
        MonetizationCatalog.offlineCapFor(const []),
        const Duration(hours: 8),
      );
    });

    test('offline extenders rise to 12 and 24 hours', () {
      expect(
        MonetizationCatalog.offlineCapFor(const ['offline_12h']),
        const Duration(hours: 12),
      );
      expect(
        MonetizationCatalog.offlineCapFor(const ['offline_12h', 'offline_24h']),
        const Duration(hours: 24),
      );
    });

    test('the immortal pack includes the 24-hour cap', () {
      expect(
        MonetizationCatalog.offlineCapFor(const ['immortal_pack']),
        const Duration(hours: 24),
      );
    });
  });

  group('heirloom gear', () {
    test('store sells only known kinds', () {
      expect(StoreProduct.kinds,
          {'support', 'theme', 'offline', 'gear', 'bundle'});
      for (final product in MonetizationCatalog.products) {
        expect(
          StoreProduct.kinds.contains(product.kind),
          isTrue,
          reason: '${product.id} has unknown kind ${product.kind}',
        );
      }
    });

    test('heirloom power tracks the current realm', () {
      expect(MonetizationCatalog.heirloomPower(0), 55.0);
      expect(
        MonetizationCatalog.heirloomPower(3),
        closeTo(55.0 * pow(1.8, 3), 0.001),
      );
    });

    test('heirloom ids mint gear for their slots', () {
      final weapon = MonetizationCatalog.mintedGearFor('heirloom_weapon', 2)!;
      final armor = MonetizationCatalog.mintedGearFor('heirloom_armor', 0)!;
      final amulet = MonetizationCatalog.mintedGearFor('heirloom_amulet', 0)!;
      expect(weapon.slot, EquipmentSlot.weapon);
      expect(weapon.name, 'Ancestral Fang');
      expect(armor.slot, EquipmentSlot.armor);
      expect(amulet.slot, EquipmentSlot.amulet);
      expect(amulet.grade, 4);
      expect(
        weapon.power,
        closeTo(MonetizationCatalog.heirloomPower(2), 0.001),
      );
      expect(MonetizationCatalog.mintedGearFor('theme_ember', 0), isNull);
    });

    test('equipIfBetter equips only strictly better gear', () {
      final state = stateAt();
      final first = MonetizationCatalog.mintedGearFor('heirloom_amulet', 0)!;
      final withFirst = StoreEngine.equipIfBetter(state, first);
      expect(withFirst.amulet, first);
      final weaker = const Equipment(
        name: 'Bone Charm',
        slot: EquipmentSlot.amulet,
        grade: 0,
        power: 50.0,
      );
      expect(StoreEngine.equipIfBetter(withFirst, weaker).amulet, first);
      final stronger = MonetizationCatalog.mintedGearFor('heirloom_amulet', 1)!;
      expect(StoreEngine.equipIfBetter(withFirst, stronger).amulet, stronger);
    });

    test('heirloom gear is outgrown by later-realm drops', () {
      final heirloomAtRealm2 =
          MonetizationCatalog.mintedGearFor('heirloom_weapon', 2)!;
      final midGameDrop = Equipment.create(
        EquipmentSlot.weapon,
        4,
        50.0 * pow(1.8, 4) * 1.05,
      );
      expect(midGameDrop.power, greaterThan(heirloomAtRealm2.power));
    });
  });

  group('amulet combat contribution', () {
    test('amulet power lends half to attack and half to defense', () {
      final plain = stateAt();
      final sealed = stateAt().copyWith(
        amulet: MonetizationCatalog.mintedGearFor('heirloom_amulet', 2),
      );
      final amuletPower = sealed.amulet!.power;
      expect(
        CombatEngine.playerAttack(sealed) - CombatEngine.playerAttack(plain),
        closeTo(amuletPower * 0.5, 0.001),
      );
      expect(
        CombatEngine.playerDefense(sealed) - CombatEngine.playerDefense(plain),
        closeTo(amuletPower * 0.5, 0.001),
      );
      expect(
        CombatEngine.playerMaxHp(sealed),
        CombatEngine.playerMaxHp(plain),
      );
    });
  });

  group('SectStoreEngine', () {
    final blade = SectStoreCatalog.itemById('forged_blade')!;
    final earthBlade = SectStoreCatalog.itemById('earth_blade')!;

    test('wandering cultivators cannot buy', () {
      final state = stateAt(sectId: null);
      expect(SectStoreEngine.buyBlocker(state, blade), isNotNull);
      expect(SectStoreEngine.buy(state, blade), same(state));
    });

    test('rank gates hold', () {
      final inner = stateAt(
        sectId: 'sword_sect',
        contribution: 100,
        spiritStones: 100000,
      );
      expect(SectStoreEngine.buyBlocker(inner, blade), isNull);
      expect(SectStoreEngine.buyBlocker(inner, earthBlade), isNotNull);
      expect(
        SectStoreEngine.buyBlocker(
          stateAt(
            sectId: 'sword_sect',
            contribution: 300,
            spiritStones: 100000,
          ),
          earthBlade,
        ),
        isNull,
      );
      expect(
        SectStoreEngine.buy(
          stateAt(
            sectId: 'sword_sect',
            contribution: 300,
            spiritStones: 100000,
          ),
          earthBlade,
        ).weapon,
        isNotNull,
      );
    });

    test('buying deducts the realm-scaled cost and equips', () {
      final state = stateAt(
        sectId: 'sword_sect',
        contribution: 100,
        spiritStones: 5000,
      );
      final bought = SectStoreEngine.buy(state, blade);
      expect(bought.spiritStones, 5000 - blade.stoneCostFor(0));
      expect(bought.weapon, isNotNull);
      expect(bought.weapon!.name, blade.name);
      expect(bought.weapon!.power, closeTo(blade.powerFor(0), 0.001));
    });

    test('sect costs and power scale with the realm', () {
      final state = stateAt(
        realmIndex: 3,
        sectId: 'sword_sect',
        contribution: 100,
        spiritStones: 999999,
      );
      final bought = SectStoreEngine.buy(state, blade);
      expect(bought.spiritStones, 999999 - blade.stoneCostFor(3));
      expect(bought.weapon!.power, closeTo(20 * pow(1.8, 3), 0.001));
    });

    test('too few stones blocks the purchase', () {
      final state = stateAt(
        sectId: 'sword_sect',
        contribution: 100,
        spiritStones: 10,
      );
      expect(SectStoreEngine.buy(state, blade), same(state));
    });

    test('every catalog item resolves and stays rank-bounded', () {
      for (final item in SectStoreCatalog.items) {
        expect(SectStoreCatalog.itemById(item.id), same(item));
        expect(item.minRank, inInclusiveRange(1, 3));
        expect(item.stoneCostFor(0), greaterThan(0));
        expect(
          item.powerFor(0),
          closeTo(
            (item.grade + 1) * 10.0,
            0.001,
          ),
          reason: '${item.id} should match its grade band',
        );
      }
    });
  });
}
