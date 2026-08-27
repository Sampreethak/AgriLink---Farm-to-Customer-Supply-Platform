import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,

          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),

        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

