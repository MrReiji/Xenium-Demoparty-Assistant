import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app settings using `SharedPreferences`.
/// Handles settings related to reminders and cache functionality.
class SettingsManager {
  // Keys for storing settings in SharedPreferences.
  static const String _reminderValueKey = 'reminderValue';
  static const String _reminderUnitKey = 'reminderUnit';
  static const String _cacheEnabledKey = 'cacheEnabled';

  // Default values for reminders.
  static const int _defaultReminderValue = 32; // Default value in minutes.
  static const String _defaultReminderUnit = 'minutes';

  /// Enables or disables caching functionality.
  ///
  /// - [isEnabled]: A boolean indicating whether caching should be enabled.
  Future<void> setCacheEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cacheEnabledKey, isEnabled);
    debugPrint("[SettingsManager] Cache enabled set to $isEnabled.");
  }

  /// Checks whether caching is enabled.
  ///
  /// Returns `true` if caching is enabled, `false` otherwise. Defaults to `true`.
  Future<bool> isCacheEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_cacheEnabledKey) ?? true;
    debugPrint("[SettingsManager] Cache enabled: $isEnabled.");
    return isEnabled;
  }

  /// Saves reminder settings (value and unit) to `SharedPreferences`.
  ///
  /// - [value]: The numeric value of the reminder (e.g., "15").
  /// - [unit]: The unit of the reminder (e.g., "minutes", "hours").
  Future<void> setReminderSettings(int value, String unit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_reminderValueKey, value);
      await prefs.setString(_reminderUnitKey, unit);
      debugPrint("[SettingsManager] Reminder settings saved successfully.");
    } catch (e) {
      debugPrint("[SettingsManager] Error saving reminder settings: $e");
      rethrow;
    }
  }

  /// Retrieves reminder settings from `SharedPreferences`.
  ///
  /// Returns a map containing the `value` and `unit` of the reminder.
  /// Defaults to `_defaultReminderValue` and `_defaultReminderUnit` if not set.
  Future<Map<String, dynamic>> getReminderSettings() async {
    debugPrint("[SettingsManager] Fetching reminder settings.");
    try {
      final prefs = await SharedPreferences.getInstance();
      final int reminderValue = prefs.getInt(_reminderValueKey) ?? _defaultReminderValue;
      final String reminderUnit = prefs.getString(_reminderUnitKey) ?? _defaultReminderUnit;

      debugPrint("[SettingsManager] Fetched reminder settings: value = $reminderValue, unit = $reminderUnit.");
      return {'value': reminderValue, 'unit': reminderUnit};
    } catch (e) {
      debugPrint("[SettingsManager] Error fetching reminder settings: $e");
      rethrow;
    }
  }

  /// Calculates the reminder time in minutes based on the saved settings.
  ///
  /// Returns the reminder time in minutes.
  /// Converts units (e.g., hours to minutes, days to minutes) as needed.
  Future<int> getReminderTimeInMinutes() async {
    debugPrint("[SettingsManager] Calculating reminder time in minutes.");
    try {
      final settings = await getReminderSettings();
      final int value = settings['value'];
      final String unit = settings['unit'];

      int result;
      switch (unit) {
        case 'minutes':
          result = value;
          break;
        case 'hours':
          result = value * 60;
          break;
        case 'days':
          result = value * 1440;
          break;
        case 'weeks':
          result = value * 10080;
          break;
        default:
          debugPrint("[SettingsManager] Invalid unit: $unit. Using default value.");
          result = _defaultReminderValue;
      }

      debugPrint("[SettingsManager] Calculated reminder time: $result minutes.");
      return result;
    } catch (e) {
      debugPrint("[SettingsManager] Error calculating reminder time: $e");
      rethrow;
    }
  }
}
