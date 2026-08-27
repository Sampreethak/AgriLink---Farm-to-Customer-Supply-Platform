import 'package:flutter/material.dart';

import '../../../widgets/cards/expansion_card.dart';
import '../../../widgets/form/custom_dropdown.dart';
import '../../../widgets/form/custom_text_field.dart';

class BankingInformationSection extends StatelessWidget {
  const BankingInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      title: "Banking Details",
      icon: Icons.account_balance,

      child: Column(
        children: [

          const CustomDropdown(
            label: "Bank Name",
            icon: Icons.account_balance,
            items: [
              "SBI",
              "HDFC",
              "ICICI",
              "Axis",
              "Canara",
              "PNB",
              "Indian Bank",
            ],
          ),

          const CustomTextField(
            label: "Account Number",
            icon: Icons.numbers,
          ),

          const CustomTextField(
            label: "IFSC Code",
            icon: Icons.code,
          ),

          const CustomTextField(
            label: "UPI ID",
            icon: Icons.payment,
          ),
        ],
      ),
    );
  }
}