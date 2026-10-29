import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextStyle? hintStyle;

  final TextEditingController controller;
  final FocusNode? focusNode;

  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  final TextInputType keyboardType;
  final int maxLines;

  final bool readOnly;
  final bool obscureText;
  final bool enabled;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final VoidCallback? onTap;

  // ✔ NEW OPTIONAL FIELDS
  final bool filled;
  final Color? fillColor;

  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.hintText,
    this.hintStyle,
    this.labelText,

    required this.controller,

    this.validator,

    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,

    // defaults (optional)
    this.filled = false,
    this.fillColor,

    // optional
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      obscureText: obscureText,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,

      // added here
      inputFormatters: inputFormatters,

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        labelText: labelText,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),

        // ✔ optional fill system
        filled: filled,
        fillColor: fillColor,

        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
