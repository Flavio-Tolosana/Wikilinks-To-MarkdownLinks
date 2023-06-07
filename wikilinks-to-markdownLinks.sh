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

# Funciones

# Caso 1: ![[imagen.png]]      ![imagen.png](%2FRutaImagen%2Fimagen.png)
tranformarImagenes () {

    #ob/Intro-Obsidian/texto.md   (es la ruta del markdown el cual se van a cambiar sus wikilinks)
    rutaMarkdown="$1"

    nombresArchivosWikilinks=$(egrep -o '\!\[\[[^]]*\.(jpg|png|gif|bmp|svg)\]\]' "$rutaMarkdown")

    for  wikilink in $nombresArchivosWikilinks      # wikilink tiene formato: ![[imagen.png]]
    do

        # nombreArchivo tiene formato: imagen.png
        nombreArchivo=$(echo "$wikilink" | sed -r 's/\!\[\[(.*)\]\]/\1/g') 
         
        # dir=ob/Intro-Obsidian  (Es el directorio del cual hay que buscar hacia abajo)
        dir=$(dirname "$rutaMarkdown")

        # rutaArchivoLink=ob/Intro-Obsidian/ANEXOS/imgagen.png
        rutaArchivoLink=$(find "$dir" -name "$nombreArchivo" 2> /dev/null)

        # nombreRuta=ANEXOS%2Fimagen.png
        nombreRuta=$(realpath --relative-to="$dir" "$rutaArchivoLink" | sed -r 's/ /%20/g; s/\//%2F/g')

        # buscarWikilink tiene formato:  !\[\[imagen.png\]\]  (para que se pueda buscar)
        buscarWikilink=$(echo "$wikilink" | sed -r 's/\[/\\[/g; s/\]/\\]/g')    

        # Realiza el cambio de buscarWikilink por ![nombreArchivo](nombreRuta)
        sed -i -r "s/$buscarWikilink/\!\[$nombreArchivo\]\($nombreRuta\)/g" "$rutaMarkdown"

    done
}

# Caso 2: (!)[[archivo.???]]      [archivo.???](%2FRutaArchivo%2Farchivo.???)
tranformarArchivosConExtension() {

    #ob/Intro-Obsidian/texto.md   (es la ruta del markdown el cual se van a cambiar sus wikilinks)
    rutaMarkdown="$1"

    nombresArchivosWikilinks=$(egrep -o '(!\[|\[)\[[^]]*\.[^]]*\]\]' "$rutaMarkdown")

    for  wikilink in $nombresArchivosWikilinks      # wikilink tiene formato: (!)[[archivo.???]]
    do

        # nombreArchivo tiene formato: archivo.???
        nombreArchivo=$(echo "$wikilink" | sed -r 's/\!//g; s/\[\[(.*)\]\]/\1/g') 
        
        # dir=ob/Intro-Obsidian  (Es el directorio del cual hay que buscar hacia abajo)
        dir=$(dirname "$rutaMarkdown")

        # rutaArchivoLink=ob/Intro-Obsidian/ANEXOS/arhivo.???
        rutaArchivoLink=$(find "$dir" -name "$nombreArchivo" 2> /dev/null)

        # nombreRuta=ANEXOS%2Farchivo.???
        nombreRuta=$(realpath --relative-to="$dir" "$rutaArchivoLink" | sed -r 's/ /%20/g; s/\//%2F/g')

        # buscarWikilink tiene formato:  (!\[|\[)\[archivo.???\]\]  (para que se pueda buscar)  
        buscarWikilink=$(echo "$wikilink" | sed -r 's/!\[\[/\(!\\[|\\[)\\[/g; s/\[\[/\(!\\[|\\[)\\[/g; s/\]/\\]/g')    

        # Realiza el cambio de buscarWikilink por [nombreArchivo](nombreRuta)
        sed -i -r "s/$buscarWikilink/\[$nombreArchivo\]\($nombreRuta\)/g" "$rutaMarkdown"

    done
}

