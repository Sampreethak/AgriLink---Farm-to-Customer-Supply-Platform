import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/localization.dart';
import '../auth/login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguageCode;

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    _selectedLanguageCode ??= langProvider.currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Top illustration/icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate,
                    size: 60,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                langProvider.translate('language_selection'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please choose your preferred language to proceed\nकृपया आगे बढ़ने के लिए अपनी पसंदीदा भाषा चुनें",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Language Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: LanguageProvider.languages.length,
                  itemBuilder: (context, index) {
                    final code = LanguageProvider.languages.keys.elementAt(index);
                    final name = LanguageProvider.languages[code]!;
                    final isSelected = _selectedLanguageCode == code;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguageCode = code;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfaceLight : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : AppColors.border,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getLanguageGlyph(code),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 12,
                                right: 12,
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Continue button
              ElevatedButton(
                onPressed: () async {
                  if (_selectedLanguageCode != null) {
                    await langProvider.setLanguage(_selectedLanguageCode!);
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Continue / आगे बढ़ें",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageGlyph(String code) {
    switch (code) {
      case 'en':
        return 'Aa';
      case 'hi':
        return 'अ';
      case 'kn':
        return 'ಅ';
      case 'te':
        return 'అ';
      case 'ta':
        return 'அ';
      case 'ml':
        return 'അ';
      default:
        return 'A';
    }
  }
}
