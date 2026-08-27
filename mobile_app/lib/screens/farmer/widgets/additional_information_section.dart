import 'package:flutter/material.dart';

import '../../../widgets/cards/expansion_card.dart';
import '../../../widgets/form/custom_text_field.dart';
import '../../../widgets/form/custom_upload_title.dart';

class AdditionalInformationSection extends StatelessWidget {
  const AdditionalInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      title: "Additional Information",
      icon: Icons.description,

      child: Column(
        children: [

          const CustomTextField(
            label: "Description",
            icon: Icons.description,
            maxLines: 4,
          ),

          const SizedBox(height: 10),

          const CustomUploadTile(
            title: "Upload Aadhaar",
            icon: Icons.badge,
          ),

          const CustomUploadTile(
            title: "Upload Bank Passbook",
            icon: Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }
}