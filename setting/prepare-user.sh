#!/bin/bash

# Nombre del archivo que contiene la lista de correos electrónicos
file="prepare-user.txt"
fileDelimiter=" "
fileOutput="prepare-user-created.txt"
# Nombre del grupo de IAM al que se agregarán los usuarios
groupIAM="GrupoFullAccess"
policyIAMAll=$(aws iam list-policies --query 'Policies[?PolicyName==`allow_all`].Arn' --output text)
policyIAMSandbox=$(aws iam list-policies --query 'Policies[?PolicyName==`Playground_AWS_Sandbox`].Arn' --output text)

# Iterar a través de la lista de correos y crear usuarios en IAM con claves de acceso
while IFS= read -r line
do
  # Obteniendo el nombre de usuario y correo electrónico de la línea
  username=$(echo "$line" | cut -d"$fileDelimiter" -f1)
  email=$(echo "$line" | cut -d"$fileDelimiter" -f2)
  password=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 6 | head -n 1)$(cat /dev/urandom | tr -dc 'A-Z' | fold -w 6 | head -n 1)$(cat /dev/urandom | tr -dc '0-9' | fold -w 6 | head -n 1)$(cat /dev/urandom | tr -dc '!@#$%^&*()_+' | fold -w 4 | head -n 1)

  echo "Contraseña generada: $password"

  # Usuario
  echo "Usuario: $username, Correo: $email, Passord: $password"

  # Crear el usuario IAM
  aws iam create-user --user-name "$username"

  # Agrega política al usuario
  aws iam attach-user-policy --policy-arn "$policyIAMAll" --user-name "$username"

  # Agrega política al usuario
  aws iam attach-user-policy --policy-arn "$policyIAMSandbox" --user-name "$username"  
  
  # Crear un perfil de login para el usuario con contraseña
  aws iam create-login-profile --user-name "$username" --password "$password"

  # Generar y mostrar las credenciales de acceso del usuario
  access_key_info=$(aws iam create-access-key --user-name "$username")
  access_key_id=$(echo "$access_key_info" | jq -r '.AccessKey.AccessKeyId')
  secret_access_key=$(echo "$access_key_info" | jq -r '.AccessKey.SecretAccessKey')

  echo "Usuario: $username"
  echo "Access Key ID: $access_key_id"
  echo "Secret Access Key: $secret_access_key"

  echo "Usuario: $username, Contraseña: $password, Access Key ID: $access_key_id, Secret Access Key: $secret_access_key" >> "$fileOutput"

done < "$file"
