#!/bin/bash

# Uso: sudo ./lowercase_by_id_recursive.sh <WorkshopID>

# Renombra carpetas y archivos dentro de un mod de Workshop a minúsculas recursivamente


if [ $# -ne 1 ]; then

    echo "Uso: sudo $0 <WorkshopID>"

    exit 1

fi


WORKSHOP_ID="$1"

BASE="../server-files/steamapps/workshop/content/108600/$WORKSHOP_ID"

MODS_DIR="$BASE/mods"


if [ ! -d "$MODS_DIR" ]; then

    echo "No existe la carpeta de mods: $MODS_DIR"

    exit 1

fi


echo "Procesando mods del Workshop ID $WORKSHOP_ID..."


# Primero renombramos carpetas de adentro hacia afuera

find "$MODS_DIR" -depth -type d | while read -r DIR; do

    PARENT=$(dirname "$DIR")

    BASENAME=$(basename "$DIR")

    LOWER=$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]')

    if [ "$BASENAME" != "$LOWER" ]; then

        sudo mv "$DIR" "$PARENT/$LOWER"

        echo "Carpeta renombrada: $DIR -> $PARENT/$LOWER"

    fi

done


# Luego renombramos archivos

find "$MODS_DIR" -type f | while read -r FILE; do

    DIRNAME=$(dirname "$FILE")

    FILENAME=$(basename "$FILE")

    LOWER=$(echo "$FILENAME" | tr '[:upper:]' '[:lower:]')

    if [ "$FILENAME" != "$LOWER" ]; then

        sudo mv "$FILE" "$DIRNAME/$LOWER"

        echo "Archivo renombrado: $FILE -> $DIRNAME/$LOWER"

    fi

done


echo "Proceso completado para Workshop ID $WORKSHOP_ID."