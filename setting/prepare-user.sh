#!/bin/bash

# Nombre del archivo que contiene la lista de correos electrónicos
file="prepare-user.txt"
fileDelimiter=" "
fileOutput="prepare-user-created.txt"
# Nombre del grupo de IAM al que se agregarán los usuarios
groupIAM="GrupoFullAccess"
policyIAM=$(aws iam list-policies --query 'Policies[?PolicyName==`allow_all`].Arn' --output text)

# Iterar a través de la lista de correos y crear usuarios en IAM con claves de acceso
while IFS= read -r line
do
  # Obteniendo el nombre de usuario y correo electrónico de la línea
  username=$(echo "$line" | cut -d"$fileDelimiter" -f1)
  email=$(echo "$line" | cut -d"$fileDelimiter" -f2)
  # password=$(echo "$line" | cut -d"$fileDelimiter" -f3)
  password=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 6 | head -n 1)$(cat /dev/urandom | tr -dc 'A-Z' | fold -w 6 | head -n 1)$(cat /dev/urandom | tr -dc '0-9' | fold -w 6 | head -n 1)$(cat /dev/urandom | tr -dc '!@#$%^&*()_+' | fold -w 4 | head -n 1)

  echo "Contraseña generada: $password"

  # Usuario
  echo "Usuario: $username, Correo: $email, Passord: $password"

  # Verificar si el usuario tiene un perfil de inicio de sesión
  profileExists=$(aws iam list-user-profiles --user-name "$username" --query 'length(ProfileUsers)')

  if [ "$login_profile_exists" -gt 0 ]; then
    # Eliminar el perfil de inicio de sesión del usuario
    aws iam delete-login-profile --user-name "$username"
    echo "Perfil de inicio de sesión eliminado para el usuario: $username"

    # Eliminar el usuario IAM
    aws iam delete-user --user-name "$username"
    echo "Usuari eliminado: $username"
  fi

  # Crear el usuario IAM
  aws iam create-user --user-name "$username"

  # grega política al usuario
  aws iam attach-user-policy --policy-arn "$policyIAM" --user-name "$username"
  
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
