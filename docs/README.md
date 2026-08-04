# 📖 Centre de Documentation SEGMA

Bienvenue dans la documentation officielle de **SEGMA**, l'outil professionnel de segmentation d'images assisté par l'IA (SAM 3).

## 🚀 Mise en Route

Pour démarrer rapidement avec SEGMA, suivez nos guides structurés par étapes :

1.  **[Démarrage Rapide](setup/QUICK_START.md)** : Configurez votre environnement et lancez votre première segmentation en 5 minutes.
2.  **[Guide d'Installation](setup/INSTALLATION.md)** : Instructions détaillées pour une installation complète (Backend & Frontend).

## 🎓 Guides d'Utilisation

Approfondissez vos connaissances sur les capacités de SEGMA :

-   **[Architecture Technique](../ARCHITECTURE.md)** : Comprendre comment le client Flutter communique avec le moteur SAM 3.
-   **[Guide des Prompts](guides/PROMPTS_GUIDE.md)** : Apprenez à rédiger des prompts textuels efficaces pour obtenir des masques précis.
-   **[Architecture de Test](guides/TESTING.md)** : Tout savoir sur la suite de tests et comment y contribuer.
-   **Segmentation Interactive** : Découvrez comment utiliser l'éditeur pour affiner vos résultats par simple clic (Inclusion/Exclusion).

## 🆘 Support & Dépannage

-   **[FAQ & Troubleshooting](troubleshooting/FAQ.md)** : Solutions aux erreurs courantes (CUDA, Réseau, Installation).

## 🛠️ Automatisation

Le projet inclut plusieurs scripts pour faciliter la maintenance dans le dossier `/scripts` :
-   `setup_hf.sh` : Authentification HuggingFace pour le téléchargement du modèle.
-   `install_sam3.sh` : Installation automatisée des dépendances de vision.

---
*SEGMA - Intelligence Artificielle au service de la Vision par Ordinateur.*
