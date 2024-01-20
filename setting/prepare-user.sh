#!/bin/bash

# Nombre del archivo que contiene la lista de correos electrónicos
file="prepare-user.txt"
fileDelimiter=" "

# Nombre del grupo de IAM al que se agregarán los usuarios
groupIAM="GrupoFullAccess"
x

# Iterar a través de la lista de correos y crear usuarios en IAM con claves de acceso
while IFS= read -r line
do
  # Obteniendo el nombre de usuario y correo electrónico de la línea
  username=$(echo "$line" | cut -d"$delimiter" -f1)
  email=$(echo "$line" | cut -d"$delimiter" -f2)

  # Usuario
  echo "Usuario: $username, Correo: $email"

  # Crear el usuario IAM
  aws iam create-user --user-name "$username"

  # Agregar el usuario al grupo IAM
  aws iam add-user-to-group --user-name "$username" --group-name "$groupIAM"

  # Asignar una política que otorgue acceso completo a todos los servicios de AWS al usuario
  aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --user-name "$username"

  # Generar y mostrar las credenciales de acceso del usuario
  access_key_info=$(aws iam create-access-key --user-name "$username")
  access_key_id=$(echo "$access_key_info" | jq -r '.AccessKey.AccessKeyId')
  secret_access_key=$(echo "$access_key_info" | jq -r '.AccessKey.SecretAccessKey')

  echo "Usuario: $username"
  echo "Access Key ID: $access_key_id"
  echo "Secret Access Key: $secret_access_key"
  echo "-----------------------------------"

done < "$file"
