import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';

/// A form bloc that manages the logic for cache-related settings, 
/// including TTL (time-to-live) and enabling/disabling the cache.
class CacheSettingsFormBloc extends FormBloc<String, String> {
  /// Field for setting cache TTL (time-to-live) in seconds.
  final TextFieldBloc cacheTTL = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      _numberValidator,
    ],
  );

  /// Field for enabling or disabling the cache functionality.
  final BooleanFieldBloc useCache = BooleanFieldBloc();

  // Dependencies for managing cache and settings.
  final CacheService _cacheService;
  final SettingsManager _settingsManager;

  /// Constructor for dependency injection and initialization.
  ///
  /// - [CacheService]: Handles cache operations.
  /// - [SettingsManager]: Manages settings, including cache enable/disable state.
  CacheSettingsFormBloc(this._cacheService, this._settingsManager) {
    debugPrint("[CacheSettingsFormBloc] Initializing CacheSettingsFormBloc.");
    addFieldBlocs(fieldBlocs: [cacheTTL, useCache]);
    _loadInitialValues();
  }

  /// Loads initial values for cache TTL and the cache enable setting.
  Future<void> _loadInitialValues() async {
    debugPrint("[CacheSettingsFormBloc] Loading initial values for cache settings.");
    try {
      // Fetch current TTL and cache enable status.
      final currentTTL = await _cacheService.getCurrentTTL();
      final isCacheEnabled = await _settingsManager.isCacheEnabled();

      // Update form fields with the fetched values.
      cacheTTL.updateInitialValue(currentTTL.toString());
      useCache.updateInitialValue(isCacheEnabled);

      debugPrint("[CacheSettingsFormBloc] Initial values loaded: TTL=$currentTTL, CacheEnabled=$isCacheEnabled.");
    } catch (e) {
      debugPrint("[CacheSettingsFormBloc] Error loading initial values: $e");
    }
  }

  /// Updates the cache settings, including TTL and enable/disable state.
  @override
  Future<void> onSubmitting() async {
    emitSubmitting();
    try {
      // Parse and validate TTL.
      final ttl = int.parse(cacheTTL.value);
      final cacheEnabled = useCache.value;

      debugPrint("[CacheSettingsFormBloc] Updating cache settings: TTL=$ttl, CacheEnabled=$cacheEnabled.");

      // Update cache service and settings manager.
      await _cacheService.setGlobalTTL(ttl);
      await _settingsManager.setCacheEnabled(cacheEnabled);

      emitSuccess(successResponse: 'Cache settings updated successfully.');
    } catch (e) {
      debugPrint("[CacheSettingsFormBloc] Error updating cache settings: $e");
      emitFailure(failureResponse: 'Failed to update cache settings.');
    }
  }

  /// Clears all cached data using the cache service.
  Future<void> clearCache() async {
    emitSubmitting();
    try {
      debugPrint("[CacheSettingsFormBloc] Clearing all cache.");
      await _cacheService.clearAllCache();

      emitSuccess(successResponse: 'Cache cleared successfully.');
    } catch (e) {
      debugPrint("[CacheSettingsFormBloc] Error clearing cache: $e");
      emitFailure(failureResponse: 'Failed to clear cache.');
    }
  }

  /// Validator for the cache TTL field.
  ///
  /// Ensures that the input is a positive integer.
  static String? _numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }

    // Use a regular expression to validate positive integers.
    final isInteger = RegExp(r'^[1-9]\d*$').hasMatch(value);
    if (!isInteger) {
      return 'Enter a valid positive integer.';
    }

    return null;
  }
}
