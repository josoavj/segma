# FAQ SEGMA

## Utilisation locale

### Où s'exécute SEGMA ?

L'interface Flutter et l'API FastAPI tournent sur le même ordinateur. Le backend écoute par défaut sur `127.0.0.1:8000`; aucun compte utilisateur SEGMA n'est nécessaire.

### Comment démarrer l'application ?

Installez les dépendances comme indiqué dans le [guide d'installation](../setup/INSTALLATION.md), lancez `bash scripts/run_server.sh`, puis démarrez Flutter dans un autre terminal avec `flutter run -d linux` (ou la cible de bureau disponible).

### Pourquoi l'interface ne se connecte-t-elle pas ?

Vérifiez que le backend est lancé et ouvrez `http://127.0.0.1:8000/api/v3/health`. L'URL Flutter est centralisée dans `lib/core/config/backend_config.dart` et peut être remplacée au build avec `--dart-define=BACKEND_URL=...`.

## Modèle et segmentation

### Pourquoi faut-il Hugging Face ?

Le modèle `facebook/sam3` est téléchargé depuis Hugging Face. Il peut être nécessaire d'accepter ses conditions et de s'authentifier localement avec `huggingface-cli login`. Ce n'est pas un compte SEGMA.

### Comment segmenter une image ?

Choisissez un dossier et une image, saisissez un prompt puis lancez la segmentation. Les masques et les boîtes englobantes s'affichent dans le visualiseur.

### À quoi sert l'éditeur interactif ?

Les clics bleus ajoutent des zones positives et les clics rouges des zones négatives. L'interface envoie les coordonnées normalisées; le backend les convertit en petites boîtes avant de les transmettre au modèle SAM 3.

### Le modèle peut-il utiliser le CPU ?

Oui. CUDA est disponible avec un GPU NVIDIA compatible; MPS peut être proposé sur Apple Silicon. Le choix effectif du device et son état sont affichés dans Paramètres.

### Comment fonctionne le traitement par lot ?

Flutter parcourt les images directement dans le dossier choisi, envoie chaque image au backend puis la segmente. La progression est affichée pendant ce traitement séquentiel.

## API

Les routes actuelles utilisent le préfixe `/api/v3` :

- `GET /api/v3/health`
- `POST /api/v3/upload`
- `POST /api/v3/segment`
- `GET /api/v3/model/info`
- `POST /api/v3/model/change`

Pour les corps JSON et exemples `curl`, consultez [API_USAGE.md](../../backend/API_USAGE.md). Il n'y a pas de route batch : l'application orchestre le lot côté Flutter.

## Problèmes fréquents

### « Impossible de contacter le serveur »

Lancez le backend et vérifiez son adresse ainsi que le port `8000`. L'API de santé permet de distinguer un backend arrêté d'un modèle qui n'a pas fini de charger.

### Aucun masque n'est renvoyé

Essayez un prompt plus court ou plus précis, et vérifiez que l'image contient bien l'objet demandé. Dans l'éditeur, posez d'abord un clic positif sur l'objet puis des clics négatifs si nécessaire.

### CUDA manque de mémoire

Choisissez CPU dans Paramètres, fermez les autres applications utilisant le GPU ou essayez une image plus petite.

### L'image ne s'ouvre pas ou le backend refuse l'upload

Vérifiez que le fichier est accessible, non vide, au format JPG, PNG, BMP ou WebP, et qu'il respecte `MAX_FILE_SIZE` dans la configuration backend.
