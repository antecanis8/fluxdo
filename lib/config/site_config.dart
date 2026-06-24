import 'site_customization.dart';

class SiteFeatures {
  final bool enableCdk;
  final bool enableLdc;
  final bool enableConnectStats;
  final bool enableReward;
  final bool useWebViewLoginOnly;

  const SiteFeatures({
    this.enableCdk = true,
    this.enableLdc = true,
    this.enableConnectStats = true,
    this.enableReward = true,
    this.useWebViewLoginOnly = false,
  });
}

class SiteConfig {
  final String baseUrl;
  final String primaryHost;
  final List<String> allowedHosts;
  final SiteCustomization siteCustomization;
  final SiteFeatures features;

  const SiteConfig({
    required this.baseUrl,
    required this.primaryHost,
    required this.allowedHosts,
    required this.siteCustomization,
    this.features = const SiteFeatures(),
  });

  bool matchesHost(String host, {bool includeSubdomains = true}) {
    final normalizedHost = host.toLowerCase();
    if (normalizedHost.isEmpty) return false;

    for (final pattern in allowedHosts) {
      final normalizedPattern = pattern.toLowerCase();
      if (normalizedPattern.startsWith('*.')) {
        if (!includeSubdomains) continue;
        final suffix = normalizedPattern.substring(1);
        if (normalizedHost.endsWith(suffix) &&
            normalizedHost.length > suffix.length - 1) {
          return true;
        }
        continue;
      }

      if (normalizedHost == normalizedPattern) {
        return true;
      }
    }
    return false;
  }
}
