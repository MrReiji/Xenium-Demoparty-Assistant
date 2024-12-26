import 'dart:io';

/// A utility class to handle errors and provide user-friendly messages.
class ErrorHelper {
  /// Returns a user-friendly error message based on the exception type.
  static String getErrorMessage(Object error) {
    if (error is SocketException) {
      return """
Unable to connect to the internet.
Please check your network connection and try again.
If cache is enabled, you can browse cached data offline.""";
    } else if (error is HttpException) {
      return """
The server is currently unreachable.
Please ensure your internet connection is stable or try again later.""";
    } else if (error is FormatException) {
      return """
Data received from the server is corrupted.
Please check for app updates or report the issue to support.""";
    } else if (error is Exception) {
      return """
An unexpected error occurred: ${error.toString()}.
Please try again or report the issue to support.""";
    } else {
      return """
An unknown error occurred.
Please try again or contact support for further assistance.""";
    }
  }

  /// A generic handler for actions when errors occur.
  static void handleError(Object error) {
    // Add logging or error tracking here, e.g., Firebase Crashlytics.
    print("[ErrorHelper] Error encountered: $error");
  }
}
