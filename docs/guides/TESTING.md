# Architecture et Guide des Tests

SEGMA accorde une grande importance à la fiabilité du code. Cette documentation explique comment fonctionne la suite de tests et comment y contribuer.

## Organisation des Tests

Le dossier `test/` à la racine du projet est organisé de manière hiérarchique :

```text
test/
├── unit/                 # Tests unitaires sans dépendances Flutter lourdes
│   ├── models/           # Sérialisation JSON, logique des modèles
│   └── services/         # Services avec Mocks (Backend, FileSystem)
├── providers/            # Tests de la logique métier (Riverpod)
└── widgets/              # Tests de composants UI (Widget testing)
```

---

## Lancement des Tests

### Ligne de commande
Pour lancer tous les tests :
```bash
flutter test
```

Pour un fichier spécifique :
```bash
flutter test test/unit/models/models_test.dart
```

### Couverture de test
Pour générer un rapport de couverture :
```bash
flutter test --coverage
# Le fichier LCOV est généré dans coverage/lcov.info
```

---

## Outils utilisés

- **flutter_test** : Framework de base fourni par Flutter.
- **mocktail** : Pour créer des mocks facilement sans génération de code.
- **ProviderContainer** : Pour tester les providers Riverpod hors de l'UI.

---

## Comment ajouter un test ?

### 1. Mocking d'un service
Si vous testez un provider qui dépend d'un service, créez un Mock :

```dart
class MockBackendService extends Mock implements BackendService {}
```

### 2. ProviderContainer
Pour tester la logique d'un provider, utilisez un `ProviderContainer` pour surcharger les dépendances :

```dart
final container = ProviderContainer(
  overrides: [
    backendServiceProvider.overrideWithValue(mockBackend),
  ],
);
```

### 3. Tests de flux (Streaming)
Pour les fonctions asynchrones complexes (comme le traitement par lot), utilisez des `StreamController` pour simuler l'envoi de données NDJSON.

---

## Standards de Qualité

> [IMPORTANT]
> - Chaque nouveau service ou provider **doit** avoir un fichier de test associé.
> - Les tests ne doivent jamais dépendre d'un serveur backend réel ou de fichiers utilisateur réels. Utilisez des dossiers temporaires (`Directory.systemTemp`).
> - La suite de tests doit passer intégralement avant toute Pull Request.

---
*Dernière mise à jour : Août 2026*
