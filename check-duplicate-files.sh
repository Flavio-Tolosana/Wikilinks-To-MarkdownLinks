#!/bin/bash

############################################################################################
# Script que cambia los Wikilinks a links normales                                         #
#                                                                                          #
# Requisitos:                                                                              #
#             1. Ejecutarlo script al mismo nivel de la raíz de los archivos obsidian,     #
#                es decir, que el script y la carpeta de obsidian estén juntos             #
#             2. Los archivos no pueden tener nombres con espacios                         #
#             3. Los nombres de los archivos deben de ser único                            #
#             4. Solo puede haber links a archivos que estén en el mismo nivel o más abajo #
#             5. Las imagenes solo pueden tener extensiones: jpg, png, gif, bmp, svg       #
#                                                                                          #
# Ejemplo de uso:   transformadorLinks.sh <direcotrio Raiz Obsidian>                       #
############################################################################################


# Variables globales
directorioActual="$1"
directorioRaiz="$2"


if [ "$#" -ne 2 ]    # No hay dos parámetros
then
    echo "USO:     $0 <directorio Actual> <directorio Raiz Obsidian>"

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

