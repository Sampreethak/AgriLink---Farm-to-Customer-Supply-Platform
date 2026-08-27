import 'package:flutter/material.dart';

class CustomUploadTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const CustomUploadTile({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: const Text("Tap to upload"),
        trailing: const Icon(Icons.upload),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$title upload coming soon"),
            ),
          );
        },
      ),
    );
  }
}