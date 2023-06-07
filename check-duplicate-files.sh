#!/bin/bash

############################################################################################
# Script que cambia los Wikilinks a links normales                                         #
#                                                                                          #
# Requisitos:                                                                              #
#             1. Se debe ejecutar al mismo nivel que el directorio raiz que se quiere      #
#                comprobar                                                                 #
#                                                                                          #
############################################################################################


# Variables globales
directorioActual="$1"
directorioRaiz="$2"


if [ "$#" -ne 2 ]    # No hay dos parámetros
then
    echo "USO:     $0 <directorio Raiz Obsidian> <directorio Raiz Obsidian>"

else   # Hay parámetros suficientes

    files=$(ls "$directorioActual")    # files son los archivos del directorioActual

    for file in $files     # Recorrer archivos del directorio actual
    do

        fileCorrecto="${directorioActual}/${file}"     # Archivo con ruta completa

        if [ -d "$fileCorrecto" ]   # Es un directorio
        then

            bash "$0" "$fileCorrecto" "$directorioRaiz"    # Llamar recursivamente a script
            
        elif [ -f "$fileCorrecto" ]  # Es un archivo corriente
        then
            numRep=$(find "$directorioRaiz" -name "$file" 2> /dev/null | wc -l)
            if [ "$numRep" -ne 1 ]  # Hay más de un archivo
            then 
                echo "ERROR: Hay archivos repetidos:"
                find "$directorioRaiz" -name "$file" 2> /dev/null
                echo -e "\n\n"
            fi
        fi
    done
fi

