# API SEGMA v3

Le backend est prévu pour une utilisation locale. Par défaut, il écoute sur `127.0.0.1:8000`.

## Routes

| Méthode | Route | Description |
| --- | --- | --- |
| `GET` | `/api/v3/health` | État du serveur et du modèle |
| `POST` | `/api/v3/upload` | Envoi d'une image multipart avec le champ `file` |
| `POST` | `/api/v3/segment` | Segmentation textuelle ou guidée par zones visuelles |
| `GET` | `/api/v3/model/info` | Informations du modèle et du device |
| `POST` | `/api/v3/model/change` | Changement de device ou rechargement du modèle |

## Vérifier le backend

```bash
curl http://127.0.0.1:8000/api/v3/health
```

## Envoyer une image

```bash
curl -F "file=@image.jpg" http://127.0.0.1:8000/api/v3/upload
```

La réponse donne un nom généré par le backend, par exemple `a1b2c3.jpg`. Utilisez cette valeur de `image_path` comme `filename` pour segmenter.

## Segmentation par texte

```bash
curl -X POST http://127.0.0.1:8000/api/v3/segment \
  -H "Content-Type: application/json" \
  -d '{"filename":"a1b2c3.jpg","prompt":"red car","confidence_threshold":0.25}'
```

## Segmentation guidée par clics

Les coordonnées sont normalisées entre `0` et `1`; `label: 1` inclut une zone, `label: 0` l'exclut. Le backend transforme chaque clic en petite boîte et la transmet à SAM 3.

```bash
curl -X POST http://127.0.0.1:8000/api/v3/segment \
  -H "Content-Type: application/json" \
  -d '{"filename":"a1b2c3.jpg","points":[{"x":0.52,"y":0.41,"label":1},{"x":0.64,"y":0.49,"label":0}]}'
```

La réponse de segmentation contient `image_path`, `resolution`, `objects_count`, `objects` et `segmentation_dir`. Chaque objet comprend `object_id`, `label`, `confidence`, `bbox`, `mask_path` et `pixels_count`. Un masque `.bin` est un tableau brut `uint8` d'un octet par pixel, de largeur et hauteur égales à l'image.

## Traitement par lot

Le traitement par lot de l'application est géré par Flutter : chaque image du dossier local est uploadée puis envoyée à `/api/v3/segment`. Il n'existe pas de route batch côté backend.
