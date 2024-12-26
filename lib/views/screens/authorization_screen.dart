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

/// **Authorization screen**
/// Handles user authentication, including login, logout, and registration.
/// Displays different UI depending on the user's logged-in status.
/// Utilizes `AuthorizationFormBloc` to manage form states and submission.
class Authorization extends StatefulWidget {
  @override
  _AuthorizationState createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {
  final AuthGuard _authGuard = AuthGuard(); // AuthGuard for managing session validity.
  AuthorizationFormBloc? _formBloc; // Bloc for managing form state.
  bool _isLoading = true; // Tracks whether the login status is being determined.
  bool _isLoggedIn = false; // Tracks the user's login state.
  String? _userName; // Stores the username of the logged-in user.

  @override
  void initState() {
    super.initState();
    _initializeLoginStatus(); // Initialize login status on widget load.
  }

  /// **Initialize login status**
  /// Determines whether the user is logged in and sets up the form bloc for authentication if not.
  Future<void> _initializeLoginStatus() async {
    final isValid = await _authGuard.isSessionValid(); // Check if the session is valid.
    if (isValid) {
      // If valid, retrieve the username from secure storage.
      final storage = GetIt.I<FlutterSecureStorage>();
      _userName = await storage.read(key: 'user_name') ?? "User";
    } else {
      // If not logged in, initialize a new form bloc for login/registration.
      _formBloc = AuthorizationFormBloc();
    }
    setState(() {
      _isLoggedIn = isValid; // Update login state.
      _isLoading = false; // Loading complete.
    });
  }

  /// **Logout the user**
  /// Clears the session and resets the form bloc for new authentication.
  Future<void> _logout() async {
    await _authGuard.clearSession(); // Clear session data.
    setState(() {
      _isLoggedIn = false; // Set logged-in status to false.
      _formBloc = AuthorizationFormBloc(); // Reinitialize the form bloc for new login attempts.
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while determining login status.
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Dynamic title based on user's login state.
        title: Text(_isLoggedIn ? "Welcome, $_userName" : "Authorization"),
        actions: [
          if (!_isLoggedIn)
            // Toggle between login and registration forms.
            TextButton(
              onPressed: () {
                setState(() {
                  _formBloc!.isLogin
                      ? _formBloc!.switchToRegistration()
                      : _formBloc!.switchToLogin();
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
      drawer: AppDrawer(currentPage: "Authorization"), // Add the navigation drawer.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          // Show either the logged-in UI or the authentication form.
          child: _isLoggedIn ? _buildLoggedInUI() : _buildAuthForm(),
        ),
      ),
    );
  }

  /// **Build UI for logged-in users**
  /// Displays a welcome message and a logout button.
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

  /// **Build the authentication form**
  /// Dynamically displays login or registration form based on `isLogin` state.
  Widget _buildAuthForm() {
    return BlocProvider(
      create: (_) => _formBloc!,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return FormBlocListener<AuthorizationFormBloc, String, String>(
            // Display a loading dialog during form submission.
            onLoading: (context, state) => _showLoadingDialog(context, theme),
            onSubmitting: (context, state) => _showLoadingDialog(context, theme),
            onSuccess: (context, state) async {
              await _initializeLoginStatus(); // Re-check login status after successful form submission.
              Navigator.of(context).pop(); // Close loading dialog.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successResponse ?? "Submission Successful"),
                ),
              );
            },
            onFailure: (context, state) {
              Navigator.of(context).pop(); // Close loading dialog.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failureResponse ?? "Submission Failed"),
                ),
              );
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_formBloc!.isLogin) ...[
                    _buildLoginForm(theme), // Build login form.
                  ] else ...[
                    _buildRegistrationForm(theme), // Build registration form.
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// **Build the login form**
  /// Allows the user to log in with a username and password.
  Widget _buildLoginForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            "Log in to access exclusive content!",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: textColorLight,
              fontSize: 30,
            ),
          ),
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

  /// **Build the registration form**
  /// Allows the user to register for a new account.
  Widget _buildRegistrationForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            "Register to join our community!",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: textColorLight,
              fontSize: 30,
            ),
          ),
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

  /// **Show a loading dialog**
  /// Displays a loading indicator during form submission.
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
