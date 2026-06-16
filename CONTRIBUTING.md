# Contribution à SEGMA

Merci de l'intérêt que vous portez à **SEGMA** ! Nous sommes ravis d'accueillir des contributions pour améliorer cet outil de segmentation assisté par SAM 3.

Pour maintenir la qualité du code et la cohérence de l'architecture, veuillez suivre ces directives.

## 📋 Comment Contribuer ?

### 1. Signaler des Bugs
Si vous trouvez un bug, veuillez créer une **Issue** en précisant :
- Votre système d'exploitation (Linux, Windows, macOS).
- La version de Flutter utilisée (`flutter --version`).
- Les étapes précises pour reproduire le bug.
- Des captures d'écran si nécessaire.

### 2. Proposer des Fonctionnalités
Les nouvelles idées sont les bienvenues ! Ouvrez une **Issue** pour discuter de la fonctionnalité avant de commencer le développement afin de s'assurer qu'elle correspond à la vision du projet.

### 3. Soumettre une Pull Request (PR)
1. Forkez le projet.
2. Créez une branche descriptive (`feat/ma-super-feature` ou `fix/nom-du-bug`).
3. Travaillez sur vos modifications.
4. Assurez-vous que le code passe l'analyse statique : `flutter analyze`.
5. Soumettez votre PR avec une description détaillée des changements.

## 🛠️ Standards de Développement

### Architecture Clean & Solid
SEGMA utilise une architecture **Service-Provider-View** découplée par Riverpod.
- **Services** : Uniquement pour l'infrastructure (API, Disque).
- **Providers** : Uniquement pour la logique métier et l'état.
- **Widgets** : Uniquement pour l'affichage (UI).

### Style de Code
- Suivez les [directives officielles de style Dart](https://dart.dev/guides/language/effective-dart).
- Utilisez des noms de variables et de fonctions explicites en anglais ou français (restez cohérent avec le fichier existant).
- Évitez les méthodes statiques pour les services ; préférez l'injection via les `Providers`.

### Conventions Git
Nous suivons la norme **Conventional Commits**. Chaque commit doit être précis et préfixé :
- `feat(...)` : Nouvelle fonctionnalité.
- `fix(...)` : Correction de bug.
- `docs(...)` : Documentation.
- `refactor(...)` : Modification de code qui ne change pas le comportement.
- `perf(...)` : Amélioration des performances.

## 🧪 Tests
Avant de soumettre, vérifiez que votre code ne casse pas l'existant :
```bash
flutter analyze
flutter test
```

## 📄 Licence
En contribuant à SEGMA, vous acceptez que vos contributions soient placées sous la licence **MIT** du projet.

---
Développé par **Josoa VONJINIAINA**.
