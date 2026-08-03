import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';
import 'package:segma/services/log_service.dart';
import 'package:segma/widgets/layout/app_background.dart';
import 'package:segma/widgets/layout/main_layout.dart';
import 'config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation des services
  await logService.initialize();
  
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'SEGMA',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return AppBackground(child: child);
      },
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
