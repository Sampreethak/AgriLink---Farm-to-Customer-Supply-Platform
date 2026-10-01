import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.validator,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue ?? (widget.items.isNotEmpty ? widget.items.first : null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        validator: widget.validator,
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
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
      ),
    );
  }
}