import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final int maxLines;
  final bool readOnly;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        readOnly: readOnly,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,

        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: readOnly
              ? Colors.grey.shade100
              : Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}