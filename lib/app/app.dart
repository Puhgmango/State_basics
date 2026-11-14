import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../features/state_demo/presentation/pages/home_page.dart';

/// Widget gốc của ứng dụng. Không có state nên dùng [StatelessWidget].
class StateBasicsApp extends StatelessWidget {
  const StateBasicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
