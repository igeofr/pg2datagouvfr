# pg2datagouv
Extraction de données PostgreSQL et transfert vers [Data.gouv.fr](https://www.data.gouv.fr/fr/) via l'[API](https://doc.data.gouv.fr/api/dataset-workflow/).

## Formats gérés.

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

## Dépendances

Intaller :
- jq : `sudo apt-get install jq`
- gdal : `sudo apt-get install gdal-bin`
- curl : `sudo apt-get install curl`
