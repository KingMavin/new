import 'dart:io';

import 'package:immortal_path/game/engine/balance_simulator.dart';

String fmt(double value) {
  if (value >= 3600) {
    return '${(value / 3600).toStringAsFixed(1)}h';
  }
  if (value >= 60) {
    return '${(value / 60).toStringAsFixed(1)}m';
  }
  return '${value.toStringAsFixed(0)}s';
}

void main() {
  final report = BalanceSimulator.report();

  void printStack(String title, StatStack stack) {
    print('$title \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500');
    for (final layer in stack.layers) {
      print('  ${layer.name.padRight(24)} x${layer.value.toStringAsFixed(2)}');
    }
    if (stack.flatBonus > 0) {
      print('  ${'weapon (flat)'.padRight(24)} +${fmt(stack.flatBonus)}');
    }
    print('  TOTAL ${stack.stat.padRight(24)} ${fmt(stack.total)}');
    print('');
  }

  print('=== IMMORTAL PATH BALANCE REPORT ===');
  print('');
  printStack('FRESH CULTIVATOR (realm 0, stage 0, unbuffed)', report.freshQi);
  printStack('  attack', report.freshAttack);
  printStack('FULLY STACKED IDLE (realm 8 peak, all systems maxed)', report.maxedQi);
  printStack('  attack', report.maxedAttack);

  print('CULTIVATION CURVE (fresh profile) \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500');
  var cumulative = 0.0;
  for (final step in report.freshCurve) {
    cumulative += step.idleSeconds;
    print(
      '  realm ${step.realm} stage ${step.stage} \u2014 '
      'req ${step.requirement.toStringAsFixed(0)} qi, '
      '${step.qiPerSecond.toStringAsFixed(1)} qi/s, '
      '${fmt(step.idleSeconds)} (total ${fmt(cumulative)})',
    );
  }
  print('  TOTAL idle to ascension: ${fmt(report.totalFreshIdleSeconds)}');
  print('');
  print('CULTIVATION CURVE (fully stacked) \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500');
  print('  TOTAL idle to ascension: ${fmt(report.totalMaxedIdleSeconds)}');
  print('');

  void printZones(String title, List<ZoneCheck> checks) {
    print('$title \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500');
    for (final check in checks) {
      print(
        '  r${check.realm} ${check.elite ? '[elite]' : '       '} '
        '${check.beast.padRight(26)} kill ${check.killRounds.toStringAsFixed(1)} '
        'vs die ${check.deathRounds.toStringAsFixed(1)} \u2014 ${check.verdict}',
      );
    }
    print('');
  }

  printZones('ZONES: fresh-realm entrant (stage 0, unbuffed)', report.freshZones);
  printZones(
    'ZONES: peak stage of realm (unbuffed)',
    report.peakZones,
  );
  printZones(
    'ZONES: fully stacked fighter (peak of realm)',
    report.maxedZones,
  );

  print('SANITY \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500');
  print('  unwinnable zones (fresh entrant): ${report.unwinnableFreshZones.length}');
  print('  unwinnable zones (peak unbuffed): ${report.unwinnablePeakZones.length}');
}
