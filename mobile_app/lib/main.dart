import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/localization.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const AgriLinkApp(),
    ),
  );
}

