import 'package:demoparty_assistant/data/manager/authorization/authorization_form_bloc.dart';
import 'package:demoparty_assistant/views/Theme.dart';
import 'package:demoparty_assistant/utils/navigation/auth_path_guard.dart';
import 'package:demoparty_assistant/views/widgets/buttons/primary_button.dart';
import 'package:demoparty_assistant/views/widgets/drawer/drawer.dart';
import 'package:demoparty_assistant/views/widgets/fields/input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Authorization screen widget.
class Authorization extends StatefulWidget {
  @override
  _AuthorizationState createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {
  final AuthGuard _authGuard = AuthGuard();
  AuthorizationFormBloc? _formBloc;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _initializeLoginStatus();
  }

  /// Initializes login status using AuthGuard.
  Future<void> _initializeLoginStatus() async {
    final isValid = await _authGuard.isSessionValid();
    if (isValid) {
      final storage = GetIt.I<FlutterSecureStorage>();
      _userName = await storage.read(key: 'user_name') ?? "User";
    } else {
      _formBloc = AuthorizationFormBloc();
    }
    setState(() {
      _isLoggedIn = isValid;
      _isLoading = false;
    });
  }

  /// Logs out the user and clears session data using AuthGuard.
  Future<void> _logout() async {
    await _authGuard.clearSession();
    setState(() {
      _isLoggedIn = false;
      _formBloc = AuthorizationFormBloc(); // Create new form bloc for login.
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoggedIn ? "Welcome, $_userName" : "Authorization"),
        actions: [
          if (!_isLoggedIn)
            TextButton(
              onPressed: () {
                setState(() {
                  // Toggle between login and registration forms.
                  if (_formBloc!.isLogin) {
                    _formBloc!.switchToRegistration();
                  } else {
                    _formBloc!.switchToLogin();
                  }
                });
              },
              child: Text(
                _formBloc!.isLogin
                    ? "Switch to Registration"
                    : "Switch to Login",
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      drawer: AppDrawer(currentPage: "Authorization"),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: _isLoggedIn ? _buildLoggedInUI() : _buildAuthForm(),
        ),
      ),
    );
  }

  /// Builds the UI for logged-in users.
  Widget _buildLoggedInUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Hello, $_userName!",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: textColorLight,
              ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Text(
          "You are currently logged in.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: mutedTextColor,
              ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        PrimaryButton(
          text: "LOGOUT",
          press: _logout,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  /// Builds the authentication form.
  Widget _buildAuthForm() {
    return BlocProvider(
      create: (_) => _formBloc!,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return FormBlocListener<AuthorizationFormBloc, String, String>(
            onLoading: (context, state) {
              print("Form is loading");
              _showLoadingDialog(context, theme);
            },
            onSubmitting: (context, state) {
              print("Form is submitting");
              _showLoadingDialog(context, theme);
            },
            onSuccess: (context, state) async {
              print("Form submission successful");
              await _initializeLoginStatus();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successResponse ?? "Submission Successful"),
              ),
              );
            },
            onFailure: (context, state) {
              print("Form submission FAILURE");
              Navigator.of(context).pop(); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failureResponse ?? "Submission Failed"),
              ),
              );
            },
            onSubmissionFailed: (context, state) {
              Navigator.of(context).pop(); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Check your credentials and try again!"),
              ),
            );
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_formBloc!.isLogin) ...[
                    _buildLoginForm(theme),
                  ] else ...[
                    _buildRegistrationForm(theme),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the login form.
  Widget _buildLoginForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Container(
              width: double.infinity,
              child: Text(
                "Log in to access exclusive content!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: textColorLight, fontSize: 30,
                ),
              ),
            ),
          ),
        ),
        Text(
          "Login",
          style: theme.textTheme.headlineLarge?.copyWith(color: textColorLight),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        InputWidget(
          hintText: "Username",
          prefixIcon: Icons.person,
          fieldBloc: _formBloc!.login,
        ),
        InputWidget(
          hintText: "Password",
          prefixIcon: Icons.lock,
          obscureText: true,
          fieldBloc: _formBloc!.loginPassword,
        ),
        PrimaryButton(
          text: "LOG IN",
          press: () => _formBloc!.submit(),
          color: theme.primaryColor,
        ),
      ],
    );
  }

  /// Builds the registration form.
  Widget _buildRegistrationForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Container(
              width: double.infinity,
              child: Text(
                "Register to join our community!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: textColorLight, fontSize: 30,
                ),
              ),
            ),
          ),
        ),
        Text(
          "Create an Account",
          style: theme.textTheme.headlineLarge?.copyWith(color: textColorLight),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        InputWidget(
          hintText: "Username",
          prefixIcon: Icons.person,
          fieldBloc: _formBloc!.registerHandle,
        ),
        InputWidget(
          hintText: "Group",
          prefixIcon: Icons.group,
          fieldBloc: _formBloc!.registerGroup,
        ),
        InputWidget(
          hintText: "Access Key",
          prefixIcon: Icons.vpn_key,
          fieldBloc: _formBloc!.registerAccessKey,
        ),
        InputWidget(
          hintText: "Password",
          prefixIcon: Icons.lock,
          obscureText: true,
          fieldBloc: _formBloc!.registerPassword,
        ),
        InputWidget(
          hintText: "Confirm Password",
          prefixIcon: Icons.lock,
          obscureText: true,
          fieldBloc: _formBloc!.registerConfirmPassword,
        ),
        PrimaryButton(
          text: "REGISTER",
          press: () => _formBloc!.submit(),
          color: theme.primaryColor,
        ),
      ],
    );
  }

  /// Displays a loading dialog during form submission.
  void _showLoadingDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      ),
    );
  }
}
