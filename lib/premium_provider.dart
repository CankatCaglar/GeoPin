import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier();
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _checkPremiumStatus();
    _setupPurchaseListener();
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      state = customerInfo.entitlements.all['premium_GeoPin']?.isActive ?? false;
    } catch (e) {
      state = false;
    }
  }

  void _setupPurchaseListener() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      state = customerInfo.entitlements.all['premium_GeoPin']?.isActive ?? false;
    });
  }

  Future<void> refresh() async {
    await _checkPremiumStatus();
  }
}
