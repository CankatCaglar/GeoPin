import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_localizations.dart';
import 'premium_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  Package? _package;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        if (mounted) {
          setState(() {
            _package = offerings.current!.availablePackages.first;
            _isLoading = false;
          });
        }
      } else {
        // Handle no offerings
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _purchasePackage() async {
    if (_package == null) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      final customerInfo = await Purchases.purchasePackage(_package!);
      final isPremium = customerInfo.entitlements.all['premium_GeoPin']?.isActive ?? false;

      if (isPremium) {
        ref.read(premiumProvider.notifier).refresh();
        if (mounted) {
          Navigator.of(context).pop(); // Close paywall
          _showSuccessDialog();
        }
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations().get('purchase_failed')}: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations().get('error')}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremium = customerInfo.entitlements.all['premium_GeoPin']?.isActive ?? false;

      if (isPremium) {
        ref.read(premiumProvider.notifier).refresh();
        if (mounted) {
          Navigator.of(context).pop();
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active subscriptions found to restore.')),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    final loc = AppLocalizations();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.amber),
            const SizedBox(width: 8),
            Text(loc.currentLanguage == 'tr' ? 'Başarı' : 'Success'),
          ],
        ),
        content: Text(loc.currentLanguage == 'tr' ? 'Premium satın alma başarılı! Artık tüm premium özelliklere erişiminiz var.' : 'Premium purchase successful! You now have access to all premium features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.currentLanguage == 'tr' ? 'TAMAM' : 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations();
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_package == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(loc.currentLanguage == 'tr' ? 'Ürün bulunamadı' : 'No products available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Icon/Image
                        const Icon(
                          Icons.workspace_premium,
                          size: 80,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          loc.currentLanguage == 'tr' ? 'Premium\'u Bugün Aç' : 'Unlock Premium Today',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        Text(
                          loc.currentLanguage == 'tr' ? 'Tüm premium özelliklere ve konumlara erişim sağlayın' : 'Get access to all premium features and locations',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        // Highlight Offer
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Text(
                            loc.currentLanguage == 'tr' ? 'Bugün katılın ve her şeyi açın' : 'Join today and unlock everything',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Feature List (Card)
                        Container(
                          height: 250,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'İkonik Köprüler' : 'Iconic Bridges'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'En Yüksek Gökdelenler' : 'Tallest Skyscrapers'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Dünya Mutfağı' : 'World Cuisine'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Stadyumlar' : 'Stadiums'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Havaalanları' : 'Airports'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Uzay Üsleri' : 'Space Bases'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Teknoloji Merkezleri' : 'Tech Hubs'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Bilimsel Harikalar' : 'Scientific Wonders'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Endemik Hayvanlar' : 'Endemic Animals'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Ekstrem Noktalar' : 'Extreme Points'),
                                const SizedBox(height: 16),
                                _buildFeatureRow(loc.currentLanguage == 'tr' ? 'Volkanlar' : 'Volcanoes'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Purchase Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isPurchasing ? null : _purchasePackage,
                            child: _isPurchasing
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary, strokeWidth: 2),
                                  )
                                : Text(
                                    loc.currentLanguage == 'tr' ? 'Premium\'a Yükselt' : 'Upgrade to Premium',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Price
                        if (_package != null)
                          Text(
                            _package!.storeProduct.priceString,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Footer Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFooterLink(loc.currentLanguage == 'tr' ? 'Satın Alımları Geri Yükle' : 'Restore Purchases', () => _restorePurchases()),
                            _buildFooterDivider(),
                            _buildFooterLink(loc.currentLanguage == 'tr' ? 'Kullanım Koşulları' : 'Terms of Use', () => _launchUrl('https://cankatcaglar.github.io/geopin-pages/terms-of-use.html')),
                            _buildFooterDivider(),
                            _buildFooterLink(loc.currentLanguage == 'tr' ? 'Gizlilik Politikası' : 'Privacy Policy', () => _launchUrl('https://cankatcaglar.github.io/geopin-pages/privacy-policy.html')),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isPurchasing)
              Container(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Colors.amber, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 1,
      height: 12,
      color: Colors.grey.shade400,
    );
  }
}
