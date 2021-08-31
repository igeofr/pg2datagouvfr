#!/bin/sh

# 2021 Florian Boret
# https://github.com/igeofr/pg2datagouvfr
# https://creativecommons.org/licenses/by-sa/4.0/deed.fr
# -----------------------------------------------------------------------------------------------------------
# LECTURE DU FICHIER DE CONFIGURATION
. ./config.env
# ------------------------------------------------------------------------------------------------------------
var_group=DECHETS
var_file=COMPOSTEURS
schema=ccpl_dechet

# ------------------------------------------------------------------------------------------------------------
# ------------------------------------ COMPOSTEURS -----------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------
export requete="SELECT
-----------------------------------------
ST_X(geom) AS x,
-----------------------------------------
ST_Y(geom) AS y,
-----------------------------------------
geom as geometry,
-----------------------------------------
id_com,
-----------------------------------------
type,
-----------------------------------------
adresse,
-----------------------------------------
'Communauté de Communes ...' as source
-----------------------------------------
FROM ccpl_composteurs WHERE ST_IsValid(geom)"

# ------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------
if [ "$FORMAT_SIG" = "SHP" ]
then
  echo "Debut : $var_group > $var_file.shp"
  $LINK_OGR -progress -s_srs EPSG:2154 -t_srs EPSG:$OUT_EPSG -f 'ESRI Shapefile' $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/'$DATE_T'_'$DONNEE'_'$FORMAT_SIG$NZ'.shp' PG:"host='$C_HOST' user='$C_USER' dbname='$C_DBNAME' password='$C_PASSWORD' active_schema='$schema' schemas='$schema'" -dialect SQLITE -sql "SELECT * FROM ($(echo $requete | sed -e 's/-//g'))" -nlt point -lco ENCODING=$ENCODAGE -lco SPATIAL_INDEX=YES --debug ON -skipfailures
  echo "Fin : $var_group > $var_file.shp"
fi
if [ "$FORMAT_SIG" = "GEOJSON" ]
then
  echo "Debut : $var_group > $var_file.geojson"
  $LINK_OGR -progress -s_srs EPSG:2154 -t_srs EPSG:4326 -f 'GEOJSON' $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/'$DATE_T'_'$DONNEE'_'$FORMAT_SIG$NZ'.geojson' PG:"host='$C_HOST' user='$C_USER' dbname='$C_DBNAME' password='$C_PASSWORD' active_schema='$schema' schemas='$schema'" -dialect SQLITE -sql "SELECT * FROM ($(echo $requete | sed -e 's/-//g'))" -nlt point -nln $DONNEE -lco ENCODING=$ENCODAGE -lco RFC7946=YES --debug ON -skipfailures
  echo "Fin : $var_group > $var_file.geojson"
fi
if [ "$FORMAT_SIG" = "GPKG" ]
then
  echo "Debut : $var_group > $var_file"
  $LINK_OGR -progress -s_srs EPSG:2154 -t_srs EPSG:$OUT_EPSG -f 'GPKG' -update -append $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/'$DATE_T'_'$DONNEE'_'$FORMAT_SIG$NZ'.gpkg' PG:"host='$C_HOST' user='$C_USER' dbname='$C_DBNAME' password='$C_PASSWORD' active_schema='$schema' schemas='$schema'" -dialect SQLITE -sql "SELECT * FROM ($(echo $requete | sed -e 's/-//g'))" -nlt point -nln $DONNEE -lco SPATIAL_INDEX=YES --debug ON -skipfailures
  echo "Fin : $var_group > $var_file"
fi
if [ "$FORMAT_SIG" = "SQL" ]
then
  echo "Debut : $var_group > $var_file"
  $LINK_OGR -progress -s_srs EPSG:2154 -t_srs EPSG:$OUT_EPSG -f 'PGDump' $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/'$DATE_T'_'$DONNEE'_'$FORMAT_SIG$NZ'.sql' PG:"host='$C_HOST' user='$C_USER' dbname='$C_DBNAME' password='$C_PASSWORD' active_schema='$schema' schemas='$schema'" -dialect SQLITE -sql "SELECT * FROM ($(echo $requete | sed -e 's/-//g'))" -nln $DONNEE --config PG_USE_COPY YES --debug ON -skipfailures -lco SRID=2154 -lco SCHEMA=$schema -lco GEOMETRY_NAME=geom
  echo "Fin : $var_group > $var_file"
fi
if [ "$FORMAT_SIG" = "CSV" ]
then
  echo "Debut : $var_group > $var_file.csv"
  $LINK_OGR -progress -s_srs EPSG:2154 -t_srs EPSG:$OUT_EPSG -f 'CSV' $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/'$DATE_T'_'$DONNEE'_'$FORMAT_SIG$NZ'.csv' PG:"host='$C_HOST' user='$C_USER' dbname='$C_DBNAME' password='$C_PASSWORD' active_schema='$schema' schemas='$schema'" -dialect SQLITE -sql "SELECT * FROM ($(echo $requete | sed -e 's/-//g'))" -nlt point -lco CREATE_CSVT=YES -lco SEPARATOR=SEMICOLON -lco ENCODING=$ENCODAGE --debug ON -skipfailures
  echo "Fin : $var_group > $var_file.csv"
fi
if [ "$FORMAT_SIG" = "ODS" ]
then
  echo "Debut : $var_group > $var_file.ods"
  $LINK_OGR -progress -s_srs EPSG:2154 -t_srs EPSG:$OUT_EPSG -f 'ODS' $REPER_TEMP'/'$DONNEE'/'$OUT_EPSG'/'$DATE_T'_'$DONNEE'_'$FORMAT_SIG$NZ'.ods' PG:"host='$C_HOST' user='$C_USER' dbname='$C_DBNAME' password='$C_PASSWORD' active_schema='$schema' schemas='$schema'" -dialect SQLITE -sql "SELECT * FROM ($(echo $requete | sed -e 's/-//g'))" -nlt point -lco ENCODING=$ENCODAGE --debug ON -skipfailures
  echo "Fin : $var_group > $var_file.ods"
fi
