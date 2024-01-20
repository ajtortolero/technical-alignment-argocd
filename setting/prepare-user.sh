#!/bin/bash

# Nombre del archivo que contiene la lista de correos electrónicos
file="prepare-user.txt"

# Nombre del grupo de IAM al que se agregarán los usuarios
groupIAM="GrupoFullAccess"

# Iterar a través de la lista de correos y crear usuarios en IAM con claves de acceso
while IFS= read -r email
do
  echo "Usuario: $email"

  # Crear el usuario IAM
  aws iam create-user --user-name "$email"

  # Agregar el usuario al grupo IAM
  aws iam add-user-to-group --user-name "$email" --group-name "$groupIAM"

  # Asignar una política que otorgue acceso completo a todos los servicios de AWS al usuario
  aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --user-name "$email"

  # Generar y mostrar las credenciales de acceso del usuario
  access_key_info=$(aws iam create-access-key --user-name "$email")
  access_key_id=$(echo "$access_key_info" | jq -r '.AccessKey.AccessKeyId')
  secret_access_key=$(echo "$access_key_info" | jq -r '.AccessKey.SecretAccessKey')

  echo "Usuario: $email"
  echo "Access Key ID: $access_key_id"
  echo "Secret Access Key: $secret_access_key"
  echo "-----------------------------------"

done < "$file"
