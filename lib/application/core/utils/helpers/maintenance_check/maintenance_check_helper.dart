import 'package:flagsmith/flagsmith.dart';

/// Centralized check for the "closed for maintenance" feature flag via Flagsmith.
/// Used by splash and landing to redirect to the maintenance screen when enabled.
class MaintenanceCheckHelper {
  MaintenanceCheckHelper._();

  static const String _flagsmithApiKey = '456qH7w6HNJqhwhyWLFkby';
  static const String _maintenanceFlagName = 'is_closed_for_maintenance';

  static const FlagsmithConfig _config = FlagsmithConfig(
    baseURI: 'https://edge.api.flagsmith.com/api/v1/',
  );

  /// Returns true if the app is closed for maintenance, false otherwise.
  /// On network/API errors, returns false so the app continues normally.
  static Future<bool> isClosedForMaintenance() async {
    try {
      final client = await FlagsmithClient.init(
        apiKey: _flagsmithApiKey,
        config: _config,
      );
      await client.getFeatureFlags(reload: true);
      return await client.isFeatureFlagEnabled(_maintenanceFlagName);
    } catch (_) {
      return false;
    }
  }
}
