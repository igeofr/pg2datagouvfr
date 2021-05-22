# PG2datagouvfr
Extraction de données PostgreSQL et transfert vers [Data.gouv.fr](https://www.data.gouv.fr/fr/) via l'[API](https://doc.data.gouv.fr/api/dataset-workflow/).

## Formats gérés.

- SQL
- GPKG
- SHP
- GeoJSON
- ODS
- CSV

## A faire pour chaque nouvelle donnée à publier

1. Créer le script d'extraction
2. Créer la description du jeu de données
3. Compléter le fichier : pg2datagouv.sh

## Exécution

```
pg2datagouv.sh COMPOSTEURS 2154 CSV
```
