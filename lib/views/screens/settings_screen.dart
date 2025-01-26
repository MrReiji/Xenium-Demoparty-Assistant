import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:demoparty_assistant/data/manager/settings/notification_settings_form_bloc.dart';
import 'package:demoparty_assistant/data/manager/settings/cache_settings_form_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:demoparty_assistant/data/manager/settings/settings_manager.dart';
import 'package:demoparty_assistant/data/services/notification_service.dart';
import 'package:demoparty_assistant/data/services/cache_service.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NotificationSettingsFormBloc(
            GetIt.I<SettingsManager>(),
            GetIt.I<NotificationService>(),
          ),
        ),
        BlocProvider(
          create: (context) => CacheSettingsFormBloc(
            GetIt.I<CacheService>(),
            GetIt.I<SettingsManager>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final settingsBloc = context.read<NotificationSettingsFormBloc>();
          final cacheBloc = context.read<CacheSettingsFormBloc>();

          return Scaffold(
            appBar: AppBar(
              title: Text('Settings'),
            ),
            drawer: AppDrawer(currentPage: 'Settings'),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNotificationSettings(context, settingsBloc),
                    Divider(),
                    _buildCacheSettings(context, cacheBloc),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationSettings(
      BuildContext context, NotificationSettingsFormBloc bloc) {
    return FormBlocListener<NotificationSettingsFormBloc, String, String>(
      onSubmitting: (context, state) => _showLoadingDialog(context),
      onSuccess: (context, state) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showSnackbar(context, 'Notifications updated successfully.');
      },
      onFailure: (context, state) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showSnackbar(context, state.failureResponse ?? 'Failed to update notifications.');
      },
      child: Column(
        children: [
          Text('Notification Reminder Time'),
          TextFieldBlocBuilder(
            textFieldBloc: bloc.reminderValue,
            decoration: InputDecoration(labelText: 'Reminder Value'),
          ),
          DropdownFieldBlocBuilder<String>(
            selectFieldBloc: bloc.timeUnit,
            decoration: InputDecoration(labelText: 'Time Unit'),
            itemBuilder: (context, value) => FieldItem(child: Text(value)),
          ),
          ElevatedButton(
            onPressed: bloc.submit,
            child: Text('Save Notifications Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheSettings(BuildContext context, CacheSettingsFormBloc bloc) {
    return FormBlocListener<CacheSettingsFormBloc, String, String>(
      onSubmitting: (context, state) => _showLoadingDialog(context),
      onSuccess: (context, state) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showSnackbar(context, state.successResponse!);
      },
      onFailure: (context, state) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        _showSnackbar(context, state.failureResponse ?? 'Failed to update cache settings.');
      },
      child: Column(
        children: [
          Text('Cache Settings'),
          TextFieldBlocBuilder(
            textFieldBloc: bloc.cacheTTL,
            decoration: InputDecoration(labelText: 'Cache TTL (seconds)'),
          ),
          SwitchFieldBlocBuilder(
            booleanFieldBloc: bloc.useCache,
            body: Text('Enable Cache'),
          ),
          ElevatedButton(
            onPressed: bloc.submit,
            child: Text('Update Cache Settings'),
          ),
          ElevatedButton(
            onPressed: () async {
              _showLoadingDialog(context);
              await bloc.clearCache();
              Navigator.of(context).pop(); // Dismiss loading dialog
              _showSnackbar(context, 'Cache cleared successfully.');
            },
            child: Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
