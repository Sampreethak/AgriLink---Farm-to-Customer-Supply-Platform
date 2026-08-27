import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final int maxLines;
  final bool readOnly;
  final String? initialValue;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: readOnly,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        keyboardType: keyboardType,

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