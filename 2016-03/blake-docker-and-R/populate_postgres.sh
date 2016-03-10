#! /bin/bash

# Ensure that this script is executed from the diretory in which it resides
SCRIPT_DIR="`dirname $0`"
cd $SCRIPT_DIR

CONTAINER_NAME=postgres
DATA_DIR=/opt/data

POSTGRES_DB=aarug
POSTGRES_PASSWORD=risfun
POSTGRES_USER=aarug

# The order of the files here represents the order in which the scripts
# will be executed
POSTGRES_SQL_FILES="
gdp_create.sql
gdp_load.sql
"

docker exec $CONTAINER_NAME mkdir $DATA_DIR

for sql_script in $POSTGRES_SQL_FILES
    do
        echo "Executing $sql_script"
        docker cp $sql_script $CONTAINER_NAME:$DATA_DIR/
        docker exec $CONTAINER_NAME psql -f $DATA_DIR/$sql_script -U $POSTGRES_USER $POSTGRES_DB
    done
