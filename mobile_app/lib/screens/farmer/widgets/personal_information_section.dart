import 'package:flutter/material.dart';

import '../../../widgets/cards/expansion_card.dart';
import '../../../widgets/form/custom_text_field.dart';

class PersonalInformationSection extends StatelessWidget {
  const PersonalInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      initiallyExpanded: true,
      title: "Personal Information",
      icon: Icons.person,
      child: Column(
        children: const [

          CustomTextField(
            label: "Full Name",
            icon: Icons.person,
            readOnly: true,
            initialValue: "Sampreetha",
          ),

          CustomTextField(
            label: "Email",
            icon: Icons.email,
            readOnly: true,
            initialValue: "sample@gmail.com",
          ),

          CustomTextField(
            label: "Phone Number",
            icon: Icons.phone,
            readOnly: true,
            initialValue: "9876543210",
          ),
        ],
      ),
    );
  }
}