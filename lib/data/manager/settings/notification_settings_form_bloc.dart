import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:demoparty_assistant/data/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

/// A form bloc for managing notification settings, including reminder intervals and time units.
class NotificationSettingsFormBloc extends FormBloc<String, String> {
  /// TextFieldBloc for the reminder value (e.g., "15" for 15 minutes).
  final TextFieldBloc reminderValue = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      numberValidator, // Ensures the input is a positive integer.
    ],
  );

  /// SelectFieldBloc for selecting the time unit (e.g., minutes, hours, days).
  final SelectFieldBloc<String, dynamic> timeUnit = SelectFieldBloc<String, dynamic>(
    items: ['minutes', 'hours', 'days', 'weeks'], // Available time units.
    validators: [FieldBlocValidators.required], // Ensures a time unit is selected.
  );

  // Dependencies for managing settings and notifications.
  final SettingsManager _settingsManager;
  final NotificationService _notificationService;

  /// Constructor for dependency injection and form initialization.
  ///
  /// - [SettingsManager]: Manages app settings, including notification preferences.
  /// - [NotificationService]: Handles notification scheduling and cancellation.
  NotificationSettingsFormBloc(this._settingsManager, this._notificationService) {
    debugPrint("[NotificationSettingsFormBloc] Initializing NotificationSettingsFormBloc.");
    addFieldBlocs(fieldBlocs: [reminderValue, timeUnit]);
    _loadInitialValues(); // Load initial settings when the bloc is initialized.
  }

  /// Loads the initial values for notification settings into the form fields.
  Future<void> _loadInitialValues() async {
    debugPrint("[NotificationSettingsFormBloc] Loading initial values for notification settings.");
    try {
      // Fetch current reminder settings.
      final settings = await _settingsManager.getReminderSettings();
      reminderValue.updateInitialValue(settings['value'].toString());
      timeUnit.updateInitialValue(settings['unit']);
      debugPrint("[NotificationSettingsFormBloc] Initial values loaded successfully.");
    } catch (e) {
      debugPrint("[NotificationSettingsFormBloc] Error loading initial values: $e");
      emitFailure(failureResponse: "Failed to load initial values.");
    }
  }

  /// Handles the form submission to save and apply notification settings.
  @override
  Future<void> onSubmitting() async {
    debugPrint("[NotificationSettingsFormBloc] Submitting form data.");
    try {
      // After validation by the form field, convert the reminder value from String to int.
      final value = int.parse(reminderValue.value);
      
      final unit = timeUnit.value;

      // Save the new settings.
      debugPrint("[NotificationSettingsFormBloc] Saving settings: value = $value, unit = $unit.");
      await _settingsManager.setReminderSettings(value, unit!);

      // Update notifications based on the new settings.
      debugPrint("[NotificationSettingsFormBloc] Re-scheduling notifications with new settings.");
      await _notificationService.cancelAllNotifications(); // Cancel existing notifications.
      await _notificationService.rescheduleAllNotifications(); // Reschedule with updated settings.

      debugPrint("[NotificationSettingsFormBloc] Settings saved and notifications updated successfully.");
      emitSuccess(successResponse: 'Notification settings saved successfully!');
    } catch (e) {
      debugPrint("[NotificationSettingsFormBloc] Error saving settings or rescheduling notifications: $e");
      emitFailure(failureResponse: 'Failed to save notification settings.');
    }
  }
}

/// Validates the number input for the reminder value.
///
/// - Ensures the input is a positive integer.
/// - Returns an error message if validation fails, or `null` if the input is valid.
String? numberValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required.';
  }

  // Use a regular expression to allow only positive integers.
  final isInteger = RegExp(r'^[1-9]\d*$').hasMatch(value);
  if (!isInteger) {
    return 'Enter a valid positive integer.';
  }

  return null;
}
