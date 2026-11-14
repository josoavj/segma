import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/core/theme/app_theme.dart';
import 'package:segma/app/shell/view_models/navigation_view_model.dart';
import 'package:segma/core/widgets/app_background.dart';
import 'package:segma/app/shell/views/main_layout.dart';

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
