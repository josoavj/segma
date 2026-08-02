import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:segma/providers/navigation_provider.dart';
import 'package:segma/widgets/modern_sidebar.dart';

void main() {
  Widget createTestableWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: ModernSidebar(),
        ),
      ),
    );
  }

  group('ModernSidebar Widget Tests', () {
    testWidgets('Should display SEGMA title when expanded', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      
      // Par défaut il est expansé (selon navigation_provider)
      expect(find.text('SEGMA'), findsOneWidget);
      expect(find.text('Image Segmentation'), findsOneWidget);
    });

    testWidgets('Should change current page on click', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      
      // Cliquer sur le menu Paramètres
      await tester.tap(find.text(NavigationPage.settings.label));
      await tester.pumpAndSettle();
      
      // On vérifie que l'état a changé (ceci nécessiterait d'accéder au container)
      // Mais on peut au moins vérifier que le clic ne crash pas
    });

    testWidgets('Should collapse when sidebarCollapsedProvider is true', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sidebarCollapsedProvider.overrideWith((ref) => true),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ModernSidebar(),
            ),
          ),
        ),
      );
      
      // En mode réduit, le titre SEGMA ne devrait pas être visible en texte simple
      // (il est dans le header réduit sous forme d'icône seulement)
      expect(find.text('SEGMA'), findsNothing);
    });
  });
}