# Caso 3: ![[markdown#Titulo]]      [markdown.md](%2FRutaMarkdown%2FMarkdown.md)
tranformarMarkdownConTransclusionUnaParte() {

    #ob/Intro-Obsidian/texto.md   (es la ruta del markdown el cual se van a cambiar sus wikilinks)
    rutaMarkdown="$1"

    nombresArchivosWikilinks=$(egrep -o '(!\[|\[)\[[^]]*\#[^]]*\]\]' "$rutaMarkdown")       

    OLDIFS=$IFS     # Guardar separador
    IFS=$'\n'       # Poner separador como salto de línea para poder poner transclusiones con espacios

    for  wikilink in $nombresArchivosWikilinks       # wikilink tiene formato:  ![[markdown#Titulo]]
    do

        # nombreArchivo tiene formato: markdown.md
        nombreArchivo=$(echo "$wikilink" | sed -r 's/\!//g; s/\[\[(.*)\]\]/\1/g; s/([^#]*)#.*/\1.md/g') 
        
        # dir=ob/Intro-Obsidian  (Es el directorio del cual hay que buscar hacia abajo)
        dir=$(dirname "$rutaMarkdown")

        # rutaArchivoLink=ob/Intro-Obsidian/ANEXOS/markdown.md
        rutaArchivoLink=$(find "$dir" -name "$nombreArchivo" 2> /dev/null)

        # nombreRuta=ANEXOS%2Fmarkdown.md
        nombreRuta=$(realpath --relative-to="$dir" "$rutaArchivoLink" | sed -r 's/ /%20/g; s/\//%2F/g')

        # buscarWikilink tiene formato:  !\[\[markdown#\^Titulo\]\]  (para que se pueda buscar)
        buscarWikilink=$(echo "$wikilink" | sed -r 's/\[/\\[/g; s/\]/\\]/g; s/\^/\\^/g')    

        # Realiza el cambio de buscarWikilink por [nombreArchivo](nombreRuta)
        sed -i -r "s/$buscarWikilink/\[$nombreArchivo\]\($nombreRuta\)/g" "$rutaMarkdown"

    done

    IFS=$OLDIFS    # Recupear separador
}

# Caso 4: (!)[[markdown]]         [markdown.md](%2FRutaMarkdown%2Fmarkdown.md)
tranformarMarkdown() {

    #ob/Intro-Obsidian/texto.md   (es la ruta del markdown el cual se van a cambiar sus wikilinks)
    rutaMarkdown="$1"

    nombresArchivosWikilinks=$(egrep -o '(!\[|\[)\[[^]]*\]\]' "$rutaMarkdown")

    for  wikilink in $nombresArchivosWikilinks      # wikilink tiene formato: (!)[[markdown]]
    do

        # nombreArchivo tiene formato: markdown.md
        nombreArchivo=$(echo "$wikilink" | sed -r 's/\!//g; s/\[\[(.*)\]\]/\1.md/g') 
        
        # dir=ob/Intro-Obsidian  (Es el directorio del cual hay que buscar hacia abajo)
        dir=$(dirname "$rutaMarkdown")

        # rutaArchivoLink=ob/Intro-Obsidian/ANEXOS/markdown.md
        rutaArchivoLink=$(find "$dir" -name "$nombreArchivo" 2> /dev/null)

        # nombreRuta=ANEXOS%2Fmarkdown.md
        nombreRuta=$(realpath --relative-to="$dir" "$rutaArchivoLink" | sed -r 's/ /%20/g; s/\//%2F/g')

        # buscarWikilink tiene formato:  (!\[|\[)\[markdown\]\]  (para que se pueda buscar)  
        buscarWikilink=$(echo "$wikilink" | sed -r 's/!\[\[/\(!\\[|\\[)\\[/g; s/\[\[/\(!\\[|\\[)\\[/g; s/\]/\\]/g')    

        # Realiza el cambio de buscarWikilink por [nombreArchivo](nombreRuta)
        sed -i -r "s/$buscarWikilink/\[$nombreArchivo\]\($nombreRuta\)/g" "$rutaMarkdown"

    done
}



# Variables globales
directorioActual="$1"


if [ "$#" -ne 1 ]    # No hay un parámetro
then
    echo "USO:     $0 <directorio Raiz Obsidian>"

else   # Hay parámetros suficientes

    files=$(ls "$directorioActual")    # files son los archivos del directorioActual

    for file in $files     # Recorrer archivos del directorio actual
    do

        fileCorrecto="${directorioActual}/${file}"     # Archivo con ruta completa

        if [ -d "$fileCorrecto" ]   # Es un directorio
        then

            bash "$0" "$fileCorrecto"    # Llamar recursivamente a script
            
        elif [ -f "$fileCorrecto" ] && [[ "$fileCorrecto" == *.md ]]   # Es un archivo corriente y es md
        then
            echo "$fileCorrecto es un archivo MD"

            # Caso 1: ![[imagen.png]]      Cualquier tipo de imagen (con transclusion)

            tranformarImagenes "$fileCorrecto"


            # Caso 2: (!)[[archivo.???]]          Cualquier tipo de archivo (con y sin translusión)

            tranformarArchivosConExtension "$fileCorrecto"
            

            # Caso 3: ![[markdown#algoMas]]      Transclusiones de solo un fragmento (solo se pondrá el link al documento)

            tranformarMarkdownConTransclusionUnaParte "$fileCorrecto"


            # Caso 4: (!)[[markdown]]             Transclusion de todo el documento o wikilink normal

            tranformarMarkdown "$fileCorrecto"

        fi

    done

fi
