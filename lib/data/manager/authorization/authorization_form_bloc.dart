import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

/// Bloc responsible for handling user authorization through login and registration.
class AuthorizationFormBloc extends FormBloc<String, String> {
  // TextFieldBloc instances for login form fields
  final login = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final loginPassword = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.passwordMin6Chars,
  ]);

  // TextFieldBloc instances for registration form fields
  final registerHandle = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final registerGroup = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final registerAccessKey = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final registerCountry = SelectFieldBloc<String, dynamic>(
    items: ['Germany', 'USA', 'France', 'Japan', 'Other'],
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

  // Dependency injection for secure storage
  final _storage = GetIt.I<FlutterSecureStorage>();

  // State variables for tracking login/registration status
  bool isLogin = true;
  bool isLoggedIn = false;
  String? sessionCookie;
  DateTime? cookieExpiry;

  /// Constructor to initialize the form bloc and default fields.
  AuthorizationFormBloc() {
    _addLoginFields();
  }

  /// Switches to registration mode and resets the form.
  void switchToRegistration() {
    debugPrint("Switching to registration mode.");
    isLogin = false;
    clear(); // Clears all form fields.
    _addRegistrationFields();
  }

  /// Switches to login mode and resets the form.
  void switchToLogin() {
    debugPrint("Switching to login mode.");
    isLogin = true;
    clear(); // Clears all form fields.
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

  /// Logs the user out by clearing stored credentials and resetting the form.
  Future<void> logout() async {
    debugPrint("Logging out the user.");
    isLoggedIn = false;
    sessionCookie = null;
    cookieExpiry = null;

    // Clear session data from secure storage
    await _storage.delete(key: 'session_cookie');
    await _storage.delete(key: 'cookie_expiry');

    clear();
    switchToLogin();
    emitSuccess(successResponse: "Logged out successfully!");
  }

  /// Handles form submission for either login or registration based on the mode.
  @override
  Future<void> onSubmitting() async {
    debugPrint("Form submission started. isLogin: $isLogin");

    try {
      if (isLogin) {
        // Login logic
        final url = Uri.parse("https://party.xenium.rocks/visitors");
        final headers = {"Content-Type": "application/x-www-form-urlencoded"};
        final body = {
          "visitor_login[login]": login.value,
          "visitor_login[password]": loginPassword.value,
          "login": "Log in"
        };

        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 302) {
          // Parse cookies from response
          final cookies = response.headers['set-cookie']?.split(RegExp(r',(?=\s*\w+=)')) ?? [];
          sessionCookie = cookies
              .where((cookie) => cookie.contains('session') || cookie.contains('autologin_user_auth_visitor'))
              .map((cookie) => cookie.split(';').first.trim())
              .join('; ');

          // Extract expiry date from cookies or set a default expiry
          final expiryMatch = RegExp(r'Expires=(.*?);').firstMatch(response.headers['set-cookie'] ?? '');
          if (expiryMatch != null) {
            cookieExpiry = DateTime.parse(expiryMatch.group(1)!);
          } else {
            // Default expiry to 3 days from now
            cookieExpiry = DateTime.now().add(Duration(days: 3));
          }

          isLoggedIn = true;

          // Store session details securely
          await _storage.write(key: 'session_cookie', value: sessionCookie);
          await _storage.write(key: 'cookie_expiry', value: cookieExpiry!.toIso8601String());
          await _storage.write(key: 'user_name', value: login.value);

          emitSuccess(successResponse: "Logged in successfully!");
        } else {
          emitFailure(failureResponse: "Login failed. Check your credentials.");
        }
      } else {
        // Placeholder for registration logic
        debugPrint("Attempting registration.");
        emitSuccess(successResponse: "Registered successfully!");
      }
    } catch (error) {
      emitFailure(failureResponse: "An error occurred: $error");
    }
  }
}
