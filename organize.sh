#!/bin/bash

# Diretório alvo
dir_target="$1"

# Checa se o diretório foi passado como argumento
if [ -z "$dir_target" ]; then
  echo "Directory is an argument"
  exit 1
fi

# Muda para o diretório
cd "$dir_target"

# Cria uma pasta para cada tipo de arquivo e move os arquivos
for file in *.*; do
  # Extrai a extensão do arquivo
  extension="${file##*.}"
  
  # Cria o diretório se ele não existir
  mkdir -p "$extension"
  
  # Move o arquivo para o diretório correspondente
  mv "$file" "$extension/"
done

echo "Done"
