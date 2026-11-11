# Architecture réelle de SEGMA

SEGMA fonctionne en local : l'application Flutter lit les images du disque et communique avec un backend FastAPI sur `http://localhost:8000`. SAM 3 effectue l'inférence dans le backend; les masques binaires restent dans les répertoires de données du backend.

## Interface Flutter

- `lib/app/` assemble l'application, la navigation et les services.
- `lib/core/` rassemble configuration, thème, journalisation, erreurs et notifications.
- `lib/features/home/` navigue dans les dossiers locaux et affiche les images.
- `lib/features/segmentation/` gère l'API, les résultats, le visualiseur et l'éditeur.
- Les paramètres, journaux, objets segmentés et informations de l'application ont chacun leur module sous `lib/features/`.

Riverpod porte l'état de navigation, les images sélectionnées et les requêtes asynchrones. Dio communique avec le backend local.

## Backend

`backend/main.py` démarre FastAPI et initialise le gestionnaire SAM 3. Les routes de l'API sont dans `backend/app/api/routes/`, le pipeline dans `backend/app/services/` et l'intégration du modèle dans `backend/app/models/sam3/`.

Routes utilisées par l'application :

| Route | Rôle |
| --- | --- |
| `GET /api/v3/health` | État du serveur et disponibilité du modèle |
| `POST /api/v3/upload` | Copie une image locale vers le backend |
| `POST /api/v3/segment` | Prompt texte ou zones visuelles positives/négatives |
| `GET /api/v3/model/info` | Modèle et device actifs |
| `POST /api/v3/model/change` | Changement de device ou rechargement du modèle |

## Prompts visuels

Le modèle `Sam3Model` utilisé ici accepte des boîtes positives et négatives. L'éditeur Flutter envoie les clics comme coordonnées normalisées entre 0 et 1 et leur label (`1` pour inclure, `0` pour exclure). Le backend les convertit en petites boîtes autour des clics et les transmet au processeur SAM 3. Ce flux ne réutilise pas les embeddings d'image entre les requêtes.

Le traitement par lot est orchestré par Flutter : chaque image du dossier est uploadée puis segmentée à son tour. La progression est tenue côté interface; il n'existe pas de route batch dédiée.

## Formats de sortie

Chaque objet renvoyé par l'API contient son score, son label, sa boîte en pixels, son nombre de pixels et le chemin local d'un masque binaire brut. Le masque contient un octet par pixel et ses dimensions sont celles de l'image source.

## Tests

Les tests disponibles sont organisés dans `test/unit/`, `test/features/` et `test/app/`. Les services et view models ont des tests ciblés; aucun test widget dédié à l'éditeur interactif n'est présent pour le moment.
