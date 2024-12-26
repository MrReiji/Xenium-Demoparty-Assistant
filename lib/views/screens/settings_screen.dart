import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:demoparty_assistant/data/manager/settings/notification_settings_form_bloc.dart';
import 'package:demoparty_assistant/data/manager/settings/cache_settings_form_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:demoparty_assistant/data/services/notification_service.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';

/// The Settings screen allows users to configure:
/// - **Notification settings**: Reminder time and units.
/// - **Cache settings**: Cache Time-to-Live (TTL), cache enabling, and clearing.
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Initialize NotificationSettingsFormBloc for managing notification preferences.
        BlocProvider(
          create: (context) => NotificationSettingsFormBloc(
            GetIt.I<SettingsManager>(), 
            GetIt.I<NotificationService>(),
          ),
        ),
        // Initialize CacheSettingsFormBloc for managing cache behavior.
        BlocProvider(
          create: (context) => CacheSettingsFormBloc(
            GetIt.I<CacheService>(), 
            GetIt.I<SettingsManager>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Access initialized Blocs.
          final settingsBloc = context.read<NotificationSettingsFormBloc>();
          final cacheBloc = context.read<CacheSettingsFormBloc>();

          return Scaffold(
            appBar: AppBar(title: Text('Settings')), // AppBar with title.
            drawer: AppDrawer(currentPage: 'Settings'), // Drawer navigation.
            body: Padding(
              padding: const EdgeInsets.all(16.0), 
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNotificationSettings(context, settingsBloc), // Notification settings UI
                    Divider(),
                    _buildCacheSettings(context, cacheBloc), // Cache settings UI
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the UI for notification settings configuration.
  ///
  /// Allows users to:
  /// - Set reminder values.
  /// - Choose time units (e.g., minutes, hours).
  Widget _buildNotificationSettings(
      BuildContext context, NotificationSettingsFormBloc bloc) {
    return FormBlocListener<NotificationSettingsFormBloc, String, String>(
      onSubmitting: (context, state) => _showLoadingDialog(context),
      onSuccess: (context, state) {
        Navigator.of(context).pop(); // Dismiss loader.
        _showSnackbar(context, 'Notifications updated successfully.');
      },
      onFailure: (context, state) {
        Navigator.of(context).pop();
        _showSnackbar(context, state.failureResponse ?? 'Failed to update notifications.');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Reminder Time', 
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          // Input field for the reminder value.
          TextFieldBlocBuilder(
            textFieldBloc: bloc.reminderValue,
            decoration: InputDecoration(labelText: 'Reminder Value'),
          ),
          // Dropdown for selecting time units (e.g., minutes, hours).
          DropdownFieldBlocBuilder<String>(
            selectFieldBloc: bloc.timeUnit,
            decoration: InputDecoration(labelText: 'Time Unit'),
            itemBuilder: (context, value) => FieldItem(child: Text(value)),
          ),
          // Save button for submitting notification settings.
          ElevatedButton(
            onPressed: bloc.submit, 
            child: Text('Save Notification Settings'),
          ),
        ],
      ),
    );
  }

  /// Builds the UI for cache settings configuration.
  ///
  /// Allows users to:
  /// - Set cache TTL (time-to-live).
  /// - Enable/disable cache usage.
  /// - Clear cached data.
  Widget _buildCacheSettings(BuildContext context, CacheSettingsFormBloc bloc) {
    return FormBlocListener<CacheSettingsFormBloc, String, String>(
      onSubmitting: (context, state) => _showLoadingDialog(context),
      onSuccess: (context, state) {
        Navigator.of(context).pop();
        _showSnackbar(context, state.successResponse!);
      },
      onFailure: (context, state) {
        Navigator.of(context).pop();
        _showSnackbar(context, state.failureResponse ?? 'Failed to update cache settings.');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cache Settings', 
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          // Input field for cache TTL (in hours).
          TextFieldBlocBuilder(
            textFieldBloc: bloc.cacheTTL,
            decoration: InputDecoration(labelText: 'Cache TTL (hours)'),
          ),
          // Switch for enabling/disabling cache.
          SwitchFieldBlocBuilder(
            booleanFieldBloc: bloc.useCache,
            body: Text('Enable Cache'),
          ),
          // Button to update cache settings.
          ElevatedButton(
            onPressed: bloc.submit, 
            child: Text('Update Cache Settings'),
          ),
          // Button to clear cached data.
          ElevatedButton(
            onPressed: () async {
              _showLoadingDialog(context);
              await bloc.clearCache();
              Navigator.of(context).pop();
              _showSnackbar(context, 'Cache cleared successfully.');
            },
            child: Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  /// Displays a loading dialog while an operation is in progress.
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
  }

  /// Displays a snackbar with a given message.
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
