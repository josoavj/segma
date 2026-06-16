# Politique de Sécurité - SEGMA

Cette politique décrit notre engagement envers la sécurité des données de segmentation et la manière dont nous gérons les vulnérabilités pour l'application SEGMA.

## 🛡️ Versions Supportées

Nous assurons le support de sécurité uniquement pour la branche de production actuelle.

| Version | Supportée          | Notes |
| ------- | ------------------ | ----- |
| 1.0.x   | :white_check_mark: | Version de production actuelle (Stable) |
| < 1.0   | :x:                | Prototypes et versions de développement |

## 🔒 Mesures de Sécurité Implémentées

SEGMA est conçu avec une architecture "Security-First" pour protéger les actifs numériques de l'utilisateur :

1.  **Isolation des Logs** : En mode `release`, tous les intercepteurs réseau (`Dio`) et les impressions de débogage sont automatiquement désactivés pour éviter la fuite de chemins de fichiers locaux ou d'adresses IP de serveurs.
2.  **Gestion des Chemins** : L'accès au système de fichiers utilise des résolutions dynamiques et sécurisées pour éviter les injections de chemins et les accès non autorisés aux dossiers système.
3.  **Communication Backend** : Le backend (FastAPI) est conçu pour être déployé dans un environnement contrôlé (VPN ou réseau local) afin d'éviter l'exposition publique du modèle SAM 3 sans authentification préalable.
4.  **Protection des Données** : Les images traitées par le modèle SAM sont gérées en mémoire ou dans des dossiers temporaires sécurisés, avec un mécanisme de nettoyage automatique.

## ⚠️ Signalement d'une Vulnérabilité

**Ne signalez pas les vulnérabilités de sécurité via les issues publiques de GitHub.**

Si vous découvrez une faille de sécurité, veuillez suivre ces étapes :

1.  Envoyez un rapport détaillé par email à : **[Votre Email ou josoa.dev@example.com]**.
2.  Incluez une description de la faille, les étapes pour la reproduire et, si possible, une suggestion de correction.
3.  Vous recevrez un accusé de réception sous **48 heures**.
4.  Une correction sera déployée en priorité, et vous serez tenu informé de l'avancement.

## 🔑 Responsabilités de l'Utilisateur

Pour garantir une sécurité maximale en production, l'utilisateur est responsable de :
-   La sécurisation du **Token HuggingFace** utilisé par le backend pour télécharger le modèle SAM 3.
-   La configuration correcte du pare-feu pour le port du backend (8000 par défaut).
-   L'utilisation de connexions chiffrées (HTTPS) si le backend est exposé sur un réseau ouvert.

## 🛠️ Dépendances Tierces

SEGMA s'appuie sur des bibliothèques reconnues (Flutter SDK, Riverpod, PyTorch). Nous effectuons des audits réguliers via `flutter pub outdated` et `pip list --outdated` pour garantir que toutes les dépendances sont à jour avec les derniers correctifs de sécurité.

---
*Dernière mise à jour : 2026*
