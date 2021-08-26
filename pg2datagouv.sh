#!/bin/sh
# ===============================================================================
# Created By : Florian Boret
# Created Date : Mai 2021
# Date last modified :
# ===============================================================================
# Démarage du compteur > temps
start=$(date '+%s')

# -------------------------------------------------------------------------------
# LECTURE DU FICHIER DE CONFIGURATION
. ./config.env

# -------------------------------------------------------------------------------
if [ "$#" -ge 1 ]; then
  if [ "$1" = "COMPOSTEURS" ];
  then
    a_DONNEE=$1
  else
  IFS= read -p "DONNEE : " p_DONNEE
  if [ "$p_DONNEE" = "COMPOSTEURS" ];
  then
    export a_DONNEE=$p_DONNEE
  else
    echo "Erreur de paramètre"
    exit 0
  fi
fi
else
  IFS= read -p "DONNEE : " p_DONNEE
  if [ "$p_DONNEE" = "COMPOSTEURS" ];
  then
    export a_DONNEE=$p_DONNEE
  else
    echo "Erreur de paramètre"
    exit 0
  fi
fi
# -------------------------------------------------------------------------------
if [ "$#" -ge 2 ]; then
  if [ "$2" = "2154" ] || [ "$2" = "4326" ];
  then
    c_epsg=$2
  else
  IFS= read -p "EPSG : " p_epsg
  if [ "$p_epsg" = "2154" ] || [ "$p_epsg" = "4326" ];
  then
    export c_epsg=$p_epsg
  else
    echo "Erreur de paramètre"
    exit 0
  fi
fi
else
  IFS= read -p "EPSG : " p_epsg
  if [ "$p_epsg" = "2154" ] || [ "$p_epsg" = "4326" ];
  then
    export c_epsg=$p_epsg
  else
    echo "Erreur de paramètre"
    exit 0
  fi
fi
# -------------------------------------------------------------------------------
if [ "$#" -ge 3 ]; then
  if [ "$3" = "SHP" ] || [ "$3" = "GPKG" ] || [ "$3" = "SQL" ] || [ "$3" = "CSV" ] || [ "$3" = "ODS" ] || [ "$3" = "GEOJSON" ];
  then
    format=$3
  else
    IFS= read -p "FORMAT : " p_format
    if [ "$p_format" = "SHP" ] || [ "$p_format" = "GPKG" ] || [ "$p_format" = "SQL" ] || [ "$p_format" = "CSV" ] || [ "$p_format" = "ODS" ] || [ "$p_format" = "GEOJSON" ];
    then
      export format=$p_format
    else
      echo "Erreur de paramètre"
      exit 0
    fi
  fi
else
  IFS= read -p "FORMAT : " p_format
  if [ "$p_format" = "SHP" ] || [ "$p_format" = "GPKG" ]|| [ "$p_format" = "SQL" ] || [ "$p_format" = "CSV" ] || [ "$p_format" = "ODS" ] || [ "$p_format" = "GEOJSON" ];
  then
    export format=$p_format
  else
    echo "Erreur de paramètre"
    exit 0
  fi
fi
# -------------------------------------------------------------------------------
# VARIABLES
# DATE DU TRAITEMENT
# export DATE_T=$(date '+%Y%m')
export DATE_T=$(date "+%Y%m")
# export DATE_OLD=$(date -d "-1 month" '+%Y%m')
export DATE_OLD='date -d "-1 month" "+%Y%m"'

export DONNEE=$a_DONNEE
export OUT_EPSG=$c_epsg
export FORMAT_SIG=$format
echo $DONNEE

. ./$REPER_DESC'/'$DONNEE'.env'
echo $DESCRIPTION

if [ "$OUT_EPSG" = "4326" ]
then
  export NZ='_WGS84_4326'
fi
if [ "$OUT_EPSG" = "2154" ]
then
  export NZ='_L93_2154'
fi
# -------------------------------------------------------------------------------
# DIRECTION LE DOSSIER
cd $REPER
mkdir $REPER_TEMP'/'$DONNEE
mkdir $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG
cd $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG
rm -rfv *
cd $REPER

# -------------------------------------------------------------------------------
# LISTE DES DONNEES EXPORTABLES PAR THEMATIQUE (A COMPLETER)

