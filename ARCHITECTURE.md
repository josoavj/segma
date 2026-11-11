# Architecture SEGMA

SEGMA est une application de bureau locale. L'interface Flutter appelle un backend FastAPI lancé sur la même machine (`127.0.0.1:8000`). Le backend charge SAM 3 et écrit les masques dans ses répertoires de données locaux.

## Composants

### Interface Flutter (`lib/`)

- `app/` : démarrage, navigation et injection des services.
- `core/` : configuration, thème, erreurs, journalisation et composants partagés.
- `features/home/` : navigation locale dans les dossiers et grille d'images.
- `features/segmentation/` : service API, état Riverpod, visualiseur, masques et éditeur.
- `features/settings/`, `logs/`, `about/` et `segmented_objects/` : pages dédiées.

### Backend (`backend/`)

- `main.py` démarre FastAPI et initialise le modèle.
- `app/api/` définit les routes et schémas de l'API v3.
- `app/services/` gère les uploads et le pipeline de segmentation.
- `app/models/` contient le gestionnaire et le wrapper SAM 3.

## Parcours de segmentation

1. L'utilisateur choisit une image sur son disque.
2. Flutter l'envoie au backend local une seule fois par session.
3. La segmentation texte transmet un prompt. L'éditeur transmet des clics d'inclusion/exclusion normalisés; le backend les convertit en boîtes visuelles positives ou négatives pour SAM 3.
4. Pour un lot, Flutter répète ces deux requêtes pour chaque image et suit la progression localement.
5. Le backend sauvegarde les masques binaires et renvoie leurs chemins, dimensions, scores et boîtes englobantes.
6. Flutter affiche le résultat et peut recalculer le masque après chaque clic dans l'éditeur.

## API principale

- `GET /api/v3/health` : état du backend et du modèle.
- `POST /api/v3/upload` : envoi d'une image.
- `POST /api/v3/segment` : segmentation par prompt texte ou zones visuelles.
- `GET /api/v3/model/info` et `POST /api/v3/model/change` : état et configuration du modèle.

## Tests présents

Les tests se trouvent dans `test/unit/`, `test/features/` et `test/app/`. Ils couvrent les modèles, les services de fichiers et d'API, les view models de segmentation et la sidebar. L'éditeur interactif n'a pas encore de test widget dédié.
