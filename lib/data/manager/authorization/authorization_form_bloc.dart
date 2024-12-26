import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

/// Bloc responsible for handling user authorization through login and registration.
/// Supports secure storage of session data and dynamic switching between login and registration modes.
class AuthorizationFormBloc extends FormBloc<String, String> {
  // Login form fields
  final login = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final loginPassword = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.passwordMin6Chars,
  ]);

  // Registration form fields
  final registerHandle = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final registerGroup = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final registerAccessKey = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final registerCountry = SelectFieldBloc<String, dynamic>(
    items: ['Germany', 'USA', 'France', 'Japan', 'Other'], // Predefined dropdown options.
    validators: [FieldBlocValidators.required],
  );
  final registerPassword = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.passwordMin6Chars,
  ]);
  final registerConfirmPassword = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.passwordMin6Chars,
  ]);

  // Secure storage instance for managing session data
  final _storage = GetIt.I<FlutterSecureStorage>();

  // State variables
  bool isLogin = true; // Tracks whether the current mode is login.
  bool isLoggedIn = false; // Indicates if the user is logged in.
  String? sessionCookie; // Stores the session cookie.
  DateTime? cookieExpiry; // Stores the expiry date of the session.

  /// Constructor initializes the form with login fields by default.
  AuthorizationFormBloc() {
    _addLoginFields();
  }

  /// Switches to registration mode and clears the form fields.
  void switchToRegistration() {
    debugPrint("Switching to registration mode.");
    isLogin = false;
    clear(); // Clears all fields in the form.
    _addRegistrationFields();
  }

  /// Switches to login mode and clears the form fields.
  void switchToLogin() {
    debugPrint("Switching to login mode.");
    isLogin = true;
    clear(); // Clears all fields in the form.
    _addLoginFields();
  }

  /// Adds login fields to the form.
  void _addLoginFields() {
    debugPrint("Adding login fields to the form.");
    addFieldBlocs(fieldBlocs: [login, loginPassword]);
  }

  /// Adds registration fields to the form.
  void _addRegistrationFields() {
    debugPrint("Adding registration fields to the form.");
    addFieldBlocs(fieldBlocs: [
      registerHandle,
      registerGroup,
      registerAccessKey,
      registerCountry,
      registerPassword,
      registerConfirmPassword,
    ]);
  }

  /// Logs the user out by clearing session data from secure storage and resetting the form.
  Future<void> logout() async {
    debugPrint("Logging out the user.");
    isLoggedIn = false;
    sessionCookie = null;
    cookieExpiry = null;

    // Clear session data securely
    await _storage.delete(key: 'session_cookie');
    await _storage.delete(key: 'cookie_expiry');
    await _storage.delete(key: 'user_name');

    clear(); // Clears all form fields.
    switchToLogin(); // Resets to login mode.
    emitSuccess(successResponse: "Logged out successfully!");
  }

  /// Handles form submission logic for both login and registration modes.
  /// Login: Sends credentials to the server and manages session cookies.
  /// Registration: Placeholder logic for future implementation.
  @override
  Future<void> onSubmitting() async {
    debugPrint("Form submission started. isLogin: $isLogin");

    // Variables for login submission
    final String loginUrl = "https://party.xenium.rocks/visitors"; // Server URL for login.
    final Map<String, String> loginHeaders = {"Content-Type": "application/x-www-form-urlencoded"};
    final Map<String, String> loginBody = {
      "visitor_login[login]": login.value,
      "visitor_login[password]": loginPassword.value,
      "login": "Log in",
    };

    try {
      if (isLogin) {

        // Send login request
        final response = await http.post(Uri.parse(loginUrl), headers: loginHeaders, body: loginBody);

        if (response.statusCode == 302) {
          debugPrint("Login successful. Processing session cookies.");

          // Extract session cookies
          final cookies = response.headers['set-cookie']?.split(RegExp(r',(?=\s*\w+=)')) ?? [];
          sessionCookie = cookies
              .where((cookie) => cookie.contains('session') || cookie.contains('autologin_user_auth_visitor'))
              .map((cookie) => cookie.split(';').first.trim())
              .join('; ');

          // Extract or set a default expiry date
          final expiryMatch = RegExp(r'Expires=(.*?);').firstMatch(response.headers['set-cookie'] ?? '');
          cookieExpiry = expiryMatch != null
              ? DateTime.parse(expiryMatch.group(1)!)
              : DateTime.now().add(Duration(hours: 1)); // Default expiry in 1 hour

          isLoggedIn = true;

          // Store session data securely
          await _storage.write(key: 'session_cookie', value: sessionCookie);
          await _storage.write(key: 'cookie_expiry', value: cookieExpiry!.toIso8601String());
          await _storage.write(key: 'user_name', value: login.value);

          emitSuccess(successResponse: "Logged in successfully!");
        } else {
          debugPrint("Login failed. Response code: ${response.statusCode}");
          emitFailure(failureResponse: "Login failed. Check your credentials.");
        }
      } 
      
       {
        // Placeholder logic for registration
        debugPrint("Registration logic not implemented yet.");
        emitSuccess(successResponse: "Registered successfully!");
      }
    } catch (error) {
      // Catch and handle any errors during submission
      debugPrint("Error during submission: $error");
      emitFailure(failureResponse: "An error occurred: $error");
    }
  }
}