# DECHETS
# COMPOSTEURS -------------------------------------------------------------------
if [ "$DONNEE" = "COMPOSTEURS" ]; then
  # LANCEMENT DE L'EXTRACTION
  sh scripts/dechets_composteurs.sh | tee $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/dechets_composteurs.txt'
  # SUPPRESSIN DU LOG
  rm -r $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/dechets_composteurs.txt'
  # AJOUT DE LA LICENCE
  cp attachment/Z_Licence.txt $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/Z_Licence.txt'
else
  echo "Erreur de paramètre"
  exit 0
fi

# --------------------------------------------------------------------------------
# COMPRESSION ZIP EN SORTIE

# ZIP DANS LE REPERTOIRE EN SORTIE
cd $REPER'/'$REPER_OUT'/'
# SUPRESSION DU FICHIER SI DEJA CREE A LA MEME DATE
rm -r $DATE_T'_'$DONNEE'_'$FORMAT_SIG$NZ'.zip'
# COMPRESSION
zip -j -r $DATE_T'_'$DONNEE'_'$FORMAT_SIG$NZ'.zip' $REPER'/'$REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/'*

# -------------------------------------------------------------------------------
# TESTER SI LE JEU DE DONNEES EXISTE
FILE=$REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'.json'
if test -f "$FILE"; then
    # ----------------------------------------------------------------------------------------------------------------------------------------------------
    # ----------------------------------------------------------------------------------------------------------------------------------------------------
    echo "$FILE existe"
    # RECUPERATION DE L'IDENTIFIANT DU JEU DE DONNEES
    DATASET=$(jq -r '.id' $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'.json')
    echo "${DATASET}"

    # ---------------------------------------------------------------------------
    # TESTER SI LA RESSOURCE EXISTE
    FILE_RESSOURCE=$REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json'
    if test -f "$FILE_RESSOURCE"; then

      # ----------------------------------------------------------------------------------------------------------------------------------------------------
      # ----------------------------------------------------------------------------------------------------------------------------------------------------
      # RECUPERATION DE L'IDENTIFIANT DE LA RESSOURCE
      RESOURCE=$(jq -r '.id' $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json')
      echo "${RESOURCE}"

      # -------------------------------------------------------------------------
      # ACTUALISATION A JOUR DE LA FICHE DE METADONNEES DU JEU DE DONNEES
      curl -H "Content-Type:application/json" \
           -H "Accept:application/json" \
           -H "X-Api-Key:$API_KEY" \
           --data '{"title": "'"$TITLE"'", "description": "'"$DESCRIPTION"'", "tags": "'"$TAG"'", "frequency": "'"$FREQUENCY"'", "spatial": "'"$SPATIAL"'", "license": "'"$LICENSE"'", "temporal_coverage": "'"$TEMPORAL_COVERAGE"'", "private": "true"}' \
           -X PUT $API'/datasets/'$DATASET'/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'.json'
      # -------------------------------------------------------------------------
      # ACTUALISATION DE LA RESSOURCE
      curl -H "Accept:application/json" \
           -H "X-Api-Key:$API_KEY" \
           -F "file=@"$REPER"/"$REPER_OUT"/"$DATE_T"_"$DONNEE"_"$FORMAT_SIG$NZ".zip" \
           -X POST $API'/datasets/'$DATASET'/resources/'$RESOURCE'/upload/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json'
      # -------------------------------------------------------------------------
      # MISE A JOUR DE LA FICHE DE METADONNEES DE LA RESSOURCE
      curl -H "Content-Type:application/json" \
           -H "Accept:application/json" \
           -H "X-Api-Key:$API_KEY" \
           --data '{"title": "'"$TITLE"' - '$FORMAT_SIG'", "description": "Livraison > '$DATE_T'"}' \
           -X PUT $API'/datasets/'$DATASET'/resources/'$RESOURCE'/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json'
    else
      # SI LA RESSOURCE N'EXISTE PAS
      # --------------------------------------------------------------------------------------------------------------------------------------------------
      # --------------------------------------------------------------------------------------------------------------------------------------------------
      # ACTUALISATION A JOUR DE LA FICHE DE METADONNEES DU JEU DE DONNEES
      curl -H "Content-Type:application/json" \
           -H "Accept:application/json" \
           -H "X-Api-Key:$API_KEY" \
           --data '{"title": "'"$TITLE"'", "description": "'"$DESCRIPTION"'", "tags": "'"$TAG"'", "frequency": "'"$FREQUENCY"'", "spatial": "'"$SPATIAL"'", "license": "'"$LICENSE"'", "temporal_coverage": "'"$TEMPORAL_COVERAGE"'", "private": "true"}' \
           -X PUT $API'/datasets/'$DATASET'/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'.json'
      # -------------------------------------------------------------------------
      # CREATION DE LA RESSOURCE
      curl -H "Accept:application/json" \
           -H "X-Api-Key:$API_KEY" \
           -F "file=@"$REPER"/"$REPER_OUT"/"$DATE_T"_"$DONNEE"_"$FORMAT_SIG$NZ".zip" \
           -X POST $API'/datasets/'$DATASET'/upload/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json'

      # -------------------------------------------------------------------------
      # MISE A JOUR DE LA FICHE DE METADONNEES DE LA RESSOURCE
      RESOURCE=$(jq -r '.id' $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json')
      echo "${RESOURCE}"

      curl -H "Content-Type:application/json" \
           -H "Accept:application/json" \
           -H "X-Api-Key:$API_KEY" \
           --data '{"title": "'"$TITLE"' - '$FORMAT_SIG'", "description": "Livraison > '$DATE_T'"}' \
           -X PUT $API'/datasets/'$DATASET'/resources/'$RESOURCE'/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json'
    fi
else
# SI LE JEU DE DONNEES N'EXISTE PAS
    # ----------------------------------------------------------------------------------------------------------------------------------------------------
    # ----------------------------------------------------------------------------------------------------------------------------------------------------
    # CREATION DU JEU DE DONNEES
    curl -H "Content-Type:application/json" \
         -H "Accept:application/json" \
         -H "X-Api-Key:$API_KEY" \
         --data '{"title": "'"$TITLE"'", "description": "'"$DESCRIPTION"'", "tags": "'"$TAG"'", "frequency": "'"$FREQUENCY"'", "spatial": "'"$SPATIAL"'", "license": "'"$LICENSE"'", "temporal_coverage": "'"$TEMPORAL_COVERAGE"'", "organization": "'$ORG'", "private": "true"}' \
         -X POST $API'/datasets/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'.json'

    # -------------------------------------------------------------------------
    # CREATION DE LA RESSOURCE
    DATASET=$(jq -r '.id' $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'.json')
    echo "${DATASET}"
    curl -H "Accept:application/json" \
         -H "X-Api-Key:$API_KEY" \
         -F "file=@"$REPER"/"$REPER_OUT"/"$DATE_T"_"$DONNEE"_"$FORMAT_SIG$NZ".zip" \
         -X POST $API'/datasets/'$DATASET'/upload/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json'

    # -------------------------------------------------------------------------
    # MISE A JOUR DE LA FICHE DE METADONNEES DE LA RESSOURCE
    RESOURCE=$(jq -r '.id' $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json')
    echo "${RESOURCE}"

    curl -H "Content-Type:application/json" \
         -H "Accept:application/json" \
         -H "X-Api-Key:$API_KEY" \
         --data '{"title": "'"$TITLE"' - '$FORMAT_SIG'", "description": "Livraison > '$DATE_T'"}' \
         -X PUT $API'/datasets/'$DATASET'/resources/'$RESOURCE'/' > $REPER'/'$REPER_CONFIG_JSON'/'$DONNEE'_'$FORMAT_SIG'.json'
    # ----------------------------------------------------------------------------------------------------------------------------------------------------
    # ----------------------------------------------------------------------------------------------------------------------------------------------------
fi


# -------------------------------------------------------------------------------
# SUPPRESSION DES FICHIERS TEMPORAIRES Suppression des fichiers temporaires
cd $REPER
cd $REPER_TEMP'/'
rm -rfv *

# -------------------------------------------------------------------------------
end=$(date '+%s')
echo "DUREE: $((($end-$start) / 3600))hrs $(((($end-$start) / 60) % 60))min $((($end-$start) % 60))sec"
