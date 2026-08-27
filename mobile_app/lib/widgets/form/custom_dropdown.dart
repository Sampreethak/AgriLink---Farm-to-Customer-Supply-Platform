import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> items;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: selectedValue,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
      ),
    );
  }
}