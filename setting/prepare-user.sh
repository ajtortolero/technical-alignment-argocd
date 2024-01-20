#!/bin/bash

# Nombre del archivo que contiene la lista de correos electrónicos
file="prepare-user.txt"

# Nombre del grupo de IAM al que se agregarán los usuarios
group_iam="GrupoFullAccess"

# Iterar a través de la lista de correos y crear usuarios en IAM con claves de acceso
while IFS= read -r email
do
  echo "Usuario: $email"
done < "$file"