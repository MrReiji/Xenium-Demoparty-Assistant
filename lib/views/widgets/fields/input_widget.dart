// ignore_for_file: deprecated_member_use

import 'package:demoparty_assistant/views/Theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

/// A refined input widget with dynamic styling based on ThemeData for a modern and clean UI.
class InputWidget extends StatelessWidget {
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextInputType? textInputType;
  final TextFieldBloc? fieldBloc;
  final SelectFieldBloc<String, dynamic>? selectFieldBloc;
  final List<String>? dropdownItems;

  const InputWidget({
    Key? key,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.autofillHints,
    this.textInputType,
    this.fieldBloc,
    this.selectFieldBloc,
    this.dropdownItems,
  })  : assert(fieldBloc != null || selectFieldBloc != null,
            'Provide either fieldBloc or selectFieldBloc'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const edgeInsets = EdgeInsets.symmetric(
      vertical: AppDimensions.paddingMedium,
      horizontal: AppDimensions.paddingMedium,
    );

    const borderStyle = OutlineInputBorder(
      borderRadius:
          BorderRadius.all(Radius.circular(AppDimensions.borderRadius)),
      borderSide: BorderSide(color: Colors.grey, width: 1.5),
    );

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: AppDimensions.paddingXXSmall),
      child: Container(
        height: 100, // Enforce consistent height
        child: selectFieldBloc != null
            ? DropdownFieldBlocBuilder<String>(
                selectFieldBloc: selectFieldBloc!,
                decoration: InputDecoration(
                  labelText: hintText,
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                    fontSize: AppDimensions.paragraphFontSize,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon, color: theme.iconTheme.color)
                      : null,
                  filled: true,
                  fillColor: Colors.grey[850],
                  contentPadding: edgeInsets,
                  isDense: false, // Ensures consistent vertical alignment
                  enabledBorder: borderStyle,
                  focusedBorder: borderStyle.copyWith(
                    borderSide:
                        BorderSide(color: theme.primaryColor, width: 1.5),
                  ),
                  errorBorder: borderStyle.copyWith(
                    borderSide:
                        BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ),
                  focusedErrorBorder: borderStyle.copyWith(
                    borderSide:
                        BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ),
                  helperText: '',
                ),
                itemBuilder: (context, value) => FieldItem(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              )

            : TextFieldBlocBuilder(
                // Builds a text input field bound to the provided `fieldBloc` for state management.
                textFieldBloc: fieldBloc!,
                // Adds a suffix button for toggling password visibility if `obscureText` is true.
                suffixButton: obscureText ? SuffixButton.obscureText : null,
                // Enables autofill hints for improved user experience (e.g., username or email suggestions).
                autofillHints: autofillHints,
                // Specifies the keyboard type (e.g., text, email, number) based on input needs.
                keyboardType: textInputType,
                // Defines the visual appearance and behavior of the input field.
                decoration: InputDecoration(
                  labelText:
                      hintText, // Placeholder text inside the input field.
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor, // Matches theme hint color.
                    fontSize: AppDimensions
                        .paragraphFontSize, // Consistent font size.
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior
                      .auto, // Auto-floating labels on focus.
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon,
                          color: theme.iconTheme.color) // Optional start icon.
                      : null,
                  suffixIcon: suffixIcon != null
                      ? IconButton(
                          icon: Icon(suffixIcon,
                              color:
                                  theme.iconTheme.color), // Optional end icon.
                          onPressed: onSuffixIconPressed,
                        )
                      : null,
                  filled: true, // Adds background color for better visibility.
                  fillColor:
                      Colors.grey[850], // Background color of the input field.
                  contentPadding:
                      edgeInsets, // Adds padding for consistent spacing.
                  isDense: false, // Maintains consistent vertical alignment.
                  enabledBorder: borderStyle, // Styling for the default border.
                  focusedBorder: borderStyle.copyWith(
                    borderSide:
                        BorderSide(color: theme.primaryColor, width: 1.5),
                  ), // Border styling when focused.
                  errorBorder: borderStyle.copyWith(
                    borderSide:
                        BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ), // Border styling on error.
                  focusedErrorBorder: borderStyle.copyWith(
                    borderSide:
                        BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ), // Error styling when focused.
                  helperText: '', // Suppresses default helper text.
                ),
                // Applies custom text style for the input value.
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}

