import 'dart:async';

import 'package:immortal_path/game/models/monetization.dart';

abstract class MonetizationGateway {
  bool get isConfigured;

  Future<bool> showRewardedAd(String placementId);

  Future<bool> purchase(String productId);
}

class StubMonetizationGateway implements MonetizationGateway {
  final Set<String> _simulatedPurchases = {};

  @override
  bool get isConfigured => false;

  @override
  Future<bool> showRewardedAd(String placementId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return MonetizationCatalog.placementById(placementId) != null;
  }

  @override
  Future<bool> purchase(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (MonetizationCatalog.productById(productId) == null) return false;
    _simulatedPurchases.add(productId);
    return true;
  }

  bool wasSimulated(String productId) =>
      _simulatedPurchases.contains(productId);
}
