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
      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.borderRadius)),
      borderSide: BorderSide(color: Colors.grey, width: 1.5),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXXSmall),
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
                    borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                  ),
                  errorBorder: borderStyle.copyWith(
                    borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ),
                  focusedErrorBorder: borderStyle.copyWith(
                    borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ),
                  helperText: '',
                ),
                itemBuilder: (context, value) => FieldItem(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
              )
            : TextFieldBlocBuilder(
                textFieldBloc: fieldBloc!,
                suffixButton: obscureText ? SuffixButton.obscureText : null,
                autofillHints: autofillHints,
                keyboardType: textInputType,
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
                  suffixIcon: suffixIcon != null
                      ? IconButton(
                          icon: Icon(suffixIcon, color: theme.iconTheme.color),
                          onPressed: onSuffixIconPressed,
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[850],
                  contentPadding: edgeInsets,
                  isDense: false, // Ensures consistent vertical alignment
                  enabledBorder: borderStyle,
                  focusedBorder: borderStyle.copyWith(
                    borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                  ),
                  errorBorder: borderStyle.copyWith(
                    borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ),
                  focusedErrorBorder: borderStyle.copyWith(
                    borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ),
                  helperText: '',
                ),
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
