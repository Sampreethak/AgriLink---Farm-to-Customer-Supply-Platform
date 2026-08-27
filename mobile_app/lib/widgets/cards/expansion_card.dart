import 'package:flutter/material.dart';

class ExpansionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  const ExpansionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      margin: const EdgeInsets.only(bottom: 18),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,

        leading: Icon(icon),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        childrenPadding: const EdgeInsets.all(18),

        children: [
          child,
        ],
      ),
    );
  }
}